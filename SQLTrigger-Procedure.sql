USE [QL_SHOPEE_BTL]
GO


-- TRIGGER 8: Kiểm tra Logic Thanh toán COD (Với bảng SHIPMENT_STATUS)
-- Mục đích: Chỉ cho phép Payment = 'success' nếu trạng thái MỚI NHẤT trong lịch sử là 'delivered'
----------------------------------------------------
CREATE TRIGGER TR_Check_COD_Payment_Integrity
ON ORDER_PAYMENT
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Payment_Status)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN SHIPMENT_PACKAGE sp ON i.Order_ID = sp.Order_ID 
            WHERE 
                i.Payment_Method = 'COD' 
                AND i.Payment_Status = 'success'
                AND NOT EXISTS ( 
                    SELECT 1
                    FROM (
                        SELECT TOP 1 Status_Name
                        FROM SHIPMENT_STATUS ss
                        WHERE ss.Shipment_ID = sp.Shipment_ID
                        ORDER BY ss.Status_ID DESC, ss.Updated_time DESC
                    ) AS LatestStatus
                    WHERE LatestStatus.Status_Name = 'delivered'
                )
        )
        BEGIN
            RAISERROR ('Lỗi Nghiệp vụ (RB 12): Đơn hàng COD chưa có trạng thái "delivered" mới nhất, không thể xác nhận thanh toán thành công.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
    END;
END;
GO

-- TRIGGER 9: Tự động cập nhật Average_Rating cho Sản phẩm
----------------------------------------------------
CREATE TRIGGER TR_Update_Product_Rating
ON PRODUCT_REVIEW
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Dùng bảng tạm để lưu danh sách các Product_ID bị ảnh hưởng
    -- (Cần xử lý cả trường hợp Insert/Update (bảng inserted) và Delete (bảng deleted))
    DECLARE @AffectedProducts TABLE (Product_ID INT);

    INSERT INTO @AffectedProducts
    SELECT DISTINCT P_ID FROM inserted
    UNION
    SELECT DISTINCT P_ID FROM deleted;

    -- Cập nhật lại Average_Rating cho các sản phẩm bị ảnh hưởng
    UPDATE p
    SET p.Average_Rating = ISNULL((
        SELECT CAST(AVG(CAST(Rating_Star AS DECIMAL(10, 2))) AS DECIMAL(3, 1))
        FROM PRODUCT_REVIEW pr
        WHERE pr.P_ID = p.Product_ID
    ), 0) -- Nếu không còn đánh giá nào thì về 0
    FROM PRODUCT p
    JOIN @AffectedProducts ap ON p.Product_ID = ap.Product_ID;
END;
GO

-- THỦ TỤC 1: Lấy lịch sử đơn hàng chi tiết của một Shop
----------------------------------------------------
CREATE PROCEDURE SP_Get_Shop_Order_History
    @Shop_ID INT,
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.Order_ID,
        o.Order_Date,
        u.Full_name AS Buyer_Name,
        sp.Tracking_Number,
        v.Variant_Name, -- Tên biến thể (VD: Màu Đỏ, Size M)
        oi.Quantity,
        oi.Price_at_Purchase,
        (oi.Quantity * oi.Price_at_Purchase) AS Total_Item_Amount,
        (
            SELECT TOP 1 ss.Status_Name
            FROM SHIPMENT_STATUS ss
            WHERE ss.Shipment_ID = sp.Shipment_ID
            ORDER BY ss.Updated_time DESC, ss.Status_ID DESC
        ) AS Current_Shipment_Status
    FROM 
        ORDER_PAYMENT o
    JOIN 
        [USER] u ON o.User_ID = u.User_ID
    JOIN 
        SHIPMENT_PACKAGE sp ON o.Order_ID = sp.Order_ID
    JOIN 
        ORDER_ITEM oi ON sp.Shipment_ID = oi.Shipment_ID
    JOIN 
        VARIANT v ON oi.Variant_ID = v.Variant_ID
    JOIN 
        PRODUCT p ON v.P_ID = p.Product_ID
    WHERE 
        p.Shop_ID = @Shop_ID
        AND o.Order_Date BETWEEN @StartDate AND @EndDate
    ORDER BY 
        o.Order_Date DESC, o.Order_ID ASC;
END;
GO

-- Câu lệnh kiểm tra (Dùng khi báo cáo):
-- EXEC SP_Get_Shop_Order_History @Shop_ID = 1, @StartDate = '2023-01-01', @EndDate = '2023-12-31';

-- THỦ TỤC 2: Báo cáo các sản phẩm có doanh thu cao (Best Sellers) của Shop
----------------------------------------------------
CREATE PROCEDURE SP_Report_Top_Selling_Products
    @Shop_ID INT,
    @Month INT,
    @Year INT,
    @Min_Revenue DECIMAL(15, 2) -- Ngưỡng doanh thu tối thiểu để lọt top
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.Product_ID,
        p.Product_Name,
        c.Category_Name,
        SUM(oi.Quantity) AS Total_Sold_Quantity,
        SUM(oi.Quantity * oi.Price_at_Purchase) AS Total_Revenue
    FROM 
        PRODUCT p
    JOIN 
        CATEGORY c ON p.C_ID = c.Category_ID
    JOIN 
        VARIANT v ON p.Product_ID = v.P_ID
    JOIN 
        ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
    JOIN 
        SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
    JOIN 
        ORDER_PAYMENT o ON sp.Order_ID = o.Order_ID
    WHERE 
        p.Shop_ID = @Shop_ID
        AND MONTH(o.Order_Date) = @Month
        AND YEAR(o.Order_Date) = @Year
        AND o.Order_Status = 'completed'
    GROUP BY 
        p.Product_ID, p.Product_Name, c.Category_Name 
    HAVING 
        SUM(oi.Quantity * oi.Price_at_Purchase) >= @Min_Revenue
    ORDER BY 
        Total_Revenue DESC;
END;
GO
