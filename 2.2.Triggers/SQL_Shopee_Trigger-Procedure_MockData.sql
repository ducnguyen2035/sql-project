
-- ===================================================
-- MOCK DATA FOR TESTING TRIGGERS & PROCEDURES
-- Minimal data needed to test your specific triggers and procedures
-- ===================================================
USE [QL_SHOPEE_BTL];
GO

-- ==============================================================================
-- CLEAR EXISTING DATA (in correct order to avoid FK violations)
-- ==============================================================================
PRINT 'Clearing existing data...';

-- Delete from junction/relationship tables first
DELETE FROM PRODUCT_CUSTOMER;
DELETE FROM SERVICE_PACKAGE_SHOP;
DELETE FROM VOUCHER_MEMBERSHIP_TIER;
DELETE FROM VOUCHER_CUSTOMER;
DELETE FROM VOUCHER_SHOP;
DELETE FROM PROMOTION_PROGRAM_PRODUCT;
DELETE FROM PROMOTION_PROGRAM_SHOP;
DELETE FROM MANAGEMENT_ENTITY_PROMOTION_PROGRAM;
DELETE FROM SERVICE_PROVIDER_MANAGEMENT_ENTITY;
DELETE FROM MANAGEMENT_ENTITY_SHIPPING_PROVIDER;

-- Delete from dependent tables
DELETE FROM PRODUCT_REVIEW;
DELETE FROM ORDER_ITEM;
DELETE FROM SHIPMENT_STATUS;
DELETE FROM ORDER_PACKAGE_TRIP;
DELETE FROM [TRIP];
DELETE FROM SHIPMENT_PACKAGE;
DELETE FROM PAYMENT_VOUCHER;
DELETE FROM ORDER_PAYMENT;
DELETE FROM VARIANT;
DELETE FROM PRODUCT;
DELETE FROM VOUCHER;
DELETE FROM PROMOTION_PROGRAM;
DELETE FROM SERVICE_PACKAGE;
DELETE FROM SERVICE_PROVIDER;
DELETE FROM CATEGORY_HIERARCHY;
DELETE FROM CATEGORY;
DELETE FROM SHOP_STAFF;
DELETE FROM SHOP_SELL;
DELETE FROM BANK_ACCOUNT;
DELETE FROM CUSTOMER;
DELETE FROM [USER];
DELETE FROM MEMBERSHIP_TIER;
DELETE FROM DRIVER;
DELETE FROM [POST];
DELETE FROM SHIPPING_PROVIDER;
DELETE FROM MANAGEMENT_ENTITY;

PRINT 'Data cleared successfully.';
PRINT '';

-- ==============================================================================
-- CORE DATA SETUP
-- ==============================================================================

-- 1. Management Entity (Required for User foreign key)
INSERT INTO MANAGEMENT_ENTITY VALUES
(1, '123 Main St, HCMC', '1900-1000', 'support@shopee.vn', 'Shopee Vietnam', 'Nguyen Van A', 'Vietnam', '2015-01-15');

-- 2. Membership Tiers (Required for Customer)
INSERT INTO MEMBERSHIP_TIER VALUES
(1, 'Standard', 0, 0, 0, 0),
(2, 'Silver', 5, 1000000, 2, 50000),
(3, 'Gold', 15, 5000000, 5, 200000),
(4, 'Diamond', 30, 15000000, 10, 500000);

-- 3. Users
INSERT INTO [USER] VALUES
-- Customers
(1, '079123001', '0901000001', 'buyer1@gmail.com', 'Nguyen Van Minh', 'Male', '1990-05-15', 'active', 1),
(2, '079123002', '0901000002', 'buyer2@gmail.com', 'Tran Thi Lan', 'Female', '1992-08-20', 'active', 1),
(3, '079123003', '0901000003', 'buyer3@gmail.com', 'Le Van Hoa', 'Male', '1988-03-10', 'restricted', 1),
-- Shop Owners
(4, '079123004', '0901000004', 'seller1@gmail.com', 'Pham Thi Mai', 'Female', '1985-11-25', 'active', 1),
(5, '079123005', '0901000005', 'seller2@gmail.com', 'Hoang Van Tuan', 'Male', '1987-07-18', 'active', 1);

