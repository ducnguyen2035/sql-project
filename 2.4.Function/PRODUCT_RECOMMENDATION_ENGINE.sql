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
 		-- 1. KHAI BÁO CÁC BIẾN CẦN DÙNG
 		DECLARE @productID INT;
 
 		-- Thông tin sản phẩm (Được SELECT INTO trong vòng lặp)
 		DECLARE @categoryID INT, @shopID INT;
 		DECLARE @categoryName VARCHAR(255), @productName VARCHAR(255), @shopName VARCHAR(255);
 		DECLARE @basePrice DECIMAL(10,2), @rating DECIMAL(3,2);
 		DECLARE @totalSales INT;
 		DECLARE @description VARCHAR(MAX);
 
 		-- JSON kết quả (Output: recommendedProducts)
 		DECLARE @recommendedProducts NVARCHAR(MAX) = '[]';
 		DECLARE @productJSON NVARCHAR(1000);
 
 		-- 2. KIỂM TRA THAM SỐ ĐẦU VÀO (YÊU CẦU BTL: IF)
 
 		-- Kiểm tra customer_id có tồn tại không
 		IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE User_ID = @customerID)
 		BEGIN
   		RETURN '{"status": false, "message": "Invalid customer_id"}';
 		END;
 
 		-- Set giá trị mặc định cho limit
 		IF @limitRange IS NULL OR @limitRange <= 0
   		SET @limitRange = 10;
 
	-- 3. TẠO TỔ HỢP ID CỦA CÁC SẢN PHẨM ĐƯỢC ĐỀ XUẤT
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
 
	-- 4. TẠO VÒNG LẶP ĐỂ THÊM THÔNG TIN CÁC SẢN PHẨM VÀO JSON
 
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
     		@categoryID = c.Category_ID, @categoryName = c.Category_name,
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
 
 		-- 6. TRẢ VỀ recommended_products (Output)
 
 		RETURN '{"status": true, "recommendedProducts": ' + @recommendedProducts + '}';
	END;
	GO
