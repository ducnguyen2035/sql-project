-- ==============================================================================
USE [QL_SHOPEE_BTL]
GO
-- ==============================================================================

-- 1. TRIGGER: COD PAYMENT INTEGRITY (Ràng buộc Nghiệp vụ)

IF OBJECT_ID('TR_Check_COD_Payment_Integrity', 'TR') IS NOT NULL
    DROP TRIGGER TR_Check_COD_Payment_Integrity;
GO

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
                        ORDER BY ss.Updated_time DESC, ss.Status_ID DESC
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

-- 2. TRIGGER: CẬP NHẬT THUỘC TÍNH DẪN XUẤT (Average_Rating)

IF OBJECT_ID('TRG_Update_Product_Rating', 'TR') IS NOT NULL
    DROP TRIGGER TRG_Update_Product_Rating;
GO

CREATE TRIGGER TRG_Update_Product_Rating
ON PRODUCT_REVIEW
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @AffectedProducts TABLE (Product_ID INT);

    INSERT INTO @AffectedProducts
    SELECT DISTINCT P_ID FROM inserted 
    UNION
    SELECT DISTINCT P_ID FROM deleted;

    UPDATE p
    SET p.Average_Rating = ISNULL((
        SELECT CAST(AVG(CAST(Rating_Star AS DECIMAL(10, 2))) AS DECIMAL(3, 1))
        FROM PRODUCT_REVIEW pr
        WHERE pr.P_ID = p.Product_ID
    ), 0)
    FROM PRODUCT p
    JOIN @AffectedProducts ap ON p.Product_ID = ap.Product_ID;
END;
GO

-- 3. THỦ TỤC 1: LẤY LỊCH SỬ ĐƠN HÀNG CHI TIẾT CỦA MỘT SHOP 

IF OBJECT_ID('SP_Get_Shop_Order_History', 'P') IS NOT NULL
    DROP PROCEDURE SP_Get_Shop_Order_History;
GO

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
        (
            SELECT TOP 1 ss.Status_Name
            FROM SHIPMENT_STATUS ss
            WHERE ss.Shipment_ID = sp.Shipment_ID
            ORDER BY ss.Updated_time DESC, ss.Status_ID DESC
        ) AS Current_Shipment_Status,
        v.Variant_Name,
        oi.Quantity,
        oi.Price_at_Purchase,
        (oi.Quantity * oi.Price_at_Purchase) AS Total_Item_Amount
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
        PRODUCT p ON v.P_ID = p.Product_ID -- Liên kết cuối cùng để lọc theo Shop_ID
    WHERE 
        p.Shop_ID = @Shop_ID
        AND o.Order_Date BETWEEN @StartDate AND @EndDate
    ORDER BY 
        o.Order_Date DESC, o.Order_ID ASC; 
END;
GO

-- 4. THỦ TỤC 2: BÁO CÁO CÁC SẢN PHẨM CÓ DOANH THU CAO 

IF OBJECT_ID('SP_Report_Top_Selling_Products', 'P') IS NOT NULL
    DROP PROCEDURE SP_Report_Top_Selling_Products;
GO

CREATE PROCEDURE SP_Report_Top_Selling_Products
    @Shop_ID INT,
    @Month INT,
    @Year INT,
    @Min_Revenue DECIMAL(15, 2)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.Product_ID,
        p.Product_Name,
        c.Category_Name,
        SUM(oi.Quantity) AS Total_Quantity_Sold, -- Aggregate
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
        p.Shop_ID = @Shop_ID -- Mệnh đề WHERE
        AND MONTH(o.Order_Date) = @Month
        AND YEAR(o.Order_Date) = @Year
        AND o.Order_Status = 'completed'
    GROUP BY 
        p.Product_ID, p.Product_Name, c.Category_Name -- Mệnh đề GROUP BY
    HAVING 
        SUM(oi.Quantity * oi.Price_at_Purchase) >= @Min_Revenue -- Mệnh đề HAVING
    ORDER BY 
        Total_Revenue DESC; -- Mệnh đề ORDER BY
END;
GO