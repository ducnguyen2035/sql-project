USE [QL_SHOPEE_BTL];
GO



-- ==============================================================================
-- PART 1: TEST TRIGGER "TRG_Validate_Voucher_Min_Spend"
-- Logic: Should block if Product_value < Voucher.Minimum_Order_Value
-- ==============================================================================
PRINT '';
PRINT '>>> Part 1: Testing Voucher Minimum Spend Trigger...';

-- Prep: Clear old test data
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (8881, 8882);

-- CASE 1.1: VALID INSERT
PRINT '  + Case 1.1: Trying to insert a valid order (Value: 6M vs Voucher Req: 5M)...';
BEGIN TRY
    INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Product_value, Payed_value, Order_Status, Payment_Status, User_ID, Payment_ID, Payment_Method, Shipment_value, Voucher_value)
    VALUES (8881, GETDATE(), 'TECHSALE', 6000000, 5500000, 'processing', 'processing', 101, 8881, 'COD', 0, 500000);
    PRINT '    -> Trigger Doing well';
END TRY
BEGIN CATCH
    PRINT '    -> Trigger Fail ' + ERROR_MESSAGE();
END CATCH;

-- CASE 1.2: INVALID INSERT (Should be blocked)
PRINT '  + Case 1.2: Trying to insert an invalid order (Value: 1M vs Voucher Req: 5M)...';
BEGIN TRY
    INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Product_value, Payed_value, Order_Status, Payment_Status, User_ID, Payment_ID, Payment_Method, Shipment_value, Voucher_value)
    VALUES (8882, GETDATE(), 'TECHSALE', 1000000, 500000, 'processing', 'processing', 101, 8882, 'COD', 0, 500000);
    PRINT '    -> Trigger Fail.';
END TRY
BEGIN CATCH
    PRINT '    -> Trigger Doing well ' + ERROR_MESSAGE();
END CATCH;

-- CASE 1.3: INVALID UPDATE (Should be blocked)
PRINT '  + Case 1.3: Trying to update Order 8881 value down to 4M (Violation)...';
BEGIN TRY
    -- Logic: Reducing Product Value to 4M. Voucher takes off 500k -> Payed must be 3.5M
    -- We update Payed_value too, so the Check Constraint doesn't complain before the Trigger runs.
    UPDATE ORDER_PAYMENT 
    SET Product_value = 4000000, 
        Payed_value = 3500000 
    WHERE Order_ID = 8881;
    PRINT '    -> Weird... The trigger let this update pass.';
END TRY
BEGIN CATCH
    PRINT '    -> Great! The trigger blocked the update. Message: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ==============================================================================
-- PART 2: TEST TRIGGER "TRG_Update_Product_Rating"
-- Logic: Auto-calculate Average_Rating when reviews change
-- ==============================================================================
PRINT '';
PRINT '>>> Part 2: Testing Auto-Rating Trigger...';

-- Prep: Create new Variant & Order to ensure clean data (No Unique Key errors)
IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 9999)
INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
VALUES (9999, 'Test Rating Variant', 100000, 100, 1004, 'for_sale'); -- 1004 is Serum

IF NOT EXISTS (SELECT 1 FROM ORDER_PAYMENT WHERE Order_ID = 9999)
BEGIN
    INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, User_ID, Order_Status, Payment_ID, Payment_Method, Payment_Status, Product_value, Payed_value)
    VALUES (9999, GETDATE(), 101, 'completed', 9999, 'COD', 'success', 100000, 100000);
    
    INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
    VALUES (9999, 9999, 'TEST-RATE-2', 'standard', 101, 0);

    INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
    VALUES (9999, 9999, 9999, 1, 100000, 100000);
END

-- Check original rating
DECLARE @Rating DECIMAL(3,2);
SELECT @Rating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '  + Original Rating for Product 1004: ' + CAST(ISNULL(@Rating, 0) AS VARCHAR);

-- CASE 2.1: ADD 1-STAR REVIEW
PRINT '  + Case 2.1: Adding a 1-star review...';
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 999; -- Cleanup if exists

INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Rating_Star, P_ID, User_ID, Comment)
VALUES (999, GETDATE(), 1, 1004, 101, 'Test Rating Fix');

SELECT @Rating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '    -> New Rating (should drop): ' + CAST(@Rating AS VARCHAR);

-- CASE 2.2: UPDATE TO 5 STARS
PRINT '  + Case 2.2: Changing that review to 5 stars...';
UPDATE PRODUCT_REVIEW SET Rating_Star = 5 WHERE Review_ID = 999;

SELECT @Rating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '    -> New Rating (should rise): ' + CAST(@Rating AS VARCHAR);

-- CASE 2.3: DELETE REVIEW
PRINT '  + Case 2.3: Deleting the review...';
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 999;

SELECT @Rating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '    -> Final Rating (should return to original): ' + CAST(@Rating AS VARCHAR);
GO


-- ==============================================================================
-- PART 3: TEST PROCEDURE "SP_Get_Shop_Order_History"
-- ==============================================================================
PRINT '';
PRINT '>>> Part 3: Testing Shop Order History Procedure...';

PRINT '  + Fetching history for Shop 501 (Year 2025)...';

EXEC SP_Get_Shop_Order_History 
    @Shop_ID = 501, 
    @StartDate = '2025-01-01', 
    @EndDate = '2025-12-31';

PRINT '  -> Please check the first result table below. It should show orders for Shop 501.';
GO


-- ==============================================================================
-- PART 4: TEST PROCEDURE "SP_Report_Top_Selling_Products"
-- ==============================================================================
PRINT '';
PRINT '>>> Part 4: Testing Sales Report Procedure...';

-- CASE 4.1: GET ALL
PRINT '  + Case 4.1: Report for Nov 2025 (Min Revenue = 0)...';
EXEC SP_Report_Top_Selling_Products 
    @Shop_ID = 501, 
    @Month = 11, 
    @Year = 2025, 
    @Min_Revenue = 0;

-- CASE 4.2: FILTER HIGH REVENUE
PRINT '  + Case 4.2: Report for Nov 2025 (Min Revenue = 1 Billion)...';
EXEC SP_Report_Top_Selling_Products 
    @Shop_ID = 501, 
    @Month = 11, 
    @Year = 2025, 
    @Min_Revenue = 1000000000;

PRINT '  -> Note: The second result table should be empty.';
GO

PRINT '';
PRINT '========================================================================';
PRINT '   TEST SCRIPT COMPLETED';
PRINT '========================================================================';