--Module 4.  Batch, Stored Procedure, Function
--TUAN 5 : Stored Procedure

USE AdventureWorks2008R2
GO

--1)  Viết  một  thủ  tục  tính  tổng  tiền  thu  (TotalDue)  của  mỗi  khách  
--hàng  trong  một tháng bất kỳ của  một năm bất kỳ (tham số tháng và năm) 
--được nhập từ bàn phím, thông tin gồm: 
--CustomerID, SumOfTotalDue =Sum(TotalDue)
CREATE PROCEDURE GetTotalDueByCustomer
	@Month INT,
	@Year INT
AS
BEGIN
	SELECT
		CustomerID,
		SUM(TotalDue) AS SumOfTotalDue
	FROM Sales.SalesOrderHeader
	WHERE MONTH(OrderDate) = @Month AND YEAR(OrderDate) = @Year
	GROUP BY CustomerID
	ORDER BY SumOfTotalDue DESC;
END;
--
EXEC GetTotalDueByCustomer @Month =8, @Year =2005;

--Ktr có đơn hàng nào trong Sales.SalesOrderHeader phù hợp với đk
SELECT * FROM Sales.SalesOrderHeader
WHERE MONTH(OrderDate) = 8 AND YEAR(OrderDate) = 2005;

--2)  Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại 
--của một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. 
--Tham số @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, 
--tham số @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
CREATE PROCEDURE GetSalesYTD
	 @SalesPerson INT, --ID của NV sale (SalePersonID)
	 @SalesYTD MONEY OUTPUT --biến đầu ra, chứa doanh thu từ đầu năm -> hiện tại
AS
BEGIN
	--tính tổng doanh thu từ đầu năm -> hiện tại của nv
	SELECT @SalesYTD = SUM(TotalDue)
	FROM Sales.SalesOrderHeader
	WHERE SalesPersonID = @SalesPerson
		AND	YEAR(OrderDate) = YEAR(GETDATE())
		AND OrderDate <= GETDATE();
END;
--
DECLARE @TotalSales MONEY;
EXEC GetSalesYTD @SalesPerson =200, @SalesYTD = @TotalSales OUTPUT;
PRINT 'Doang thu tu đau nam -> hien tai: ' + CAST(@TotalSales AS NVARCHAR(10));

--3)  Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản 
--phẩm có giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
 CREATE PROCEDURE GetProductsByPrice
    @MaxPrice MONEY
AS
BEGIN
    SELECT ProductID, ListPrice
    FROM Production.Product
    WHERE ListPrice <= @MaxPrice;
END;

--gọi:
EXEC GetProductsByPrice @MaxPrice = 100;


--4)  Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân 
--viên bán hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên  đó. Mức 
--thưởng mới bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin 
--bao gồm [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--SumOfSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01 
CREATE PROCEDURE NewBonus
    @SalesPersonID INT
AS
BEGIN
    UPDATE Sales.SalesPerson
    SET Bonus = Bonus + (SELECT SUM(SubTotal) * 0.01 FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPersonID)
    WHERE BusinessEntityID = @SalesPersonID;

    SELECT 
        @SalesPersonID AS SalesPersonID, 
        Bonus AS NewBonus,
        (SELECT SUM(SubTotal) FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPersonID) AS SumOfSubTotal
    FROM Sales.SalesPerson
    WHERE BusinessEntityID = @SalesPersonID;
END;

--gọi
EXEC NewBonus @SalesPersonID = 276;



--5)  Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query) 
CREATE PROCEDURE GetTopProductCategory
    @Year INT
AS
BEGIN
    SELECT TOP 1 
        pc.ProductCategoryID, 
        pc.Name, 
        (SELECT SUM(sod.OrderQty) 
         FROM Sales.SalesOrderDetail sod
         JOIN Production.Product p ON sod.ProductID = p.ProductID
         JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
         WHERE ps.ProductCategoryID = pc.ProductCategoryID 
         AND YEAR(sod.ModifiedDate) = @Year) AS SumOfQty
    FROM Production.ProductCategory pc
    ORDER BY SumOfQty DESC;
