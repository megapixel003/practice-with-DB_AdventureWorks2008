-- Module 8. Bảo trì cơ sở dữ liệu

-- Mục tiêu:
-- Backup và Recovery cơ sở dữ liệu



-- 1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục T:\backup\adv2008back.bak
EXEC sp_dropdevice 'adv2008back', 'delfile';

USE master;
EXEC sp_addumpdevice 
    @devtype = 'disk', 
    @logicalname = 'adv2008back', 
    @physicalname = 'D:\backup\adv2008back.bak';




-- 2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, 
-- rồi thực hiện full backup vào thiết bị backup vừa tạo

-- Chọn chế độ Recovery là FULL:
ALTER DATABASE AdventureWorks2008R2 
SET RECOVERY FULL;

-- Thực hiện full backup vào thiết bị backup:
BACKUP DATABASE AdventureWorks2008R2 
TO adv2008back 
WITH INIT, NAME = 'Full Backup AW2008R2';




-- 3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng 
-- xe đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp hơn 60%.

USE AdventureWorks2008R2;
GO

-- Xác định tổng trị giá mặt hàng xe đạp
SELECT SUM(p.ListPrice) AS TotalBikePrice
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';



-- Cập nhật giá xe đạp còn $15
BEGIN TRANSACTION;

-- Kiểm tra tổng trị giá có >= 60%
DECLARE @totalBikePrice MONEY;

SELECT @totalBikePrice = SUM(p.ListPrice)
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';

IF @totalBikePrice >= 0.6 * (
	SELECT SUM(ListPrice) FROM Production.Product
)
BEGIN
    UPDATE p
    SET ListPrice = 15
    FROM Production.Product p
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.Name = 'Bikes';

    PRINT 'Đã cập nhật giá xe đạp xuống còn $15';
    COMMIT;
END
ELSE
BEGIN
    PRINT 'Không đủ điều kiện giảm giá. Không cập nhật.';
    ROLLBACK;
END;




-- 4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu vào thiết bị 
-- backup vừa tạo
	-- a. Tạo 1 differential backup
	-- b. Tạo 1 transaction log backup

-- a. Differential Backup:
BACKUP DATABASE AdventureWorks2008R2
TO adv2008back
WITH DIFFERENTIAL, NAME = 'Diff Backup AW2008R2';

-- b. Transaction Log Backup:
BACKUP LOG AdventureWorks2008R2
TO adv2008back
WITH NAME = 'Log Backup AW2008R2';





-- 5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục hồi cơ sở dữ 
-- liệu cho các hoạt động trong câu 5, 6).
-- Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup

DELETE FROM Person.EmailAddress;

BACKUP LOG AdventureWorks2008R2
TO adv2008back
WITH NAME = 'Log Backup After Deleting EmailAddress';





-- 6. Thực hiện lệnh:
-- a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như sau:
-- INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
INSERT INTO Person.PersonPhone 
VALUES (10000, '123-456-7890', 1, GETDATE());

-- b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị backup vừa tạo.
BACKUP DATABASE AdventureWorks2008R2
TO adv2008back
WITH DIFFERENTIAL, NAME = 'Diff Backup AW2008R2 After Insert Phone';

-- c. Chú ý giờ hệ thống của máy.
-- Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
DELETE FROM Sales.ShoppingCartItem;





-- 7. Xóa CSDL AdventureWorks2008
DROP DATABASE AW2008R2 AdventureWorks2008R2;






-- 8. 
-- a. Để khôi phục lại CSDL như lúc ban đầu (trước câu 3: giảm giá xe đạp) thì phải 
-- restore thế nào?
	-- Khôi phục CSDL từ full backup để đảm bảo rằng dữ liệu trong CSDL sẽ được phục 
	-- hồi về trạng thái lúc sao lưu. Lệnh sau đây sẽ khôi phục full backup và đưa 
	-- CSDL vào chế độ NORECOVERY (tức chưa hoàn tất quá trình khôi phục, có thể khôi 
	-- phục thêm differential hoặc log backups sau đó)

	-- File 1 là Full Backup
	RESTORE DATABASE [AW2008R2]
	FROM DISK = 'D:\Backup\adv2008back.bak'
	WITH FILE = 1, NORECOVERY, STATS = 10;


