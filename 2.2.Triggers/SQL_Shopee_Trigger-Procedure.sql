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
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Voucher_Code) OR UPDATE(Product_value)
    BEGIN
        -- CHECK 1: KIỂM TRA MÃ VOUCHER CÓ TỒN TẠI TRONG HỆ THỐNG KHÔNG?ỗi
        IF EXISTS (
            SELECT 1 
            FROM inserted i 
            WHERE i.Voucher_Code IS NOT NULL 
              AND NOT EXISTS (SELECT 1 FROM VOUCHER v WHERE v.Voucher_Code = i.Voucher_Code)
        )
        BEGIN
            DECLARE @Non_Exist_Code VARCHAR(50);
            SELECT TOP 1 @Non_Exist_Code = Voucher_Code FROM inserted WHERE Voucher_Code IS NOT NULL;
            
            RAISERROR ('Lỗi Nghiệp vụ: Mã Voucher "%s" không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1, @Non_Exist_Code);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- CHECK 2: KIỂM TRA GIÁ TRỊ TỐI THIỂU (MIN SPEND) & TỐI ĐA (MAX SPEND)
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN VOUCHER v ON i.Voucher_code = v.Voucher_Code
            WHERE 
                i.Product_value < v.Minimum_Order_Value
                OR 
                (v.Maximum_Order_Value > 0 AND i.Product_value > v.Maximum_Order_Value)
        )
        BEGIN
            DECLARE @Err_Voucher VARCHAR(50);
            DECLARE @Min_Spend VARCHAR(50);
            DECLARE @Max_Spend VARCHAR(50);
            DECLARE @Current_Value VARCHAR(50);
            
            SELECT TOP 1 
                @Err_Voucher = i.Voucher_code,
                @Min_Spend = CAST(v.Minimum_Order_Value AS VARCHAR(50)),
                @Max_Spend = CAST(v.Maximum_Order_Value AS VARCHAR(50)),
                @Current_Value = CAST(i.Product_value AS VARCHAR(50))
            FROM inserted i
            JOIN VOUCHER v ON i.Voucher_code = v.Voucher_Code
            WHERE i.Product_value < v.Minimum_Order_Value 
               OR (v.Maximum_Order_Value > 0 AND i.Product_value > v.Maximum_Order_Value);

            RAISERROR ('Lỗi Nghiệp vụ (RB 15): Voucher %s yêu cầu đơn từ %s đến %s, nhưng giá trị hiện tại là %s.', 
                        16, 1, @Err_Voucher, @Min_Spend, @Max_Spend, @Current_Value);
            
            ROLLBACK TRANSACTION;
            RETURN;
        END
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
    @Shop_ID INT,
    @Start_date DATETIME,
    @End_date DATETIME
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
        AND o.Order_Date BETWEEN @Start_date AND @End_date
    ORDER BY 
        o.Order_Date DESC, o.Order_ID ASC; 
END;
GO

-- 4. THỦ TỤC 2
USE [QL_SHOPEE_BTL]
GO

IF OBJECT_ID('SP_Get_Potential_Vip_Users', 'P') IS NOT NULL
    DROP PROCEDURE SP_Get_Potential_Vip_Users;
GO

CREATE PROCEDURE SP_Get_Potential_Vip_Users
    @Year INT,                  -- Năm cần báo cáo
    @Min_Spending DECIMAL(15,2) -- Mức chi tiêu tối thiểu để được coi là VIP
AS
BEGIN
    SET NOCOUNT ON;


    -- [Ràng buộc 1]: Mức chi tiêu phải là số dương
    IF @Min_Spending <= 0
    BEGIN
        RAISERROR('Lỗi tham số: Mức chi tiêu tối thiểu (@Min_Spending) phải lớn hơn 0.', 16, 1);
        RETURN;
    END

    -- [Ràng buộc 2]: Năm báo cáo phải hợp lý (Từ 2015 đến hiện tại)
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    
    IF @Year < 2015 OR @Year > @CurrentYear
    BEGIN
        DECLARE @Err VARCHAR(200) = 'Lỗi tham số: Năm báo cáo (@Year) phải từ 2015 đến năm hiện tại (' + CAST(@CurrentYear AS VARCHAR) + ').';
        RAISERROR(@Err, 16, 1);
        RETURN;
    END
    
    SELECT 
        u.User_ID,
        u.Full_name,
        u.Email,
        COUNT(o.Order_ID) AS [Tong_So_Don],         -- 1. Aggregate Function (COUNT)
        SUM(o.Payed_value) AS [Tong_Chi_Tieu]       -- 1. Aggregate Function (SUM)
    FROM 
        [USER] u
    JOIN 
        ORDER_PAYMENT o ON u.User_ID = o.User_ID    -- 6. Liên kết 2 bảng trở lên ([USER] và ORDER_PAYMENT)
    WHERE 
        o.Order_Status = 'completed'                -- 4. WHERE
        AND YEAR(o.Order_Date) = @Year              -- 4. WHERE
    GROUP BY 
        u.User_ID, u.Full_name, u.Email             -- 2. GROUP BY
    HAVING 
        SUM(o.Payed_value) >= @Min_Spending         -- 3. HAVING
    ORDER BY 
        [Tong_Chi_Tieu] DESC;                       -- 5. ORDER BY
END;
GO