END;
--gọi
EXEC GetTopProductCategory @Year = 2022;



--6)  Tạo thủ tục đặt tên là TongThu  có tham số vào là mã nhân viên, tham số 
--đầu ra là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh 
--RETURN để trả về trạng thái thành công hay thất bại của thủ tục.
CREATE PROCEDURE TongThu
    @SalesPersonID INT,
    @TotalSales MONEY OUTPUT
AS
BEGIN
    SET @TotalSales = (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPersonID);
    
    IF @TotalSales IS NULL
        RETURN -1;  -- Thất bại (không có dữ liệu)
    ELSE
        RETURN 0;   -- Thành công
END;

-- gọi:
DECLARE @TotalSales MONEY;
DECLARE @Status INT;

EXEC @Status = TongThu @SalesPersonID = 276, @TotalSales = @TotalSales OUTPUT;

PRINT 'Tổng trị giá hóa đơn: ' + CAST(@TotalSales AS NVARCHAR(50));
PRINT 'Trạng thái: ' + CAST(@Status AS NVARCHAR(10));


--7)  Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất 
--theo năm đã cho.
CREATE PROCEDURE GetTopCustomerByYear
    @Year INT
AS
BEGIN
    SELECT TOP 1 c.StoreID, s.Name, SUM(soh.TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
    WHERE YEAR(soh.OrderDate) = @Year
    GROUP BY c.StoreID, s.Name
    ORDER BY TotalSpent DESC;
END;
--gọi:
EXEC GetTopCustomerByYear @Year = 2022;



--8)  Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu
--tin vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị 
--not null và các field là khóa  ngoại.
CREATE PROCEDURE Sp_InsertProduct
    @Name NVARCHAR(50),
    @ProductNumber NVARCHAR(25),
    @StandardCost MONEY,
    @ListPrice MONEY,
    @ProductSubcategoryID INT,
    @ModelID INT
AS
BEGIN
    INSERT INTO Production.Product (Name, ProductNumber, StandardCost, ListPrice, ProductSubcategoryID, ProductModelID, SellStartDate)
    VALUES (@Name, @ProductNumber, @StandardCost, @ListPrice, @ProductSubcategoryID, @ModelID, GETDATE());
END;

--gọi
EXEC Sp_InsertProduct @Name = 'New Product', @ProductNumber = 'NP-001', @StandardCost = 50, @ListPrice = 100, @ProductSubcategoryID = 3, @ModelID = 5;



--9)  Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng 
--Sales.SalesOrderHeader khi  biết  SalesOrderID.  Lưu  ý  :  trước  khi  
--xóa  mẫu  tin  trong Sales.SalesOrderHeader  thì  phải  xóa  các  mẫu  
--tin  của  hoá  đơn  đó  trong Sales.SalesOrderDetail. 
CREATE PROCEDURE XoaHD
    @SalesOrderID INT
AS
BEGIN
    DELETE FROM Sales.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
    DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
END;
--gọi
EXEC XoaHD @SalesOrderID = 12345;


--10)  Viết  thủ  tục  Sp_Update_Product  có  tham  số  ProductId  dùng  
--để  tăng  listprice lên 10%  nếu  sản phẩm này tồn  tại,  ngược  lại  
--hiện  thông  báo  không  có  sản  phẩm này.
CREATE PROCEDURE Sp_Update_Product
    @ProductID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Production.Product WHERE ProductID = @ProductID)
    BEGIN
        UPDATE Production.Product
        SET ListPrice = ListPrice * 1.1
        WHERE ProductID = @ProductID;
        
        PRINT 'Giá sản phẩm đã được tăng 10%.';
    END
    ELSE
    BEGIN
        PRINT 'Không tìm thấy sản phẩm này.';
    END
END;
--gọi
EXEC Sp_Update_Product @ProductID = 101;
