--Module 3.  View
USE AdventureWorks2008R2;
GO

--1)  Tạo  view  dbo.vw_Products  hiển  thị  danh  sách  các  sản  phẩm  từ  bảng 
--Production.Product và bảng  Production.ProductCostHistory. Thông tin  bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE VIEW dbo.vw_Products AS
SELECT 
    p.ProductID, 
    p.Name, 
    p.Color, 
    p.Size, 
    p.Style, 
    pch.StandardCost, 
    pch.EndDate, 
    pch.StartDate
FROM Production.Product p
JOIN Production.ProductCostHistory pch 
    ON p.ProductID = pch.ProductID;



--2)  Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008  và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.
CREATE VIEW dbo.List_Product_View AS
SELECT 
    sod.ProductID, 
    p.Name AS Product_Name, 
    COUNT(DISTINCT soh.SalesOrderID) AS CountOfOrderID, 
    SUM(sod.OrderQty * sod.UnitPrice) AS SubTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(soh.OrderDate) = 2008 AND MONTH(soh.OrderDate) BETWEEN 1 AND 3
GROUP BY sod.ProductID, p.Name
HAVING COUNT(DISTINCT soh.SalesOrderID) > 500 AND SUM(sod.OrderQty * sod.UnitPrice) > 10000;

	

--3)  Tạo view dbo.vw_CustomerTotals  hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID,  YEAR(OrderDate)  AS  OrderYear,  MONTH(OrderDate)  AS 
--OrderMonth,  SUM(TotalDue).
CREATE VIEW dbo.vw_CustomerTotals AS
SELECT 
    CustomerID, 
    YEAR(OrderDate) AS OrderYear, 
    MONTH(OrderDate) AS OrderMonth, 
    SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, YEAR(OrderDate), MONTH(OrderDate);


--4)  Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên  theo  từng  năm.  Thông  tin gồm  SalesPersonID,  OrderYear,  sumOfOrderQty
CREATE VIEW dbo.vw_SalesPersonTotalQuantity AS
SELECT 
    soh.SalesPersonID, 
    YEAR(soh.OrderDate) AS OrderYear, 
    SUM(sod.OrderQty) AS sumOfOrderQty
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY soh.SalesPersonID, YEAR(soh.OrderDate);


--5)  Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin  gồm  mã khách (PersonID) , họ tên 
--(FirstName +'  '+ LastName as FullName), Số hóa đơn  (CountOfOrders).
CREATE VIEW dbo.ListCustomer_view AS
SELECT 
    p.BusinessEntityID AS PersonID, 
    p.FirstName + ' ' + p.LastName AS FullName, 
    COUNT(soh.SalesOrderID) AS CountOfOrders
FROM Person.Person p
JOIN Sales.Customer c ON p.BusinessEntityID = c.PersonID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE YEAR(soh.OrderDate) BETWEEN 2007 AND 2008
GROUP BY p.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 25;


--6)  Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên  50 sản phẩm, thông 
--tin  gồm  ProductID,  Name,  SumOfOrderQty,  Year.  (dữ  liệu  lấy  từ  các  bảng
--Sales.SalesOrderHeader,          Sales.SalesOrderDetail,          và
--Production.Product)
CREATE VIEW dbo.ListProduct_view AS
SELECT 
    p.ProductID, 
    p.Name, 
    SUM(sod.OrderQty) AS SumOfOrderQty, 
    YEAR(soh.OrderDate) AS OrderYear
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'
GROUP BY p.ProductID, p.Name, YEAR(soh.OrderDate)
HAVING SUM(sod.OrderQty) > 50;


--7)  Tạo view List_department_View chứa  danh sách  các  phòng  ban  có lương  (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
CREATE VIEW dbo.List_department_View AS
SELECT 
    d.DepartmentID, 
    d.Name, 
    AVG(eph.Rate) AS AvgOfRate
FROM HumanResources.Department d
JOIN HumanResources.EmployeeDepartmentHistory edh 
    ON d.DepartmentID = edh.DepartmentID
JOIN HumanResources.EmployeePayHistory eph 
    ON edh.BusinessEntityID = eph.BusinessEntityID
GROUP BY d.DepartmentID, d.Name
HAVING AVG(eph.Rate) > 30;


--8)  Tạo view  Sales.vw_OrderSummary  với từ khóa  WITH ENCRYPTION gồm 
--OrderYear  (năm  của  ngày  lập),  OrderMonth  (tháng  của  ngày  lập),  OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view  này
CREATE VIEW Sales.vw_OrderSummary 
WITH ENCRYPTION AS
SELECT 
    YEAR(OrderDate) AS OrderYear, 
    MONTH(OrderDate) AS OrderMonth, 
    SUM(TotalDue) AS OrderTotal
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

EXEC sp_helptext 'Sales.vw_OrderSummary'; -- Không thể xem nội dung do mã hóa

--9)  Tạo  view  Production.vwProducts  với  từ  khóa  WITH  SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice  của  bảng Product và bảng 
--ProductCostHistory.  Xem  thông  tin  của  View.  Xóa  cột  ListPrice  của  bảng 
--Product. Có xóa được không? Vì sao?
CREATE VIEW Production.vwProducts 
WITH SCHEMABINDING AS
SELECT 
    p.ProductID, 
    p.Name, 
    pch.StartDate, 
    pch.EndDate, 
    p.ListPrice
FROM Production.Product p
JOIN Production.ProductCostHistory pch 
    ON p.ProductID = pch.ProductID;

--xem thông tin của View
EXEC sp_help 'Production.vwProducts'; --xem thông tin của View

--Thử xóa cột ListPrice trong bảng Product
ALTER TABLE Production.Product DROP COLUMN ListPrice; 

--Không xóa được! vì WITH SCHEMABINDING ràng buộc bảng gốc. Cần xóa 
--View trước khi thay đổi cấu trúc bảng.




--10) Tạo  view  view_Department  với  từ  khóa  WITH  CHECK  OPTION  chỉ  chứa  các 
--phòng  thuộc  nhóm  có  tên  (GroupName)  là  “Manufacturing”  và  “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name,  GroupName.
CREATE VIEW dbo.view_Department 
AS
SELECT 
    DepartmentID, 
    Name, 
    GroupName
FROM HumanResources.Department
WHERE GroupName IN ('Manufacturing', 'Quality Assurance')
WITH CHECK OPTION;

--a.  Chèn thêm một phòng ban mới thuộc nhóm không  thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.
INSERT INTO dbo.view_Department (DepartmentID, Name, GroupName)
VALUES (20, 'Marketing', 'Sales'); 
-- Không chèn được, do WITH CHECK OPTION ràng buộc chỉ chấp nhận 
-- dữ liệu thuộc nhóm 'Manufacturing' hoặc 'Quality Assurance'.


--b.  Chèn  thêm  một  phòng  mới  thuộc  nhóm  “Manufacturing”  và  một 
--phòng thuộc nhóm “Quality  Assurance”.
INSERT INTO dbo.view_Department (DepartmentID, Name, GroupName)
VALUES (21, 'New Manufacturing', 'Manufacturing');

INSERT INTO dbo.view_Department (DepartmentID, Name, GroupName)
VALUES (22, 'QA Inspection', 'Quality Assurance');


--c.  Dùng câu lệnh Select xem kết quả trong bảng  Department.
SELECT * FROM HumanResources.Department;