-- 4. Customers
INSERT INTO CUSTOMER VALUES
(1, 5, 8000000, 2),    -- Silver tier
(2, 12, 4500000, 3),   -- Gold tier
(3, 0, 0, 1);          -- Standard tier (restricted account)

-- 5. Categories
INSERT INTO CATEGORY VALUES
(1, 'Electronics', NULL, 1),
(2, 'Fashion', NULL, 1),
(3, 'Smartphones', NULL, 2),
(4, 'Clothing', NULL, 2);

INSERT INTO CATEGORY_HIERARCHY VALUES (1, 3), (2, 4);

-- 6. Shops
INSERT INTO SHOP_SELL VALUES
(1, 'Tech World Store', 'Shopee Mall', 'Official tech store', 'active', NULL, 15000, 95.5, 
 '456 Tech St, District 1', '1234567890', 'tech@world.vn', '789 Warehouse', '0123456789', 'Electronics', 4),
(2, 'Fashion Paradise', 'preferred', 'Trendy fashion', 'active', NULL, 8500, 88.0, 
 '789 Fashion Ave, District 3', '0987654321', 'info@fashion.vn', '321 Stock', '9876543210', 'Clothing', 5);

-- 7. Products
INSERT INTO PRODUCT VALUES
(1, 'iPhone 15 Pro', 'Latest flagship phone', 29990000, 100, 4.8, NULL, 'for_sale', 3, 1),
(2, 'Samsung Galaxy S24', 'Premium Android phone', 24990000, 80, 4.7, NULL, 'for_sale', 3, 1),
(3, 'Nike T-Shirt', 'Premium cotton shirt', 450000, 200, 4.5, NULL, 'for_sale', 4, 2);

-- 8. Variants
INSERT INTO VARIANT VALUES
(1, '256GB', 'Blue', 'iPhone 15 Pro 256GB Blue', 29990000, 50, 'for_sale', NULL, 1),
(2, '512GB', 'Black', 'iPhone 15 Pro 512GB Black', 34990000, 30, 'for_sale', NULL, 1),
(3, '256GB', 'Black', 'Galaxy S24 256GB Black', 24990000, 40, 'for_sale', NULL, 2),
(4, 'Size L', 'Red', 'Nike T-Shirt L Red', 450000, 100, 'for_sale', NULL, 3),
(5, 'Size M', 'Blue', 'Nike T-Shirt M Blue', 450000, 50, 'for_sale', NULL, 3),
(6, '128GB', 'White', 'Galaxy S24 128GB White', 22990000, 35, 'for_sale', NULL, 2);

-- 9. Vouchers (for testing voucher validation trigger)
INSERT INTO PROMOTION_PROGRAM VALUES
(1, 'Electronics', 'Premium', '2024-01-01', '2024-12-31');


INSERT INTO VOUCHER VALUES
(1, 100, 'TECH500K', 'Platform', 'fixed', 5000000, 50000000, '2024-01-01', '2025-12-31', 1),
(2, 200, 'SAVE100K', 'Platform', 'fixed', 1000000, 10000000, '2024-01-01', '2025-12-31', 1);

INSERT INTO VOUCHER (Voucher_ID, Voucher_Code, Minimum_Order_Value, Quantity, Start_Date, Expiration_Date)
    VALUES (8888, 'TECHSALE', 5000000, 100, GETDATE()-1, GETDATE()+30);

-- Link vouchers to orders (for PAYMENT_VOUCHER table)
-- Note: We'll add this AFTER orders are created

-- ==============================================================================
-- TESTING DATA FOR PROCEDURES
-- ==============================================================================

-- Orders for Shop 1 (Tech World Store)
INSERT INTO ORDER_PAYMENT VALUES
-- Order 1: Completed with voucher (Oct 2024)
(1, '2024-10-15 10:30:00', 'TECH500K', '123 Nguyen Hue, District 1', 'completed', 1, 
 'Shopee Pay', 'success', 29540000, 29990000, 50000, 500000, 1),

-- Order 2: Completed without voucher (Oct 2024)
(2, '2024-10-20 14:20:00', NULL, '456 Le Loi, District 3', 'completed', 2, 
 'COD', 'success', 25040000, 24990000, 50000, 0, 2),

