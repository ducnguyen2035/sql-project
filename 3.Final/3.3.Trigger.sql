-- ==============================================================================
USE [QL_SHOPEE_BTL]
GO
-- ==============================================================================
-- ===================================================
-- TRIGGERS
-- ===================================================
--trigger của quý
-- TRIGGER 1: Kiểm tra Tồn kho (SKU)
CREATE TRIGGER TR_Check_Stock_On_Insert
ON ORDER_ITEM
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Stock_Available INT;
    DECLARE @Quantity_Requested INT;
    DECLARE @Variant_ID_To_Check INT;
    DECLARE @Variant_Status VARCHAR(50);
    
    SELECT 
        @Quantity_Requested = i.Quantity,
        @Variant_ID_To_Check = i.Variant_ID,
        @Stock_Available = v.SKU, 
        @Variant_Status = v.Variant_Status
    FROM 
        inserted i
    JOIN 
        VARIANT v ON i.Variant_ID = v.Variant_ID;

    IF @Variant_Status = 'discontinued'
    BEGIN
        RAISERROR ('Error (RB 7): This product is discontinued and cannot be added to the order.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF @Stock_Available < @Quantity_Requested
    BEGIN
        RAISERROR ('Error (RB 5): Not enough stock available for this variant.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE VARIANT
    SET SKU = SKU - @Quantity_Requested
    WHERE Variant_ID = @Variant_ID_To_Check;

END;
GO

-- TRIGGER 2: Kiểm tra khi tạo Đơn hàng (User Status, Voucher)
CREATE TRIGGER TR_Check_Order_Creation
ON ORDER_PAYMENT
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @User_ID_To_Check INT;
    DECLARE @Account_Status VARCHAR(50);
    DECLARE @Voucher_Code_Used VARCHAR(50);
    DECLARE @Voucher_Quantity INT;
    DECLARE @Voucher_Start DATETIME;
    DECLARE @Voucher_End DATETIME;

    SELECT 
        @User_ID_To_Check = i.User_ID,
        @Voucher_Code_Used = i.Voucher_code
    FROM inserted i;

    SELECT @Account_Status = Account_status
    FROM [USER] 
    WHERE User_ID = @User_ID_To_Check;
    
    IF @Account_Status = 'restricted'
    BEGIN
        RAISERROR ('Error (RB 11): Your account is restricted and cannot create new orders.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Logic voucher ở bảng Payment_Voucher nên trigger này chỉ kiểm tra User
    -- Phần kiểm tra Voucher được xử lý ở bảng Payment_Voucher
END;
GO

-- TRIGGER 3: Cập nhật Trạng thái Đơn hàng khi Thanh toán thành công
CREATE TRIGGER TR_Update_Order_Status_On_Payment
ON ORDER_PAYMENT
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Payment_Status)
    BEGIN
        IF EXISTS (SELECT 1 FROM inserted i
                   JOIN deleted d ON i.Order_ID = d.Order_ID
                   WHERE d.Payment_Status != 'success' AND i.Payment_Status = 'success')
        BEGIN
            UPDATE ORDER_PAYMENT
            SET Order_Status = 'confirmed'
            WHERE Order_ID IN (SELECT Order_ID FROM inserted);
        END;
    END;
END;
GO

-- TRIGGER 4: Cập nhật Hạng thành viên khi đơn hàng Hoàn thành
CREATE TRIGGER TR_Update_Membership_On_Order_Complete
ON ORDER_PAYMENT
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @User_ID_To_Update INT;
    DECLARE @Payed_Value DECIMAL(10, 2);
    DECLARE @New_Total_Order INT;
    DECLARE @New_Total_Spending DECIMAL(12, 2);
    DECLARE @New_Tier_ID INT;

    IF EXISTS (SELECT 1 FROM inserted i
               JOIN deleted d ON i.Order_ID = d.Order_ID
               WHERE d.Order_Status != 'completed' AND i.Order_Status = 'completed')
    BEGIN
        
        SELECT @User_ID_To_Update = i.User_ID, @Payed_Value = i.Payed_value
        FROM inserted i;

        UPDATE CUSTOMER
        SET 
            Total_Order = Total_Order + 1,
            Total_Spending = Total_Spending + @Payed_Value
        WHERE User_ID = @User_ID_To_Update;

        SELECT 
            @New_Total_Order = Total_Order,
            @New_Total_Spending = Total_Spending
        FROM CUSTOMER
        WHERE User_ID = @User_ID_To_Update;

        SELECT TOP 1 @New_Tier_ID = Tier_ID
        FROM MEMBERSHIP_TIER
        WHERE 
            Min_orders_Per_half_year <= @New_Total_Order 
            AND Min_spend_Per_half_year <= @New_Total_Spending
        ORDER BY Min_spend_Per_half_year DESC, Min_orders_Per_half_year DESC;

        IF @New_Tier_ID IS NOT NULL
        BEGIN
            UPDATE CUSTOMER
            SET Tier_ID = @New_Tier_ID
            WHERE User_ID = @User_ID_To_Update;
        END;
    END;
END;
GO

-- TRIGGER 5: Kiểm tra Shopee Mall khi thêm/sửa sản phẩm
CREATE TRIGGER TR_Check_description_Product
ON PRODUCT
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SHOP_SELL s ON i.Shop_ID = s.Shop_ID
        WHERE 
            s.Shop_Type = 'Shopee Mall' 
            AND (i.Description IS NULL OR LTRIM(RTRIM(i.Description)) = '')
    )

    BEGIN
        RAISERROR ('Error (RB 8): Products listed on Shopee Mall must have a detailed description.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- TRIGGER 6: Ngăn tạo Vận đơn khi Đơn hàng đã hủy
CREATE TRIGGER TR_Check_Shipment_Creation
ON SHIPMENT_PACKAGE
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Order_Status VARCHAR(50);
    
    SELECT @Order_Status = o.Order_Status
    FROM ORDER_PAYMENT o
    JOIN inserted i ON i.Order_ID = o.Order_ID;

    IF @Order_Status = 'cancelled'
    BEGIN
        RAISERROR ('Error (RB 15): Cannot create a shipment for a cancelled order.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- TRIGGER 7: Xác thực Người mua khi viết Đánh giá
CREATE TRIGGER TR_Validate_Review_Creation
ON PRODUCT_REVIEW
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Customer_ID INT;
    DECLARE @Product_ID INT;
    DECLARE @Orders_Completed INT;

    SELECT @Customer_ID = i.User_ID, @Product_ID = i.P_ID
    FROM inserted i;

    SELECT @Orders_Completed = COUNT(DISTINCT op.Order_ID)
    FROM ORDER_PAYMENT op
    JOIN SHIPMENT_PACKAGE sp ON op.Order_ID = sp.Order_ID
    JOIN ORDER_ITEM oi ON sp.Shipment_ID = oi.Shipment_ID
    JOIN VARIANT v ON oi.Variant_ID = v.Variant_ID
    WHERE
        op.User_ID = @Customer_ID        
        AND v.P_ID = @Product_ID         
        AND op.Order_Status = 'completed';

    IF @Orders_Completed = 0
    BEGIN
        RAISERROR ('Error: You must purchase and complete an order for this product before you can review it.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
-- ===================================================
--trigger của tùng
-- TRIGGER 8: VOUCHER MINIMUM SPEND VALIDATION (Ràng buộc Nghiệp vụ)

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

-- TRIGGER 9: Update Product Rating

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