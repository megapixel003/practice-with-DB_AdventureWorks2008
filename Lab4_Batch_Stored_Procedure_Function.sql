--Module 4.  Batch, Stored Procedure, Function
--Tuần 4 : Batch
USE AdventureWorks2008R2;
GO

--1) Viết một batch khai báo biến @tongsoHD chứa tổng số 
--hóa đơn của sản phẩm có ProductID=’778’; nếu @tongsoHD>500 
--thì in ra chuỗi “Sản phẩm 778 có trên 500 đơn hàng”, ngược 
--lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt hàng”
DECLARE @tongsoHD INT;

SELECT @tongsoHD = COUNT(*) 
FROM Sales.SalesOrderDetail 
WHERE ProductID = 778;

IF @tongsoHD > 500
    PRINT 'San pham 778 co tren 500 đon hang';
ELSE
    PRINT 'San pham 778 co it đon đat hang';



--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa 
--đơn của khách hàng @makh, tham số @nam chứa năm lập hóa đơn 
--(ví dụ @nam=2008), nếu @n>0 thì in ra chuỗi: “Khách hàng @makh 
--có @n hóa đơn trong năm 2008” ngược lại nếu @n=0 thì in ra chuỗi 
--“Khách hàng @makh không có hóa đơn nào trong năm 2008”
DECLARE @makh INT = 11000; -- Nhập mã khách hàng
DECLARE @nam INT = 2008;
DECLARE @n INT;

SELECT @n = COUNT(*) 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = @makh AND YEAR(OrderDate) = @nam;

IF @n > 0
    PRINT 'Khach hang ' + CAST(@makh AS NVARCHAR) + 
          ' có ' + CAST(@n AS NVARCHAR) + ' hoa đon trong nam ' + CAST(@nam AS NVARCHAR);
ELSE
    PRINT 'Khach hang ' + CAST(@makh AS NVARCHAR) + ' khong co hoa đon nao trong nam ' + CAST(@nam AS NVARCHAR);



--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) 
--có tổng tiền>100000, thông tin gồm [SalesOrderID], 
--SubTotal=SUM([LineTotal]), Discount (tiền giảm), với Discount được 
--tính như sau:
-- Những hóa đơn có SubTotal<100000 thì không giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)
SELECT 
    SalesOrderID, 
    SUM(LineTotal) AS SubTotal,
    CASE 
        WHEN SUM(LineTotal) < 100000 THEN 0
        WHEN SUM(LineTotal) BETWEEN 100000 AND 119999 THEN SUM(LineTotal) * 0.05
        WHEN SUM(LineTotal) BETWEEN 120000 AND 149999 THEN SUM(LineTotal) * 0.10
        ELSE SUM(LineTotal) * 0.15
    END AS Discount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, 
--chứa giá trị của các field [ProductID],[BusinessEntityID],[OnOrderQty], 
--với giá trị truyền cho các biến @mancc, @masp (vd: @mancc=1650, @masp=4), 
--thì chương trình sẽ gán giá trị tương ứng của field [OnOrderQty] cho biến 
--@soluongcc, nếu @soluongcc trả về giá trị là null thì in ra chuỗi “Nhà 
--cung cấp 1650 không cung cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) 
--thì in chuỗi “Nhà cung cấp 1650 cung cấp sản phẩm 4 với số lượng là 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
DECLARE @mancc INT = 1650;
DECLARE @masp INT = 4;
DECLARE @soluongcc INT;

SELECT @soluongcc = OnOrderQty
FROM Purchasing.ProductVendor
WHERE BusinessEntityID = @mancc AND ProductID = @masp;

IF @soluongcc IS NULL
    PRINT 'Nha cung cap ' + CAST(@mancc AS NVARCHAR) + ' khong cung cap san pham ' + CAST(@masp AS NVARCHAR);
ELSE
    PRINT 'Nha cung cap ' + CAST(@mancc AS NVARCHAR) + ' cung cap san pham ' + CAST(@masp AS NVARCHAR) +
          ' voi so luong la ' + CAST(@soluongcc AS NVARCHAR);


--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.
WHILE (SELECT SUM(Rate) FROM HumanResources.EmployeePayHistory) < 6000 
BEGIN
    UPDATE HumanResources.EmployeePayHistory 
    SET Rate = Rate * 1.1;

    IF (SELECT MAX(Rate) FROM HumanResources.EmployeePayHistory) > 150 
        BREAK;
END