-- Module 6: ROLE-PERMISSION

-- Login: User3
-- Password: password3
USE AdventureWorks2008R2
GO

-- 4) Tạo 2 kết nối đến server bằng login User2 và User3 và kiểm tra quyền
SELECT * FROM HumanResources.Employee;

-- Lỗi:
-- Msg 229, Level 14, State 5, Line 4
-- The SELECT permission was denied on the object 'Employee', database 'AdventureWorks2008R2', schema 'HumanResources'.




-- 7b) Tại kết nối của User3: Cập nhật JobTitle
USE AdventureWorks2008R2
GO

-- Lệnh check trước và sau cập nhật:
SELECT e.BusinessEntityID, e.JobTitle
FROM HumanResources.Employee e
WHERE BusinessEntityID = 1

-- Thử lệnh UPDATE:
UPDATE HumanResources.Employee
SET JobTitle = 'Sale Manager'
WHERE BusinessEntityID = 1

-- KQ: Cập nhật thành công 



