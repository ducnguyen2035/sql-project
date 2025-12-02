
-- ===================================================
-- ===================================================
USE [QL_SHOPEE_BTL];
GO

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


-- ==============================================================================
-- TESTING DATA FOR PROCEDURES
-- ==============================================================================

-- Thêm dữ liệu vào order_payment để test
-- Shop 1
INSERT INTO ORDER_PAYMENT VALUES
(1, '2024-10-15 10:30:00', 'TECH500K', '123 Nguyen Hue, District 1', 'completed', 1, 
 'Shopee Pay', 'success', 29540000, 29990000, 50000, 500000, 1),
(2, '2024-10-20 14:20:00', NULL, '456 Le Loi, District 3', 'completed', 2, 
 'COD', 'success', 25040000, 24990000, 50000, 0, 2),
(3, '2024-11-05 09:15:00', NULL, '789 Tran Hung Dao, District 5', 'completed', 3, 
 'Bank Transfer', 'success', 35040000, 34990000, 50000, 0, 1),
(4, '2024-11-10 16:00:00', NULL, '321 Vo Van Tan, District 3', 'processing', 4, 
 'Shopee Pay', 'processing', 22990000, 22990000, 0, 0, 2);

-- Shop 2
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

-- Product Reviews
INSERT INTO PRODUCT_REVIEW VALUES
(1, '2024-10-19 10:00:00', NULL, 'Great phone, very fast!', 5, 1, 1),
(2, '2024-10-24 14:30:00', NULL, 'Good value for money', 4, 2, 2),
(3, '2024-11-09 09:00:00', NULL, 'Excellent product, highly recommended', 5, 1, 1);

-- Vouchers
INSERT INTO PAYMENT_VOUCHER VALUES
(1, 1); 

-- Data test procedure
IF NOT EXISTS (SELECT 1 FROM [USER] WHERE User_ID IN (801, 802, 803))
BEGIN
    INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Entity_ID, Account_status) VALUES
    (801, 'ID801', '0980101010', 'vip@test.com', 'Nguyen Van Dai Gia', 1, 'active'),
    (802, 'ID802', '0980202020', 'normal@test.com', 'Tran Van Trung Luu', 1, 'active'),
    (803, 'ID803', '0980303030', 'tiny@test.com', 'Le Van Tieu Gia', 1, 'active');
END

-- 2. Tạo Đơn hàng năm 2025 (Chỉ cần tạo Payment là đủ để test procedure này)
DELETE FROM ORDER_PAYMENT WHERE User_ID IN (801, 802, 803);

-- User 801: Mua đơn 50 Triệu
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Order_Status, Payment_ID, Payment_Method, Payment_Status, Address, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9901, '2025-05-01', 'completed', 9901, 'Bank Transfer', 'success', 'Villa Quan 7', 50000000, 50000000, 0, 0, 801);

-- User 802: Mua đơn 10 Triệu
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Order_Status, Payment_ID, Payment_Method, Payment_Status, Address, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9902, '2025-06-01', 'completed', 9902, 'Shopee Pay', 'success', 'Chung cu Quan 2', 10000000, 10000000, 0, 0, 802);

-- User 803: Mua đơn 500k
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Order_Status, Payment_ID, Payment_Method, Payment_Status, Address, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9903, '2025-07-01', 'completed', 9903, 'COD', 'success', 'Phong tro Go Vap', 500000, 500000, 0, 0, 803);

GO


