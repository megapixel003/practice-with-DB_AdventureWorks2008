-- Module 6: ROLE-PERMISSION

-- Login: User2
-- Password: password2
USE AdventureWorks2008R2
GO

-- 4) Tạo 2 kết nối đến server bằng login User2 và User3 và kiểm tra quyền
SELECT * FROM HumanResources.Employee;

-- Lỗi:
-- Msg 229, Level 14, State 5, Line 4
-- The SELECT permission was denied on the object 'Employee', database 'AdventureWorks2008R2', schema 'HumanResources'.







-- 5)
-- Gán quyền SELECT cho User2, 
-- kiểm tra và sau đó thu hồi quyền

-- B2: Test
SELECT * FROM HumanResources.Employee;

-- KQ: Có thể xem dữ liệu bảng HumanResources.Employee

-- B4: chạy lại lệnh SELECT sẽ có báo lỗi



-- 7a)
USE AdventureWorks2008R2
GO

SELECT e.BusinessEntityID , e.JobTitle
FROM HumanResources.Employee e

-- KQ: Xem được bảng HumanResources.Employee




-- 7c)
USE AdventureWorks2008R2
GO

SELECT e.BusinessEntityID, e.JobTitle
FROM HumanResources.Employee e
WHERE e.BusinessEntityID = 1

-- Nếu thấy Sales Manager, 
-- tức là User3 cập nhật thành công và User2 đọc được.



