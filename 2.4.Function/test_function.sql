-- ===================================================
-- KIEM THU CAC HAM
-- ===================================================

USE [QL_SHOPEE_BTL];
GO

-- Khối lệnh dùng để test các hàm, muốn kiểm tra tham số nào của sản phẩm thì thêm  vào tập kết quả cuối cùng, và group by
DECLARE @CUSTID INT = 110;
DECLARE @LIMIT INT = 10;

-- Tạo và hiển thị bảng kiểm tra
WITH PurchasedCategories AS (
    SELECT DISTINCT p.C_ID
    FROM PRODUCT p
    INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
    INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
    INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
    INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
    WHERE op.User_ID = @CUSTID AND op.Order_Status = 'completed'
),
AllProducts AS (
    -- Priority 3: Buy Again (1008, 1011)
    SELECT DISTINCT p.Product_ID, 3 AS Priority
    FROM PRODUCT p
    INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
    INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
    INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
    INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
    WHERE op.User_ID = @CUSTID AND op.Order_Status = 'completed' AND p.Product_Status = 'for_sale'
    
    UNION ALL
    
    -- Priority 2: Cross-Category (Sản phẩm cùng C_ID 12, 13)
    SELECT p.Product_ID, 2 AS Priority
    FROM PRODUCT p
    WHERE p.C_ID IN (SELECT C_ID FROM PurchasedCategories) AND p.Product_Status = 'for_sale'
    
    UNION ALL
    
    -- Priority 1: Top Rated
    SELECT TOP 20 Product_ID, 1 AS Priority
    FROM PRODUCT
    WHERE Product_Status = 'for_sale' AND Average_Rating IS NOT NULL
    ORDER BY Average_Rating DESC, Total_Sales DESC
)
-- Tập kết quả cuối cùng (MAX Priority, sắp xếp và giới hạn)
SELECT TOP (@LIMIT)
    ap.Product_ID,
    MAX(ap.Priority) AS Final_Priority,
    p.Product_name,
	p.C_ID,
	p.Average_Rating
FROM AllProducts ap
JOIN PRODUCT p ON ap.Product_ID = p.Product_ID
GROUP BY ap.Product_ID, p.Product_name, p.C_ID, p.Average_Rating
ORDER BY Final_Priority DESC, ap.Product_ID;

--====================================================--

-- TEST HAM 1: PRODUCT_RECOMMENDATION_ENGINE
DECLARE @RecResult1 NVARCHAR(MAX);
-- Customer 107 đã mua (Headphones, Dress). Category đã mua: 12, 13.
SET @RecResult1 = dbo.ProductRecommendationEngine(107, 4); 
SELECT @RecResult1 AS Recommendation_Result_C107;
GO

--- TEST 2: Customer 110 đã mua Novel (1023). Category đã mua: 6, 7.
DECLARE @RecResult2 NVARCHAR(MAX);
-- Product 1024 (Self-Help Book) thuộc C_ID 7 -> Priority 2.
SET @RecResult2 = dbo.ProductRecommendationEngine(110, 5);
SELECT @RecResult2 AS Recommendation_Result_C110;
GO

--- TEST 3: Kiểm tra Customer ID không tồn tại
DECLARE @RecResult3 NVARCHAR(MAX);
-- Sử dụng UserID 9999 (không tồn tại trong CUSTOMER)
SET @RecResult3 = dbo.ProductRecommendationEngine(9999, 5); 
SELECT @RecResult3 AS Recommendation_Result_C9999;
GO

--- TEST 4: KIỂM TRA GIỚI HẠN MẶC ĐỊNH (@limitRange = NULL)
DECLARE @RecResult4 NVARCHAR(MAX);
-- Truyền giá trị NULL cho @limitRange
SET @RecResult4 = dbo.ProductRecommendationEngine(107, NULL); 
SELECT @RecResult4 AS Recommendation_Result_Limit_NULL;
GO

--- TEST 5: KIỂM TRA GIỚI HẠN MẶC ĐỊNH (@limitRange = 0)
DECLARE @RecResult5 NVARCHAR(MAX);
-- Truyền giá trị 0 cho @limitRange
SET @RecResult5 = dbo.ProductRecommendationEngine(107, 0); 
SELECT @RecResult5 AS Recommendation_Result_Limit_ZERO;
GO

-- ===================================================
-- TEST HAM 2: CalculateProductAverageRating
-- ===================================================

-- TEST 1: Lỗi: Product ID không hợp lệ (<= 0). Mong đợi: -2
SELECT dbo.CalculateProductAverageRating(0, '2025-11-01', '2025-12-31') AS Result_Error_Minus2;
GO

-- TEST 2: Lỗi: Product ID không tồn tại (Ví dụ: 99999). Mong đợi: -1
SELECT dbo.CalculateProductAverageRating(99999, '2025-11-01', '2025-12-31') AS Result_Error_Minus1;
GO

-- TEST 3: Lỗi: Thiếu tham số ngày (EndDate = NULL). Mong đợi: -3
SELECT dbo.CalculateProductAverageRating(1004, '2025-11-01', NULL) AS Result_Error_Minus3;
GO

-- TEST 4: Lỗi: Logic ngày (StartDate > EndDate). Mong đợi: -4
SELECT dbo.CalculateProductAverageRating(1004, '2025-12-31', '2025-11-01') AS Result_Error_Minus4;
GO

-- TEST 5: Lỗi: Khoảng thời gian tối thiểu (< 30 ngày). Mong đợi: -5
SELECT dbo.CalculateProductAverageRating(1004, '2025-11-01', '2025-11-15') AS Result_Error_Minus5;
GO

-- Test 6: Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1008, '2025-09-15', '2025-12-15') AS Result;
GO

-- Test 7 : Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1016, '2025-09-15', '2025-12-15') AS Result;
GO

-- Test 8: Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1023, '2025-10-15', '2025-12-15') AS Result;
GO