-- b. Để khôi phục lại CSDL ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress 
-- vẫn còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?

	-- File 2 là Diff Backup
	-- Diff Backup AW2008R2 - câu 4a
	RESTORE DATABASE [AW2008R2]
	FROM DISK = 'D:\Backup\adv2008back.bak'
	WITH FILE = 2, NORECOVERY, STATS = 10;  

	-- File 3 là Log Backup
	-- Log Backup AW2008R2 - câu 4b
	RESTORE LOG [AW2008R2]
	FROM DISK = 'D:\Backup\adv2008back.bak'
	WITH FILE = 3, NORECOVERY, STATS = 10; 

	-- Full-back -> Diff-back -> Log-back ở câu 4ab
	-- Chỉ ngưng lại tại đây thì WITH FILE 3 -> RECOVERY để kết thúc



-- c. Để khôi phục lại CSDL đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc 
-- restore lại CSDL AdventureWorks2008 ra sao?

	-- File 4 là Log Backup
	-- Log Backup After Deleting EmailAddress - câu 5
	RESTORE LOG [AW2008R2]
	FROM DISK = 'D:\Backup\adv2008back.bak'
	WITH FILE = 4, NORECOVERY, STATS = 10; 

	-- File 5 là Diff Backup 
	-- Diff Backup AW2008R2 After Insert Phone
	RESTORE DATABASE [AW2008R2]
	FROM DISK = 'D:\Backup\adv2008back.bak'
	WITH FILE = 5, RECOVERY;

-- Vẫn có thể khôi phục về thời điểm trước khi xóa bảng Sales.ShoppingCartItem, 
-- bằng cách dừng lại ở Differential Backup (file 5).
-- Nhưng KHÔNG thể khôi phục chính xác đến thời điểm xóa bảng Sales.ShoppingCartItem
-- nếu không có log backup sau thời điểm đó.

	RESTORE HEADERONLY
	FROM DISK = 'D:\Backup\adv2008back.bak';

	RESTORE VERIFYONLY 
	FROM adv2008back;



--9. 
--Tạo cơ sở dữ liệu và bảng mẫu
CREATE DATABASE Plan2Recover;
USE Plan2Recover;

CREATE TABLE T1 (
  PK INT Identity PRIMARY KEY,
  Name VARCHAR(15)
);

--Insert dòng dữ liệu và thực hiện backup FULL
INSERT T1 VALUES ('Full');
BACKUP DATABASE Plan2Recover
TO DISK = 'T:\P2R.bak'
WITH NAME = 'P2R_Full', INIT;

--Thêm dữ liệu và backup Log (2 lần)
INSERT T1 VALUES ('Log 1');
BACKUP LOG Plan2Recover
TO DISK ='T:\P2R.bak'
WITH NAME = 'P2R_Log';
-- FILE = 2

INSERT T1 VALUES ('Log 2');
BACKUP LOG Plan2Recover
TO DISK ='T:\P2R.bak'
WITH NAME = 'P2R_Log';
-- FILE = 3

--Xóa CSDL → Khôi phục từ chuỗi backup
USE Master;
RESTORE DATABASE Plan2Recover
FROM DISK = 'T:\P2R.bak'
WITH FILE = 1, NORECOVERY;

RESTORE LOG Plan2Recover
FROM DISK = 'T:\P2R.bak'
WITH FILE = 2, NORECOVERY;

RESTORE LOG Plan2Recover
FROM DISK = 'T:\P2R.bak'
WITH FILE = 3, RECOVERY;
