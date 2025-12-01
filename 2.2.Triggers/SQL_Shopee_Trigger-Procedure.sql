-- ==============================================================================
USE [QL_SHOPEE_BTL]
GO
-- ==============================================================================

-- 1. TRIGGER: VOUCHER MINIMUM SPEND VALIDATION (Ràng buộc Nghiệp vụ)

IF OBJECT_ID('TRG_Validate_Voucher_Min_Spend', 'TR') IS NOT NULL
    DROP TRIGGER TRG_Validate_Voucher_Min_Spend; -- Valid Voucher
GO

CREATE TRIGGER TRG_Validate_Voucher_Min_Spend
ON ORDER_PAYMENT
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE Voucher_Code IS NOT NULL)
    BEGIN
        DECLARE @Order_ID INT;
        DECLARE @Voucher_Code VARCHAR(50);
        DECLARE @Min_Spend DECIMAL(15, 2);
        DECLARE @Current_Order_Value DECIMAL(15, 2);
        DECLARE @MinSpendStr VARCHAR(50);

        SELECT @Order_ID = Order_ID, @Voucher_Code = Voucher_Code FROM inserted;

        SELECT @Min_Spend = Minimum_Order_Value
        FROM VOUCHER
        WHERE Voucher_Code = @Voucher_Code;

        SELECT @Current_Order_Value = Product_value FROM inserted;

        IF @Current_Order_Value < @Min_Spend
        BEGIN
            SET @MinSpendStr = CAST(@Min_Spend AS VARCHAR(50));
            RAISERROR ('Lỗi Nghiệp vụ (RB 15): Giá trị tiền hàng chưa đạt mức tối thiểu (%s) để áp dụng Voucher này.', 16, 1, @MinSpendStr);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
    END;


    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN

        INSERT INTO ORDER_PAYMENT SELECT * FROM inserted;
    END
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN

        UPDATE op 
        SET op.Order_Status = i.Order_Status, op.Payment_Status = i.Payment_Status, op.Voucher_Code = i.Voucher_Code
        FROM ORDER_PAYMENT op 
        JOIN inserted i ON op.Order_ID = i.Order_ID;
    END
END;
GO

-- 2. TRIGGER: Update Product Rating

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
    SELECT DISTINCT P_ID FROM inserted WHERE P_ID IS NOT NULL
    UNION
    SELECT DISTINCT P_ID FROM deleted WHERE P_ID IS NOT NULL;

    UPDATE p
    SET p.Average_Rating = ISNULL((
        SELECT CAST(AVG(CAST(Rating_Star AS DECIMAL(10, 2))) AS DECIMAL(3, 2))
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
    @Shop_ID INT --add date
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.Order_ID,
        o.Order_Date,
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
        Final_Item_Price AS Total_Item_Amount
    FROM 
        ORDER_PAYMENT o

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
        SUM(oi.Quantity) AS Total_Quantity_Sold,
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