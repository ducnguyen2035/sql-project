-- ===================================================
	-- HÀM 1: PRODUCT_RECOMMENDATION_ENGINE - CÔNG CỤ GỢI Ý SẢN PHẨM
	-- Mục đích: Đề xuất các sản phẩm cho khách hàng dựa trên lịch sử mua sắm và độ phổ biến.
	-- ===================================================

	USE [QL_SHOPEE_BTL];
	GO

	CREATE OR ALTER FUNCTION dbo.ProductRecommendationEngine (
 		@customerID INT, -- Input: id của khách hàng (@customerID)
 		@limitRange INT  -- Input: số lượng sản phẩm được đề xuất (@limitRange)
	)
	RETURNS NVARCHAR(MAX)
	AS
	BEGIN
 		--  KHAI BÁO CÁC BIẾN CẦN DÙNG
 		DECLARE @productID INT;
 
 		-- Thông tin sản phẩm (Được SELECT INTO trong vòng lặp)
 		DECLARE @categoryID INT, @shopID INT;
 		DECLARE @categoryName VARCHAR(255), @productName VARCHAR(255), @shopName VARCHAR(255);
 		DECLARE @basePrice DECIMAL(10,2), @rating DECIMAL(3,2);
 		DECLARE @totalSales INT, @baseImage NVARCHAR(MAX);
 		DECLARE @description VARCHAR(MAX);
 
 		-- JSON kết quả (Output: recommendedProducts)
 		DECLARE @recommendedProducts NVARCHAR(MAX) = '[]';
 		DECLARE @productJSON NVARCHAR(1000);
 
 		--  KIỂM TRA THAM SỐ ĐẦU VÀO (YÊU CẦU BTL: IF)
 
 		-- Kiểm tra customer_id có tồn tại không
 		IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE User_ID = @customerID)
 		BEGIN
   		RETURN '{"status": false, "message": "Invalid customer_id"}';
 		END;
 
 		-- Set giá trị mặc định cho limit
 		IF @limitRange IS NULL OR @limitRange <= 0
   		SET @limitRange = 10;
 
	--  TẠO TỔ HỢP ID CỦA CÁC SẢN PHẨM ĐƯỢC ĐỀ XUẤT
	-- Lưu ý: Các ID sản phẩm là khác nhau (GROUP BY), và có trạng thái là 'for_sale' (Active).


	-- Bảng tạm lưu trữ ID và mức ưu tiên cao nhất của mỗi sản phẩm
	DECLARE @RecommendedProductsTemp TABLE (
 		Product_ID INT PRIMARY KEY, 
 		Priority INT
	);

	-- Lấy danh sách Category mà khách hàng đã mua (sử dụng để gợi ý)
	DECLARE @PurchasedCategories TABLE (Category_ID INT);
 		INSERT INTO @PurchasedCategories
 		SELECT DISTINCT p.C_ID
 		FROM PRODUCT p
 		INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
 		INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
 		INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
 		INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
 		WHERE op.User_ID = @customerID AND op.Order_Status = 'completed';


	-- Chèn vào bảng tạm bằng UNION ALL
	INSERT INTO @RecommendedProductsTemp (Product_ID, Priority)
	SELECT Product_ID, MAX(Priority) AS Priority -- Chọn mức ưu tiên cao nhất
	FROM (
 		-- Ưu tiên 3: Các sản phẩm từng mua (mua lại)
 		SELECT DISTINCT p.Product_ID, 3 AS Priority
 		FROM PRODUCT p
 		INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
 		INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
 		INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
 		INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
 		WHERE op.User_ID = @customerID AND op.Order_Status = 'completed' AND p.Product_Status = 'for_sale'
 
 		UNION ALL
 
 		-- Ưu tiên 2: Sản phẩm cùng danh mục (gợi ý từ các sản phẩm từng mua)
 		SELECT p.Product_ID, 2 AS Priority
 		FROM PRODUCT p
 		WHERE p.C_ID IN (SELECT Category_ID FROM @PurchasedCategories)
   		AND p.Product_Status = 'for_sale'
 
 		UNION ALL
 
 		-- Ưu tiên 1: Các sản phẩm được đánh giá cao (Top rated)
 		SELECT TOP 20 Product_ID, 1 AS Priority
 		FROM PRODUCT
 		WHERE Product_Status = 'for_sale' AND Average_Rating IS NOT NULL
 		ORDER BY Average_Rating DESC, Total_Sales DESC
	) AS AllProducts
	GROUP BY Product_ID; -- Nhóm lại để xử lý trùng lặp và chọn MAX(Priority)
 
	--  TẠO VÒNG LẶP ĐỂ THÊM THÔNG TIN CÁC SẢN PHẨM VÀO JSON
 
	DECLARE productCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 		SELECT TOP (@limitRange) Product_ID
 		FROM @RecommendedProductsTemp
 		-- Sắp xếp để ưu tiên mức ưu tiên cao nhất
 		ORDER BY Priority DESC, Product_ID; 
 
	OPEN productCursor;
 
	FETCH NEXT FROM productCursor INTO @productID;
 
	WHILE @@FETCH_STATUS = 0 -- Bắt đầu vòng lặp (YÊU CẦU BTL: LOOP)
 		BEGIN
   		-- Lấy thông tin chi tiết sản phẩm (Lấy dữ liệu từ truy vấn để tính toán)
   		SELECT
     		@categoryID = c.Category_ID, @categoryName = c.Category_name, @baseImage = p.Base_Image,
     		@productName = p.Product_name, @basePrice = p.Base_Price,
     		@description = ISNULL(p.Description, ''), @rating = ISNULL(p.Average_Rating, 0),
     		@totalSales = p.Total_Sales, @shopID = s.Shop_ID, @shopName = s.Shop_name
   		FROM PRODUCT p
   		INNER JOIN CATEGORY c ON p.C_ID = c.Category_ID
   		INNER JOIN SHOP_SELL s ON p.Shop_ID = s.Shop_ID
   		WHERE p.Product_ID = @productID AND p.Product_Status = 'for_sale';
   
   		-- Kiểm tra nếu có dữ liệu để tránh lỗi JSON
   		IF @productName IS NOT NULL
   		BEGIN
      
     		SET @productJSON = '{' +
       		'"productId": ' + CAST(@productID AS NVARCHAR(10)) + ', ' +
       		'"productName": "' + REPLACE(@productName, '"', '\"') + '", ' +
			'"baseImage": "' + REPLACE(@baseImage, '"', '\"') + '", ' +
       		'"categoryId": ' + CAST(@categoryID AS NVARCHAR(10)) + ', ' +
       		'"categoryName": "' + REPLACE(@categoryName, '"', '\"') + '", ' +
       		'"price": ' + CAST(@basePrice AS NVARCHAR(20)) + ', ' +
       		'"description": "' + REPLACE(LEFT(@description, 100), '"', '\"') + '", ' +
       		'"rating": ' + CAST(@rating AS NVARCHAR(10)) + ', ' +
       		'"soldAmount": ' + CAST(@totalSales AS NVARCHAR(10)) + ', ' +
       		'"shopId": ' + CAST(@shopID AS NVARCHAR(10)) + ', ' +
       		'"shopName": "' + REPLACE(@shopName, '"', '\"') + '"' +
       		'}';
     
     		-- Append vào mảng JSON
     		IF @recommendedProducts = '[]'
       			SET @recommendedProducts = '[' + @productJSON + ']';
     		ELSE
       			SET @recommendedProducts = STUFF(@recommendedProducts, LEN(@recommendedProducts), 1, ', ' + @productJSON + ']');
   		END;
   
   		FETCH NEXT FROM productCursor INTO @productID;
 		END;
 
 		CLOSE productCursor;
 		DEALLOCATE productCursor;
 
 		-- TRẢ VỀ recommended_products (Output)
 
 		RETURN '{"status": true, "recommendedProducts": ' + @recommendedProducts + '}';
	END;
	GO