-- Order 3: Completed (Nov 2024)
(3, '2024-11-05 09:15:00', NULL, '789 Tran Hung Dao, District 5', 'completed', 3, 
 'Bank Transfer', 'success', 35040000, 34990000, 50000, 0, 1),

-- Order 4: Processing (for testing)
(4, '2024-11-10 16:00:00', NULL, '321 Vo Van Tan, District 3', 'processing', 4, 
 'Shopee Pay', 'processing', 22990000, 22990000, 0, 0, 2);

-- Orders for Shop 2 (Fashion Paradise)
INSERT INTO ORDER_PAYMENT VALUES
(5, '2024-10-18 11:00:00', NULL, '555 Hai Ba Trung, District 1', 'completed', 5, 
 'Credit Card', 'success', 500000, 450000, 50000, 0, 1);

-- Shipments
INSERT INTO SHIPMENT_PACKAGE VALUES
(1, 'SPX001234567', '2024-10-18 15:00:00', '2024-10-18 10:00:00', 1, 50000, 'successful delivery', NULL, 1, 1),
(2, 'JT002345678', '2024-10-23 16:30:00', '2024-10-23 10:00:00', 1, 50000, 'successful delivery', NULL, 2, 2),
(3, 'SPX003456789', '2024-11-08 14:00:00', '2024-11-08 09:00:00', 1, 50000, 'successful delivery', NULL, 3, 1),
(4, 'SPX004567890', NULL, '2024-11-12 10:00:00', 1, 0, 'successful delivery', NULL, 4, 2),
(5, 'GHN005678901', '2024-10-20 12:00:00', '2024-10-20 08:00:00', 2, 50000, 'successful delivery', NULL, 5, 1);

-- Order Items (each must use different Variant_ID due to UNIQUE constraint)
INSERT INTO ORDER_ITEM VALUES
(1, 29990000, 1, 29990000, 1, 1),
(2, 24990000, 1, 24990000, 2, 3),
(3, 34990000, 1, 34990000, 3, 2),
(4, 22990000, 1, 22990000, 4, 6),
(5, 450000, 1, 450000, 5, 4);

-- Shipment Status for completed orders
INSERT INTO SHIPMENT_STATUS VALUES
(1, 1, 'preparing', '2024-10-15 11:00:00', 'Tech World Warehouse'),
(1, 2, 'shipping', '2024-10-16 08:00:00', 'District 1 Hub'),
(1, 3, 'delivered', '2024-10-18 15:00:00', 'Customer Address'),
(2, 1, 'preparing', '2024-10-20 15:00:00', 'Tech World Warehouse'),
(2, 2, 'shipping', '2024-10-21 09:00:00', 'District 3 Hub'),
(2, 3, 'delivered', '2024-10-23 16:30:00', 'Customer Address'),
(3, 1, 'preparing', '2024-11-05 10:00:00', 'Tech World Warehouse'),
(3, 2, 'shipping', '2024-11-06 08:00:00', 'District 5 Hub'),
(3, 3, 'delivered', '2024-11-08 14:00:00', 'Customer Address');

-- Product Reviews (from customers who completed orders)
INSERT INTO PRODUCT_REVIEW VALUES
(1, '2024-10-19 10:00:00', NULL, 'Great phone, very fast!', 5, 1, 1),
(2, '2024-10-24 14:30:00', NULL, 'Good value for money', 4, 2, 2),
(3, '2024-11-09 09:00:00', NULL, 'Excellent product, highly recommended', 5, 1, 1);

-- Link vouchers to payment (PAYMENT_VOUCHER table)
INSERT INTO PAYMENT_VOUCHER VALUES
(1, 1);  -- Order 1 used TECH500K voucher

GO

IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 501)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (501, 'iPhone 15 Pro - Titanium Grey', 29990000, 100, 1, 'for_sale');

IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 502)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (502, 'iPhone 15 Pro - Gold Luxury', 32000000, 100, 1, 'for_sale');

-- Product 2: Samsung S24 (Shop 1)
IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 503)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (503, 'Samsung S24 - Cream', 24990000, 100, 2, 'for_sale');

