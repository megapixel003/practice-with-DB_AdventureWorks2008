--Client A
USE AdventureWorks2008R2
GO

--3)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

--B1
BEGIN TRAN; 
SELECT * FROM Accounts WHERE acctID = 101;

--B2:
UPDATE Accounts 
SET balance = 800 
WHERE acctID = 101;


--B4:
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

--B2:
UPDATE Accounts 
SET balance = 800 
WHERE acctID = 101;
--bị chặn 1 lúc, sau đó mới thực thi khi client B cũng chạy UPDATE

--B4:
SELECT * FROM Accounts WHERE acctID = 101; 
COMMIT;

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




-----------------------------------------------------------------------


--câu 5)
--Sử dụng SERIALIZABLE để đảm bảo các giao dịch diễn ra tuần tự, tránh xung đột.
--Phải đảm bảo đủ tiền trước khi trừ bằng cách thêm điều kiện:

-- Cách 1: SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

SELECT * FROM Accounts WHERE acctID = 101; 
COMMIT;

-- Trừ tiền tài khoản 101
UPDATE Accounts
SET balance = balance - 100
WHERE acctID = 101;

-- Cộng tiền tài khoản 202
UPDATE Accounts
SET balance = balance + 100
WHERE acctID = 202;

COMMIT;


-- lệnh check
SELECT * FROM Accounts WHERE acctID IN (101,202)






-- Cách 2: làm giống câu 3
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
--b1
BEGIN TRAN;
SELECT * FROM Accounts WHERE acctID IN (101,202)
--b2
UPDATE Accounts
SET balance = balance - 100
WHERE acctID = 101

UPDATE Accounts	
SET balance = balance + 100
WHERE acctID = 202

--b4
SELECT * FROM Accounts WHERE acctID IN (101,202)
COMMIT


---------------------------------------------------------------------------


-- Câu 6:
-- B1: Client A: cập nhật balance của account giảm đi 100 cho AccountID =101, 
-- cập nhật balance của account tăng lên 100 cho AccountID =202

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;

UPDATE Accounts
SET balance = balance - 100 -- Giảm 100
WHERE acctID = 101;

UPDATE Accounts
SET balance = balance + 100 -- tăng 100
WHERE acctID = 202;

-- TẠM DỪNG ở đây để chờ Client B SELECT
-- B3: Rollback (hủy giao dịch)
ROLLBACK;


--Kết luận:
	--READ UNCOMMITTED cho phép đọc dữ liệu chưa commit, gây ra dirty read.
	--Sau khi ROLLBACK, dữ liệu trở về trạng thái cũ, nhưng Client B đã đọc sai.
	--Không nên dùng trong các hệ thống yêu cầu tính nhất quán cao.




-----------------------------------------------------------------------------





--7)
--B1: Client A: thiết lập 
--ISOLATION LEVEL REPEATABLE READ;
--Lấy ra các Accounts có Balance > 1000

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRAN;

SELECT * FROM Accounts WHERE balance > 1000

COMMIT
















