--Client B
USE AdventureWorks2008R2
GO

--câu 3)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

--B1
BEGIN TRAN; 
SELECT * FROM Accounts WHERE acctID = 101;

--B3:
UPDATE Accounts 
SET balance = 500 
WHERE acctID = 101;
--> bị chặn (blocked).
--> sau khi client A COMMIT(B4) mới thực thi tiếp

--B5:
SELECT * FROM Accounts WHERE acctID = 101; 
COMMIT;


--Do READ COMMITTED, nên khi Client A đang cập nhật và chưa COMMIT, 
--Client B không thể sửa dòng đó và sẽ bị chặn (blocked).

--Sau khi Client A COMMIT, thì Client B mới thực thi tiếp.
--Kết quả cuối cùng phụ thuộc vào lệnh cập nhật cuối cùng được thực hiện và commit




----------------------------------------------------------------------



--4)
--Ở cả Client A và Client B, chạy lệnh:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO

--B1
BEGIN TRAN; 
SELECT * FROM Accounts WHERE acctID = 101;

--B3
UPDATE Accounts 
SET balance = 500 
WHERE acctID = 101;
--bị chặn và thoát luôn giao dịch

--B5: 
SELECT * FROM Accounts WHERE acctID = 101;
COMMIT;

--Kết quả:
--(1 row affected)
--Completion time: 2025-04-15T01:36:01.8304465+07:00

--Do `REPEATABLE READ`, 
--khi Client A đã `SELECT`, SQL Server sẽ giữ khóa đọc (S-lock) trên dòng đó 
--cho đến khi `COMMIT`, ngăn không cho transaction khác sửa dữ liệu đã đọc.

--Khi Client B cũng cố gắng cập nhật dòng đó, nó bị chặn. 
--Nếu cả hai bên đều giữ khóa 
--(A giữ S-lock → UPDATE → muốn X-lock, B giữ S-lock rồi UPDATE), 
--dễ dẫn đến **deadlock** hoặc **timeout** (thoát giao dịch)

--Kết quả là **một transaction bị rollback**, 
--đảm bảo dữ liệu đã đọc trong transaction sẽ không bị thay đổi xuyên suốt 
--transaction.




---------------------------------------------------------------------------


--câu 5
--Sử dụng SERIALIZABLE để đảm bảo các giao dịch diễn ra tuần tự, tránh xung đột.


-- Cách 1: SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

SELECT * FROM Accounts WHERE acctID = 101; 
COMMIT;

-- Trừ tiền tài khoản 202
UPDATE Accounts
SET balance = balance - 200
WHERE acctID = 202;

-- Cộng tiền tài khoản 101
UPDATE Accounts
SET balance = balance + 200
WHERE acctID = 101;

COMMIT;



-- lệnh check
SELECT * FROM Accounts WHERE acctID IN (101,202)






--Cách 2: giống câu 3
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
--b1
BEGIN TRAN;
SELECT * FROM Accounts WHERE acctID IN (101,202)
--b3
UPDATE Accounts
SET balance = balance - 200
WHERE acctID = 202

UPDATE Accounts	
SET balance = balance + 200
WHERE acctID = 101

--b5
SELECT * FROM Accounts WHERE acctID IN (101,202)
COMMIT



-----------------------------------------------------------------------


-- câu 6:
-- B2: Client B: thiết lập ISOLATION LEVEL READ UNCOMMITTED
-- SELECT * FROM Accounts; COMMIT;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN;

-- Đọc dữ liệu sẽ thấy giá trị ĐÃ CẬP NHẬT (nhưng chưa commit)
SELECT * FROM Accounts; 

COMMIT;


--Kết luận:
	--READ UNCOMMITTED cho phép đọc dữ liệu chưa commit, gây ra dirty read.
	--Sau khi ROLLBACK, dữ liệu trở về trạng thái cũ, nhưng Client B đã đọc sai.
	--Không nên dùng trong các hệ thống yêu cầu tính nhất quán cao.





-----------------------------------------------------------------------------





--7)
BEGIN TRAN;
INSERT INTO Accounts (acctID, balance) VALUES (303, 3000);

COMMIT;