-- [FIXED]: Tạo thêm Product mới cho Shop 1 (Thêm Description để thỏa mãn Trigger Shopee Mall)
IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE Product_ID = 88)
BEGIN
    INSERT INTO PRODUCT (Product_ID, Product_name, Base_Price, C_ID, Shop_ID, Average_Rating, Product_Status, Description)
    VALUES (88, 'AirPods Pro 2', 5000000, 1, 1, 5, 'for_sale', 'Tai nghe chong on chu dong, hang chinh hang Apple VN/A');

    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (504, 'AirPods Pro 2 - MagSafe', 5000000, 200, 88, 'for_sale');
END
DELETE FROM ORDER_ITEM WHERE Shipment_ID IN (7001, 7002, 7003, 7004);
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID IN (8001, 8002, 8003, 8004);
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (8001, 8002, 8003, 8004);

-- Đơn A: Mua iPhone Titanium (Variant 501) - Giá trị cao
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, User_ID)
VALUES (8001, '2024-10-05 09:00:00', 'HCM', 'completed', 8001, 'COD', 'success', 29990000, 29990000, 0, 1);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (7001, 8001, 'TRK-OCT-01', 'fast', 1, 0);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (6001, 7001, 501, 2, 29990000, 59980000); -- Mua 2 cái (Doanh thu ~60tr)


-- Đơn B: Mua iPhone Gold (Variant 502) - Giá trị rất cao
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, User_ID)
VALUES (8002, '2024-10-12 14:00:00', 'HN', 'completed', 8002, 'Bank Transfer', 'success', 32000000, 32000000, 0, 2);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (7002, 8002, 'TRK-OCT-02', 'standard', 2, 0);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (6002, 7002, 502, 1, 32000000, 32000000); -- Doanh thu 32tr


-- Đơn C: Mua Samsung Cream (Variant 503) - Giá trị trung bình
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, User_ID)
VALUES (8003, '2024-10-20 10:00:00', 'DN', 'completed', 8003, 'Shopee Pay', 'success', 24990000, 24990000, 0, 1);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (7003, 8003, 'TRK-OCT-03', 'economy', 1, 0);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (6003, 7003, 503, 1, 24990000, 24990000); -- Doanh thu ~25tr


-- Đơn D: Mua AirPods (Variant 504) - Mua sỉ số lượng lớn (10 cái)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, User_ID)
VALUES (8004, '2024-10-25 16:00:00', 'HCM', 'completed', 8004, 'Bank Transfer', 'success', 50000000, 50000000, 0, 2);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (7004, 8004, 'TRK-OCT-04', 'standard', 2, 0);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (6004, 7004, 504, 10, 5000000, 50000000); -- Doanh thu 50tr
-- ==============================================================================
-- TEST SCENARIOS
-- ==============================================================================


-- Sample test queries you can run:


-- Test 1: Try to create order with voucher but insufficient order value
DELETE FROM ORDER_PAYMENT WHERE Order_ID >= 99;
INSERT INTO ORDER_PAYMENT VALUES
(99, '2024-11-15 10:00:00', 'TECH500K', '999 Test St', 'processing', 99, 'Shopee Pay', 'processing', 450000, 450000, 50000, 50000, 1);
INSERT INTO ORDER_PAYMENT VALUES
(102, GETDATE(), 'TECH500K', 'Bach Khoa HCM', 'processing', 102, 'COD', 'processing', 500000, 550000, 50000, 100000, 1);
INSERT INTO ORDER_PAYMENT VALUES
(100, GETDATE(), 'TECHSALE', 'Test St', 'processing', 100, 'COD', 'processing', 5500000, 6000000, 0, 500000, 1);
INSERT INTO ORDER_PAYMENT VALUES
(101, GETDATE(), NULL, 'Test St', 'processing', 101, 'COD', 'processing', 100000, 100000, 0, 0, 1);
UPDATE ORDER_PAYMENT
SET Product_value = 100000, Payed_value = 100000 
WHERE Order_ID = 100;
-- Should fail: order value (450K) < minimum spend (5M)

-- Test 2: Check product rating update

SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

