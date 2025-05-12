--Module 7. TRANSACTION

--I.  SINGLE TRANSACTION
--Autocommit mode là chế độ quản lý giao dịch mặc định của SQL Server Database Engine. 
--Mỗi lệnh Transact-SQL được Commit hoặc Rollback khi nó hoàn thành.
USE AdventureWorks2008R2
GO

-- 1)  Thêm vào bảng Department một dòng dữ liệu tùy ý bằng câu lệnh INSERT..VALUES…
	-- a)  Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng cách 
	-- thực hiện lệnh Begin tran và Rollback, 
	-- dùng câu lệnh Select * From Department xem kết quả.

-- Lệnh check trước/sau thay đổi:
SELECT d.Name, d.GroupName, d.ModifiedDate
FROM HumanResources.Department d

-- lệnh thực thi:
BEGIN TRANSACTION;
INSERT INTO HumanResources.Department (Name, GroupName, ModifiedDate)
VALUES ('AI Research','Research & Development', GETDATE())

ROLLBACK;
-- KQ: trước khi rollback thì row 17 có trong bảng, sau khi roll back thì bị hủy, ko còn row 17


	--b)  Thực hiện câu lệnh trên với lệnh Commit ?

-- Lệnh check trước/sau thay đổi:
SELECT d.Name, d.GroupName, d.ModifiedDate
FROM HumanResources.Department d

-- Lệnh thực thi
BEGIN TRANSACTION;
INSERT INTO HumanResources.Department
(Name, GroupName, ModifiedDate)
VALUES ('AI Research','Research & Development', GETDATE())

COMMIT;
-- KQ: hoàn tất TRANSACTION, lưu lại dòng 17





--2)  Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS ON). 
-- Tạo đoạn batch gồm các thao tác:
	--  Thêm một dòng vào bảng  Department
	--  Tạo một bảng Test (ID int, Name  nvarchar(10))
	--  Thêm một dòng vào Test
	--  ROLLBACK;
	--  Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết 
	--quả.

-- Lệnh giúp check trước/sau thay đổi:
SELECT d.Name, d.GroupName, d.ModifiedDate
FROM HumanResources.Department d

-- Tắt chế độ autocommit
SET IMPLICIT_TRANSACTIONS ON
GO

--2a)
INSERT INTO HumanResources.Department (Name, GroupName, ModifiedDate)
VALUES ('AI RESEARCH 2', 'RESEARCH & DEVELOPMENT',GETDATE())

--2b)
CREATE TABLE Test
(
	ID INT PRIMARY KEY,
	Name NVARCHAR(10)
)

--2c)
INSERT INTO Test (ID, Name) VALUES (1, 'TestData')

-- Check table test
SELECT * FROM Test
-- Đúng 1 dòng ID = 1, Name = TestData

--2d)
ROLLBACK;
GO

--2e)
SELECT * FROM HumanResources.Department -- Mất row "AI RESEARCH 2"
SELECT * FROM Test                      -- bảng Test biến mất luôn

-- Trả lời câu hỏi:
-- INSERT vào Department, tạo TABLE Test, INSERT vào Test → rồi ROLLBACK.
-- Kết quả: Cả dòng mới và bảng mới đều bị xóa, vì đều nằm trong một transaction chưa commit.







-- 3)  Viết đoạn batch thực hiện các thao tác sau (lưu ý thực hiện lệnh SET XACT_ABORT ON: 
-- nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn bộ giao dịch được chấm dứt và Rollback)
--		3a)  Câu lệnh SELECT với phép chia 0:	SELECT 1/0 as Dummy
--		3b)  Cập nhật một dòng trên bảng Department với DepartmentID = '9' (id này không tồn tại)
--		3c)  Xóa một dòng không tồn tại trên bảng Department  (DepartmentID =’66’)
--		3d)  Thêm một dòng bất kỳ vào bảng  Department
--		3e)  COMMIT;
-- Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.


-- Lệnh giúp check trước/sau thay đổi:
SELECT d.Name, d.GroupName, d.ModifiedDate
FROM HumanResources.Department d


-- Lệnh thực thi
SET XACT_ABORT ON -- Ngắt giao dịch khi có lỗi

-- 3a)
SELECT 1/0 as Dummy	

-- 3b)
UPDATE HumanResources.Department
SET Name = 'Dong moi'
WHERE DepartmentID = 9

-- 3c)
DELETE HumanResources.Department
WHERE DepartmentID = 66

-- 3d)
INSERT INTO HumanResources.Department (Name, GroupName)
VALUES ('Phong ban moi', 'Nhom moi')

COMMIT
-- Thực thi TOÀN BỘ đoạn batch trên sẽ có báo lỗi:
-- "Divide by zero error encountered."
											

-- Nếu 1 câu lệnh trong batch bị lỗi (như chia 0), tất cả các thao tác khác cũng bị hủy.
-- đảm bảo dữ liệu không bị lưu khi có lỗi.







-- 4) Thực hiện lệnh SET XACT_ABORT OFF (những câu lệnh lỗi sẽ rollback, transaction vẫn tiếp tục) 
-- sau đó thực thi lại các thao tác của đoạn batch ở câu 3.
-- Quan sát kết quả và giải thích kết  quả?

SET XACT_ABORT OFF  -- Lỗi không làm dừng toàn bộ
BEGIN TRANSACTION;

-- Câu lệnh lỗi chia cho 0, gây lỗi runtime nhưng không làm hủy toàn bộ giao dịch
SELECT 1/0 AS Dummy	

-- Cập nhật dòng không tồn tại (DepartmentID = 9) – KHÔNG lỗi
UPDATE HumanResources.Department
SET Name = 'Dong moi'
WHERE DepartmentID = 9

-- Xóa dòng không tồn tại – KHÔNG lỗi
DELETE FROM HumanResources.Department
WHERE DepartmentID = 66

-- Chèn dòng mới – THỰC THI THÀNH CÔNG
INSERT INTO HumanResources.Department (Name, GroupName, ModifiedDate)
VALUES ('Phong ban moi', 'Nhom moi', GETDATE())

COMMIT
-- KQ: ngoại trừ câu lệnh lỗi /0 ra thì toàn bộ đều được thực thi

-- Lưu ý: Nếu không kiểm soát kỹ, 
-- có thể gây ra tình trạng dữ liệu không đồng nhất khi một phần giao dịch thất bại 
-- nhưng phần còn lại vẫn lưu.




--  Tổng hợp cú pháp quan trọng cần nhớ

--| Tác vụ                                   | Cú pháp                        |
--| ---------------------------------------- | ------------------------------ |
--| Bắt đầu transaction thủ công             | `BEGIN TRANSACTION`            |
--| Kết thúc transaction                     | `COMMIT`                       |
--| Hủy transaction                          | `ROLLBACK`                     |
--| Tắt autocommit (yêu cầu COMMIT thủ công) | `SET IMPLICIT_TRANSACTIONS ON` |
--| Kích hoạt rollback toàn bộ khi gặp lỗi   | `SET XACT_ABORT ON`            |
--| Cho phép thực hiện tiếp dù có lỗi        | `SET XACT_ABORT OFF`           |