-- ===================================================
-- HÀM 2: TÍNH RATING TRUNG BÌNH SẢN PHẨM
-- Mục đích: Có thể dùng để so sánh rating trung bình hiện tại của sản phẩm khi mới ra mắt với rating trung bình hiện tại
-- ===================================================
USE [QL_SHOPEE_BTL]
GO

CREATE OR ALTER FUNCTION CalculateProductAverageRating
(
	-- Tham số đầu vào ( YÊU CẦU )
    @Product_ID INT,
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS NVARCHAR(100)
AS
BEGIN
	-- Khai báo các biến
    DECLARE @AvgRating DECIMAL(3, 2) = 0,
			@ReviewCount INT = 0,
			@TotalStars INT = 0,
			@CurrentStar INT,
			@ReviewDate DATETIME;
    
    -- Kiểm tra tham số đầu vào ( YÊU CẦU )
    -- Kiểm tra Product_ID hợp lệ
    IF @Product_ID <= 0
        RETURN '{"status": false, "code": -2, "message": "Invalid Product ID."}';
    
    -- Kiểm tra Product_ID có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE Product_ID = @Product_ID)
        RETURN '{"status": false, "code": -1, "message": "Product not found."}';
    
    -- Kiểm tra tham số ngày
    IF @StartDate IS NULL OR @EndDate IS NULL
        RETURN '{"status": false, "code": -3, "message": "Missing date parameter."}';
    
    -- Kiểm tra logic ngày
    IF @StartDate > @EndDate
        RETURN '{"status": false, "code": -4, "message": "StartDate must not be greater than EndDate."}';
    
    -- Kiểm tra khoảng thời gian tối thiểu 1 tháng (30 ngày)
    IF DATEDIFF(DAY, @StartDate, @EndDate) < 30
        RETURN '{"status": false, "code": -5, "message": "The time period must be at least 30 days."}';
    -- Kiểm tra nếu sản phẩm chưa có bất kỳ đánh giá nào trong khoảng thời gian
    IF NOT EXISTS (
        SELECT 1 
        FROM PRODUCT_REVIEW 
        WHERE P_ID = @Product_ID
            AND Review_Date >= @StartDate
            AND Review_Date <= @EndDate
    )
        RETURN '{"status": true,' + ' "AvgRating": 0.00}';

    -- Khai báo và sử dụng Con trỏ duyệt qua Rating_Star của sản phẩm ( YÊU CẦU )
    DECLARE rating_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT 
            Rating_Star,
            Review_Date
        FROM PRODUCT_REVIEW
        WHERE P_ID = @Product_ID
            AND Rating_Star BETWEEN 1 AND 5
            AND Review_Date >= @StartDate
            AND Review_Date <= @EndDate
        ORDER BY Review_Date DESC; -- Sắp xếp theo ngày mới nhất 
    
    OPEN rating_cursor;
    FETCH NEXT FROM rating_cursor INTO @CurrentStar, @ReviewDate;
    
    -- LOOP ( YÊU CẦU )
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- IF: Kiểm tra rating hợp lệ (YÊU CẦU)
        IF @CurrentStar IS NOT NULL AND @CurrentStar BETWEEN 1 AND 5
        BEGIN
            -- Tích lũy tổng số sao và tổng số lượt đánh giá
            SET @TotalStars = @TotalStars + @CurrentStar;
            SET @ReviewCount = @ReviewCount + 1;
        END;
        
        FETCH NEXT FROM rating_cursor INTO @CurrentStar, @ReviewDate;
    END;
    
    CLOSE rating_cursor;
    DEALLOCATE rating_cursor;
    
    IF @ReviewCount > 0
	-- Tính điểm trung bình và làm tròn
        SET @AvgRating = ROUND(CAST(@TotalStars AS DECIMAL(10,2)) / @ReviewCount, 2);
    
    RETURN '{"status": true,' + ' "AvgRating": ' + CAST(@AvgRating AS VARCHAR(10)) + '}';
END;
GO