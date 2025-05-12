--I.  II. CONCURRENT TRANSACTIONS (Các giao tác đồng thời)

USE AdventureWorks2008R2
GO

--1) Tạo bảng Accounts (AccountID int NOT NULL PRIMARY KEY, balance int NOT NULL
--CONSTRAINT unloanable_account CHECK (balance >= 0)
--Chèn dữ liệu:
--INSERT INTO Accounts (acctID,balance) VALUES (101,1000); INSERT INTO Accounts (acctID,balance) VALUES (202,2000);

-- Tạo bảng Accounts
CREATE TABLE Accounts (
    acctID INT NOT NULL PRIMARY KEY,
    balance INT NOT NULL,
    CONSTRAINT unloanable_account CHECK (balance >= 0)
);
GO

-- Chèn dữ liệu vào bảng Accounts
INSERT INTO Accounts (acctID, balance) VALUES (101, 1000);
INSERT INTO Accounts (acctID, balance) VALUES (202, 2000);
GO

SELECT * FROM Accounts;
GO






--2) SET TRANSACTION ISOLATION LEVEL

--Cú pháp:
--SET TRANSACTION ISOLATION LEVEL
	--{ READ UNCOMMITTED
	--| READ COMMITTED
	--| REPEATABLE READ
	--| SNAPSHOT
	--| SERIALIZABLE
	--}[ ; ]

--READ UNCOMMITTED: có thể đọc những dòng đang được hiệu chỉnh bởi các transaction khác nhưng chưa commit
--READ COMMITTED: không thể đọc những dòng đang hiệu chỉnh bởi những transaction khác mà chưa commit

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Cho phép đọc dữ liệu chưa được commit (dirty read)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Mặc định: Chỉ đọc dữ liệu đã commit. Nếu có transaction khác đang sửa dữ liệu thì phải chờ.

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Dữ liệu đã đọc không được sửa bởi transaction khác cho đến khi kết thúc

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Nghiêm ngặt nhất: tránh phantom reads

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
-- Cho phép đọc bản sao snapshot của dữ liệu đã được commit





--3) Mở 2 cửa sổ Query của SQL server, thiết lập SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
--ở cả 2 cửa sổ (tạm gọi là client A bên trái, và client B bên phải):
	-- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
	-- B2: Client A cập nhật account trên AccountID =101, balance =1000-200
	-- B3: Client B cập nhật account trên AccountID =101, balance =1000-500
	-- B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
	-- B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT;
--Quan sát kết quả hiển thị và giải thích.

--Ở cả Client A và Client B, chạy lệnh:
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

--Do READ COMMITTED, nên khi Client A đang cập nhật và chưa COMMIT, 
--Client B không thể sửa dòng đó và sẽ bị chặn (blocked).

--Sau khi Client A COMMIT, thì Client B mới thực thi tiếp.
--Kết quả cuối cùng phụ thuộc vào lệnh cập nhật cuối cùng được thực hiện và commit









--4) Thiết lập ISOLATION LEVEL REPEATABLE READ (không thể đọc được dữ liệu đã được hiệu chỉnh 
--nhưng chưa commit bởi các transaction khác và không có transaction khác có thể hiệu chỉnh dữ 
--liệu đã được đọc bởi các giao dịch hiện tại cho đến transaction hiện tại hoàn thành) ở 2 client. 
--Thực hiện yêu cầu sau:
		-- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
		-- B2: Client A cập nhật accounts trên AccountID =101, balance =1000-200
		-- B3: Client B cập nhật accounts trên AccountID =101, balance =1000-500.
		-- B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
--Quan sát kết quả hiển thị và giải thích.

--Ở cả Client A và Client B, chạy lệnh:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO

--REPEATABLE READ khóa toàn bộ dòng đã đọc → ngăn chặn transaction khác cập nhật hoặc chèn trên dòng đó.
--Client B bị block đến khi Client A commit.
--Giúp tránh non-repeatable read (lỗi đọc dữ liệu bị thay đổi giữa chừng).






--5) Giả sử có 2 giao dịch chuyển tiền từ tài khoản 101 và 202 như sau:
	-- Client A chuyển 100$ từ tài khoản 101 sang 202
	-- Client B chuyển 200$ từ tài khoản 202 sang 101.
--Viết các lệnh tương ứng ở 2 client để kiểm soát các giao dịch xảy ra đúng









--6) Xóa tất cả dữ liệu của bảng Accounts. Thêm lại các dòng mới
	--INSERT INTO Accounts (AccountID ,balance) VALUES (101,1000);
	--INSERT INTO Accounts (AccountID ,balance) VALUES (202,2000);

	-- B1: Client A: cập nhật balance của account giảm đi 100 cho AccountID =101, 
	--cập nhật balance của account tăng lên 100 cho AccountID =202

	-- B2: Client B: thiết lập ISOLATION LEVEL READ UNCOMMITTED
	--SELECT * FROM Accounts; COMMIT;

	-- B3: Client A:
	--ROLLBACK;
	--SELECT * FROM Accounts; COMMIT;
--Quan sát kết quả và giải thích.


-- Xóa tất cả dữ liệu của bảng Accounts.
DELETE FROM Accounts;

-- -- Thêm dữ liệu mới
INSERT INTO Accounts (acctID, balance) VALUES (101, 1000);
INSERT INTO Accounts (acctID, balance) VALUES (202, 2000);

SELECT * FROM Accounts


--Kết luận:
	--READ UNCOMMITTED cho phép đọc dữ liệu chưa commit, gây ra dirty read.
	--Sau khi ROLLBACK, dữ liệu trở về trạng thái cũ, nhưng Client B đã đọc sai.
	--Không nên dùng trong các hệ thống yêu cầu tính nhất quán cao.





--7) Xóa tất cả dữ liệu của bảng Account, thêm lại các dòng mới

-- Xóa tất cả dữ liệu của bảng Accounts.
DELETE FROM Accounts;

-- thêm dòng mới
INSERT INTO Accounts (acctID ,balance) VALUES (101,1000); 
INSERT INTO Accounts (acctID ,balance) VALUES (202,2000);

SELECT * FROM Accounts

--B1: Client A: thiết lập 
--ISOLATION LEVEL REPEATABLE READ;
--Lấy ra các Accounts có Balance > 1000

--B2: Client B:
--INSERT INTO Accounts (acctID ,balance) VALUES (303,3000);
--COMMIT;

--B3: Client A:
--SELECT * FROM Accounts WHERE balance > 1000;
--COMMIT;


DELETE FROM Accounts WHERE acctID = 303




KILL 161
KILL 69
















