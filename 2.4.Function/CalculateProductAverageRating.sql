-- ===================================================
-- HÀM 2: TÍNH RATING TRUNG BÌNH SẢN PHẨM
-- ===================================================
USE [QL_SHOPEE_BTL]
GO

CREATE OR ALTER FUNCTION CalculateProductAverageRating
(
	-- Tham số đầu vào ( YÊU CẦU )
    @Product_ID INT
)
RETURNS DECIMAL(3, 2)
AS
BEGIN
	-- Khai báo các biến
    DECLARE @AvgRating DECIMAL(3, 2) = 0,
			@ReviewCount INT = 0,
			@TotalStars INT = 0,
			@CurrentStar INT;
    
    -- Kiểm tra tham số đầu vào ( YÊU CẦU )
    IF @Product_ID <= 0
        RETURN -2;
    
    IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE Product_ID = @Product_ID)
        RETURN -1;
    -- Kiểm tra nếu sản phẩm chưa có bất kỳ đánh giá nào
    IF NOT EXISTS (SELECT 1 FROM PRODUCT_REVIEW WHERE P_ID = @Product_ID)
        RETURN 0;
    -- Khai báo và sử dụng Con trỏ duyệt qua Rating_Star của sản phẩm ( YÊU CẦU )
    DECLARE rating_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT Rating_Star
        FROM PRODUCT_REVIEW
        WHERE P_ID = @Product_ID
          AND Rating_Star BETWEEN 1 AND 5 
        ORDER BY Review_ID; 
    
    OPEN rating_cursor;
    FETCH NEXT FROM rating_cursor INTO @CurrentStar;
    
    -- LOOP ( YÊU CẦU )
    WHILE @@FETCH_STATUS = 0
    BEGIN
		-- Tích lũy tổng số sao và tổng số lượt đánh giá
        SET @TotalStars = @TotalStars + @CurrentStar;
        SET @ReviewCount = @ReviewCount + 1;
        
        FETCH NEXT FROM rating_cursor INTO @CurrentStar;
    END
    
    CLOSE rating_cursor;
    DEALLOCATE rating_cursor;
    
    IF @ReviewCount > 0
	-- Tính điểm trung bình và làm tròn
        SET @AvgRating = ROUND(CAST(@TotalStars AS DECIMAL(10,2)) / @ReviewCount, 2);
    
    RETURN @AvgRating;
END;
GO