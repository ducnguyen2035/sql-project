-- ===================================================
-- HÀM 2: TÍNH RATING TRUNG BÌNH SẢN PHẨM
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
RETURNS DECIMAL(3, 2)
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
        RETURN -2; -- Mã lỗi: Product_ID không hợp lệ
    
    -- Kiểm tra Product_ID có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE Product_ID = @Product_ID)
        RETURN -1; -- Mã lỗi: Product không tồn tại
    
    -- Kiểm tra tham số ngày
    IF @StartDate IS NULL OR @EndDate IS NULL
        RETURN -3; -- Mã lỗi: Thiếu tham số ngày
    
    -- Kiểm tra logic ngày
    IF @StartDate > @EndDate
        RETURN -4; -- Mã lỗi: StartDate không được lớn hơn EndDate
    
    -- Kiểm tra khoảng thời gian tối thiểu 1 tháng (30 ngày)
    IF DATEDIFF(DAY, @StartDate, @EndDate) < 30
        RETURN -5; -- Mã lỗi: Khoảng thời gian phải tối thiểu 1 tháng (30 ngày)
    -- Kiểm tra nếu sản phẩm chưa có bất kỳ đánh giá nào trong khoảng thời gian
    IF NOT EXISTS (
        SELECT 1 
        FROM PRODUCT_REVIEW 
        WHERE P_ID = @Product_ID
            AND Review_Date >= @StartDate
            AND Review_Date <= @EndDate
    )
        RETURN 0; -- Không có đánh giá trong khoảng thời gian này

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
    
    RETURN @AvgRating;
END;
GO