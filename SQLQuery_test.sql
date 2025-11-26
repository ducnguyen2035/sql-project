USE [QL_SHOPEE_BTL];
GO

PRINT '>>> STARTING TEST SUITE (FINAL VERSION) <<<';
PRINT '--------------------------------------------------';

-- ===========================================================
-- 1. TEST TRIGGER: VOUCHER MIN SPEND VALIDATION
-- ===========================================================
PRINT '--- [TEST 1] TRIGGER: VALIDATE MIN SPEND ---';

DELETE FROM PRODUCT_REVIEW WHERE P_ID IN (SELECT Product_ID FROM PRODUCT); 
DELETE FROM ORDER_ITEM WHERE Shipment_ID = 8999;
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID = 9999;
DELETE FROM ORDER_PAYMENT WHERE Order_ID = 9999;

INSERT INTO ORDER_PAYMENT (Order_ID, User_ID, Voucher_Code, Order_Status, Order_date, Address, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, Payment_ID)
VALUES (9999, 101, 'TECHSALE', 'processing', GETDATE(), 'Test Address', 'COD', 'processing', 0, 0, 0, 0, 19999);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Customer_ID, Shipment_type, Group_ID)
VALUES (8999, 9999, 101, 'standard', 1);

-- B3: Perform VIOLATION (Insert item worth 150k, expecting block)
BEGIN TRY
    INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase)
    VALUES (7999, 8999, 2002, 1, 150000); -- T-shirt 150k
    
    PRINT 'RESULT: FAILURE (Trigger did not block the invalid insert!)';
END TRY
BEGIN CATCH
    PRINT 'RESULT: SUCCESS. Trigger blocked transaction with error:';
    PRINT '   -> ' + ERROR_MESSAGE();
END CATCH;
GO


-- ===========================================================
-- 2. TEST TRIGGER: AUTO UPDATE RATING (Derived Attribute)
-- ===========================================================
PRINT ' ';
PRINT '[TEST 2] TRIGGER: AUTO UPDATE PRODUCT RATING';

-- B1: Get current rating of Product 1004 (Vitamin C)
DECLARE @OldRating DECIMAL(3,1);
SELECT @OldRating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '   + Initial Rating: ' + ISNULL(CAST(@OldRating AS VARCHAR), 'NULL');

DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 999;
DELETE FROM ORDER_ITEM WHERE Order_Item_ID = 7888;
DELETE FROM SHIPMENT_PACKAGE WHERE Shipment_ID = 8888;
DELETE FROM ORDER_PAYMENT WHERE Order_ID = 9888;

-- B3: Simulate successful purchase
INSERT INTO ORDER_PAYMENT (Order_ID, User_ID, Order_Status, Order_date, Address, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, Payment_ID) 
VALUES (9888, 101, 'completed', GETDATE(), 'Test Addr', 'COD', 'success', 0, 0, 0, 0, 19888);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Customer_ID, Shipment_type, Group_ID) 
VALUES (8888, 9888, 101, 'standard', 1);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase) 
VALUES (7888, 8888, 2005, 1, 300000); -- Insert item for Product 1004

-- B4: Insert a 1-star review
INSERT INTO PRODUCT_REVIEW (Review_ID, User_ID, P_ID, Rating_Star, Review_Date)
VALUES (999, 101, 1004, 1, GETDATE());

DECLARE @NewRating DECIMAL(3,1);
SELECT @NewRating = Average_Rating FROM PRODUCT WHERE Product_ID = 1004;
PRINT '   + New Rating after 1-star review: ' + CAST(@NewRating AS VARCHAR);

IF @NewRating <> @OldRating
    PRINT 'RESULT: SUCCESS (Rating was automatically updated)';
ELSE
    PRINT 'RESULT: FAILURE (Rating remained unchanged)';

DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 999;
DELETE FROM ORDER_ITEM WHERE Order_Item_ID = 7888;
DELETE FROM SHIPMENT_PACKAGE WHERE Shipment_ID = 8888;
DELETE FROM ORDER_PAYMENT WHERE Order_ID = 9888;
GO

-- ===========================================================
-- 3. TEST STORED PROCEDURES (Reporting Functionality)
-- ===========================================================
PRINT ' ';
PRINT '=== [TEST 3] PROCEDURE: SHOP ORDER HISTORY ===';
-- Tests: SP_Get_Shop_Order_History
EXEC SP_Get_Shop_Order_History 
    @Shop_ID = 501, 
    @StartDate = '2025-11-01', 
    @EndDate = '2025-11-30';
GO

PRINT ' ';
PRINT '=== [TEST 4] PROCEDURE: BEST SELLERS REPORT ===';
-- Tests: SP_Report_Top_Selling_Products
EXEC SP_Report_Top_Selling_Products 
    @Shop_ID = 501, 
    @Month = 11, 
    @Year = 2025, 
    @Min_Revenue = 0;
GO