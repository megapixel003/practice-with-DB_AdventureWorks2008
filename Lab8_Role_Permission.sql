-- Tuần 8
-- Module 6: ROLE-PERMISSION


-- Sử dụng SSMS (Sql Server Management Studio) để thực hiện các thao tác sau:
-- 1) Đăng nhập vào SQL bằng SQL Server authentication, tài khoản sa. Sử dụng T-SQL.
--DONE




-- 2) Tạo hai login SQL server Authentication User2 và User3
-- Tạo login User2 & User3 với mk:
CREATE LOGIN User2 WITH PASSWORD = 'password2';
CREATE LOGIN User3 WITH PASSWORD = 'password3';

-- Mỗi LOGIN là một thực thể ở mức server, 
-- không liên quan trực tiếp đến bất kỳ CSDL nào cho đến khi gán thành USER trong 1 CSDL cụ thể!

-- Xóa user2 và user3 nếu bên dưới bạn tạo có bị lỗi
-- IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'User2')
--     DROP LOGIN User2;
-- IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'User3')
--     DROP LOGIN User3;




-- 3) Tạo một database user User2 ứng với login User2 và một database user User3
-- ứng với login User3 trên CSDL AdventureWorks2008.
USE AdventureWorks2008R2
GO

-- Tạo database user User2 liên kết với login User2 
-- và user User3 liên kết với login User3
CREATE USER User2 FOR LOGIN User2;
GO
CREATE USER User3 FOR LOGIN User3;
GO

-- USER là thực thể trong database (DB-level), ánh xạ đến LOGIN (server-level).

-- Xóa user2 và user3 nếu bên dưới bạn tạo có bị lỗi
-- DROP USER IF EXISTS User2;
-- DROP USER IF EXISTS User3;






-- 4) Tạo 2 kết nối đến server thông qua login User2 và User3, 
-- sau đó thực hiện các thao tác truy cập CSDL của 2 user tương ứng 
-- (VD: thực hiện câu Select). 
-- Có thực hiện được không?

-- Không thực hiện được
-- Lỗi: do User2 và User3 chưa có quyền SELECT trên bảng.






-- 5) Gán quyền select trên Employee cho User2, 
-- kiểm tra kết quả. 
-- Xóa quyền select trên Employee cho User2. 
-- Ngắt 2 kết nối của User2 và User3

-- B1: Gán quyền select
-- Thực hiện dưới tài khoản sa hoặc người có quyền cao
GRANT SELECT ON HumanResources.Employee TO User2;
GO

-- B3: Xóa quyền select
REVOKE SELECT ON HumanResources.Employee FROM User2;
GO







-- 6) Trở lại kết nối của sa, 
-- tạo một user-defined database Role tên Employee_Role trên CSDL AdventureWorks2008, 
-- sau đó gán các quyền Select, Update, Delete cho Employee_Role.

USE AdventureWorks2008R2
GO

-- Tạo role
CREATE ROLE Employee_Role
GO

-- gán quyền SELECT, UPDATE, DELETE trên bảng Employee cho role
GRANT SELECT, UPDATE, DELETE ON HumanResources.Employee TO Employee_Role;

-- CREATE ROLE tạo một role cấp cơ sở dữ liệu (Database Role). 
-- Role này có thể được gán cho nhiều user để họ cùng chia sẻ quyền.





-- 7) Thêm các User2 và User3 vào Employee_Role. 
ALTER ROLE Employee_Role ADD MEMBER User2;
ALTER ROLE Employee_Role ADD MEMBER User3;
GO
-- Tạo lại 2 kết nối đến server thông qua login User2 và User3 thực hiện các thao tác sau:

-- 7a) Tại kết nối với User2, 
-- thực hiện câu lệnh Select để xem thông tin của bảng Employee

-- 7b) Tại kết nối của User3, 
-- thực hiện cập nhật JobTitle= ’Sale Manager’ của nhân viên có BusinessEntityID=1

-- 7c) Tại kết nối User2, 
-- dùng câu lệnh Select xem lại kết quả.



-- 7d) Xóa role Employee_Role, 
-- (quá trình xóa role ra sao?)

-- Trước khi xóa role, 
-- cần xóa tất cả các thành viên trong role, 
-- nếu không sẽ bị lỗi.

-- Xóa User2 và User3 khỏi role
ALTER ROLE Employee_Role DROP MEMBER User2;
ALTER ROLE Employee_Role DROP MEMBER User3;
GO

-- Sau đó xóa role
DROP ROLE Employee_Role;
GO