-- Xử lý đơn hàng 100 qua các bảng để thành success
DELETE FROM ORDER_ITEM WHERE Variant_ID = 1;
DELETE FROM ORDER_ITEM WHERE Shipment_ID IN (SELECT Shipment_ID FROM SHIPMENT_PACKAGE WHERE Order_ID = 100);
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID = 100;

UPDATE ORDER_PAYMENT 
SET Order_Status = 'completed', 
    Payment_Status = 'success'
WHERE Order_ID = 100
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID = 100; 
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (8100, 100, 'TRK-TEST-100', 'standard', 1, 0);
DELETE FROM ORDER_ITEM WHERE Shipment_ID = 8100;
INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (7100, 8100, 1, 1, 6000000, 6000000);

-- Tạo người mua tiếp để check
IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 2)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (2, 'iPhone 15 Pro - Backup', 29990000, 10, 1, 'for_sale');
DELETE FROM ORDER_ITEM WHERE Variant_ID = 2; -- Dọn dẹp cũ
DELETE FROM ORDER_PAYMENT WHERE Order_ID = 200;
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (200, GETDATE(), NULL, 'User 2 Address', 'completed', 200, 'COD', 'success', 29990000, 29990000, 0, 0, 2);
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (8200, 200, 'TRK-USER2', 'standard', 2, 0);
INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (7200, 8200, 2, 1, 29990000, 29990000);

INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (999, GETDATE(), NULL, 'Test Rating Order 100', 1, 1, 1);
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (1000, GETDATE(), NULL, 'Excellent!', 5, 1, 2);

UPDATE PRODUCT_REVIEW 
SET Rating_Star = 4, Comment = 'Changed my mind, it is good'
WHERE Review_ID = 999;
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 1000;

SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;
-- Rating should update automatically
-- Reset
DELETE FROM PRODUCT_REVIEW WHERE Review_ID IN (999, 1000);
DELETE FROM ORDER_ITEM WHERE Shipment_ID IN (
    SELECT Shipment_ID FROM SHIPMENT_PACKAGE WHERE Order_ID IN (100, 200)
);
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID IN (100, 200);
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (100, 200);
DELETE FROM VARIANT WHERE Variant_ID = 2;
-- Test 3: Get shop order history
SELECT 
    s.Shop_ID, s.Shop_name, o.Order_ID, o.Order_Date, u.Full_name AS [Nguoi_Mua], p.Product_name, v.Variant_Name AS [Phan_Loai], oi.Quantity AS [So_Luong], oi.Price_at_Purchase AS [Gia_Ban], (oi.Quantity * oi.Price_at_Purchase) AS [Tong_Tien_Mon], o.Order_Status AS [Trang_Thai_Don]
FROM 
    SHOP_SELL s
JOIN 
    PRODUCT p ON s.Shop_ID = p.Shop_ID
JOIN 
    VARIANT v ON p.Product_ID = v.P_ID
JOIN 
    ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
JOIN 
    SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
JOIN 
    ORDER_PAYMENT o ON sp.Order_ID = o.Order_ID
JOIN 
    [USER] u ON o.User_ID = u.User_ID
ORDER BY 
    s.Shop_ID ASC, 
    o.Order_Date DESC; 
GO

EXEC SP_Get_Shop_Order_History @Shop_ID = 1;

-- Test 4: Get top selling products report

-----------------------------------------
DECLARE @Test_Shop_ID INT = 1;
DECLARE @Test_Month INT = 10;
DECLARE @Test_Year INT = 2024;
SELECT 
    '1. ACTUAL SALES DATA (ALL)' AS [VIEW_MODE],
    p.Product_ID,
    p.Product_name,
    c.Category_name,
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
    p.Shop_ID = @Test_Shop_ID
    AND MONTH(o.Order_Date) = @Test_Month
    AND YEAR(o.Order_Date) = @Test_Year
    AND o.Order_Status = 'completed'
GROUP BY 
    p.Product_ID, p.Product_name, c.Category_name
ORDER BY 
    Total_Revenue DESC;

EXEC SP_Report_Top_Selling_Products @Shop_ID = 1, @Month = 10, @Year = 2024, @Min_Revenue = 200000000;

