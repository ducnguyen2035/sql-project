-- ===================================================
-- DATA INSERT SCRIPT
-- ===================================================

USE [QL_SHOPEE_BTL];
GO

-- ===================================================
-- CLEANUP
-- ===================================================
PRINT '--- STARTING CLEANUP ---';
ALTER TABLE ORDER_ITEM NOCHECK CONSTRAINT ALL;
ALTER TABLE SHIPMENT_PACKAGE NOCHECK CONSTRAINT ALL;
ALTER TABLE PRODUCT_REVIEW NOCHECK CONSTRAINT ALL;
ALTER TABLE ORDER_PAYMENT NOCHECK CONSTRAINT ALL;

DELETE FROM SHIPMENT_STATUS;
DELETE FROM ORDER_PACKAGE_TRIP;
DELETE FROM ORDER_ITEM;
DELETE FROM SHIPMENT_PACKAGE;
DELETE FROM PAYMENT_VOUCHER;
DELETE FROM ORDER_PAYMENT;
DELETE FROM PRODUCT_REVIEW;
DELETE FROM VARIANT;
DELETE FROM PRODUCT_CUSTOMER;
DELETE FROM VOUCHER_CUSTOMER;
DELETE FROM VOUCHER_MEMBERSHIP_TIER;
DELETE FROM VOUCHER_SHOP;
DELETE FROM VOUCHER;
DELETE FROM PROMOTION_PROGRAM_PRODUCT;
DELETE FROM PROMOTION_PROGRAM_SHOP;
DELETE FROM PROMOTION_PROGRAM;
DELETE FROM PRODUCT;
DELETE FROM CATEGORY_HIERARCHY;
DELETE FROM CATEGORY;
DELETE FROM [TRIP];
DELETE FROM DRIVER;
DELETE FROM [POST];
DELETE FROM SERVICE_PACKAGE_SHOP;
DELETE FROM SERVICE_PACKAGE;
DELETE FROM MANAGEMENT_ENTITY_SHIPPING_PROVIDER;
DELETE FROM SHIPPING_PROVIDER;
DELETE FROM SERVICE_PROVIDER_MANAGEMENT_ENTITY;
DELETE FROM SERVICE_PROVIDER;
DELETE FROM SHOP_STAFF;
DELETE FROM SHOP_SELL;
DELETE FROM CUSTOMER;
DELETE FROM MEMBERSHIP_TIER;
DELETE FROM BANK_ACCOUNT;
DELETE FROM [USER];
DELETE FROM MANAGEMENT_ENTITY;

ALTER TABLE ORDER_ITEM CHECK CONSTRAINT ALL;
ALTER TABLE SHIPMENT_PACKAGE CHECK CONSTRAINT ALL;
ALTER TABLE PRODUCT_REVIEW CHECK CONSTRAINT ALL;
ALTER TABLE ORDER_PAYMENT CHECK CONSTRAINT ALL;
PRINT '--- CLEANUP COMPLETE ---';
GO

-- ===================================================
-- 1. MASTER DATA (ENTITY, CATEGORY, PROVIDERS)
-- ===================================================

-- 1.1 MANAGEMENT_ENTITY (5 rows)
INSERT INTO MANAGEMENT_ENTITY (Entity_ID, Address, Hotline, Email, Entity_Name, Director, Nation, Established_Date) VALUES
(1, 'Saigon Centre, Q1, HCMC', '19001221', 'legal.vn@shopee.com', 'Shopee Vietnam', 'Tran Tuan Anh', 'Vietnam', '2015-08-08'),
(2, 'Galaxis, Solaris, Singapore', '65677788', 'legal.sg@shopee.com', 'Shopee Regional HQ', 'Chris Feng', 'Singapore', '2015-01-01'),
(3, 'Jakarta, Indonesia', '62215555', 'legal.id@shopee.com', 'Shopee Indonesia', 'Handhika Jahja', 'Indonesia', '2015-12-01'),
(4, 'Bangkok, Thailand', '66201788', 'legal.th@shopee.com', 'Shopee Thailand', 'Terence Pang', 'Thailand', '2015-12-01'),
(5, 'Manila, Philippines', '63288805', 'legal.ph@shopee.com', 'Shopee Philippines', 'Martin Yu', 'Philippines', '2015-12-01');

-- 1.2 CATEGORY (5 rows)
INSERT INTO CATEGORY (Category_ID, Category_name, Category_Image, [Level]) VALUES
(1, 'Electronics', 0x01, 1),
(2, 'Fashion', 0x02, 1),
(3, 'Home & Living', 0x03, 1),
(4, 'Health & Beauty', 0x04, 1),
(5, 'Books & Stationery', 0x05, 1);

-- 1.3 SHIPPING_PROVIDER (5 rows)
INSERT INTO SHIPPING_PROVIDER (Provider_ID, Provider_Name, Coverage_Area, Weight_Limit, Size_Limit, Delivery_Method) VALUES
(1, 'SPX Express', 'Nationwide', 50.00, '100x100x100', 'standard'),
(2, 'Giao Hang Nhanh', 'Nationwide', 30.00, '80x80x80', 'fast'),
(3, 'J&T Express', 'Nationwide', 50.00, '120x120x120', 'economy'),
(4, 'GrabExpress', 'Urban Only', 20.00, '50x50x50', 'instant'),
(5, 'Ninja Van', 'Rural Support', 40.00, '90x90x90', 'standard');

-- 1.4 SERVICE_PROVIDER (5 rows)
INSERT INTO SERVICE_PROVIDER (Provider_ID, Provider_Name, Service_Type, Contact_Info) VALUES
(1, 'Shopee Marketing', 'Ads', 'ads@shopee.com'),
(2, 'Shopee Logistics', 'Fulfillment', 'logistics@shopee.com'),
(3, 'Shopee Pay', 'Payment Gateway', 'pay@shopee.com'),
(4, 'Google Ads Partner', 'External Ads', 'ads@google.com'),
(5, 'Facebook Ads Partner', 'External Ads', 'ads@meta.com');

-- 1.5 MEMBERSHIP_TIER (4 rows - MAX allowed by CHECK constraint)
INSERT INTO MEMBERSHIP_TIER (Tier_ID, Tier, Min_orders_Per_half_year, Min_spend_Per_half_year, Discount_Rate, Benefit) VALUES
(1, 'Standard', 0, 0, 0, 0),
(2, 'Silver', 3, 1000000, 0.02, 10000), 
(3, 'Gold', 20, 5000000, 0.05, 25000),
(4, 'Diamond', 75, 15000000, 0.10, 50000);

-- ===================================================
-- 2. USERS & ACTORS
-- ===================================================

-- 2.1 USER (15 rows: Buyers, Sellers, Staff)
INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID) VALUES
-- Buyers (101-105)
(101, '001099000001', '0901000001', 'nguyenvana@mail.com', 'Nguyen Van A', 'Male', '1999-01-01', 'active', 1),
(102, '001099000002', '0901000002', 'tranthib@mail.com', 'Tran Thi B', 'Female', '1998-02-02', 'active', 1),
(103, '001099000003', '0901000003', 'levanc@mail.com', 'Le Van C', 'Male', '1997-03-03', 'warning', 1),
(104, '001099000004', '0901000004', 'phamthid@mail.com', 'Pham Thi D', 'Female', '1996-04-04', 'active', 1),
(105, '001099000005', '0901000005', 'hoangvane@mail.com', 'Hoang Van E', 'Male', '1995-05-05', 'active', 1),
-- Sellers (201-205)
(201, '001088000001', '0902000001', 'shopowner1@mail.com', 'Doan Van Chu', 'Male', '1988-01-01', 'active', 1),
(202, '001088000002', '0902000002', 'shopowner2@mail.com', 'Le Thi Chu', 'Female', '1989-02-02', 'active', 1),
(203, '001088000003', '0902000003', 'nguyenvanbuon@mail.com', 'Nguyen Van Buon', 'Male', '1990-03-03', 'active', 1),
(204, '001088000004', '0902000004', 'tranthiban@mail.com', 'Tran Thi Ban', 'Female', '1991-04-04', 'active', 1),
(205, '001088000005', '0902000005', 'phamvanloi@mail.com', 'Pham Van Loi', 'Male', '1992-05-05', 'active', 1),
-- Shop Staff (301-305)
(301, '001095000001', '0903000001', 'staff1@shop.com', 'Nhan Vien Mot', 'Male', '2000-01-01', 'active', 1),
(302, '001095000002', '0903000002', 'staff2@shop.com', 'Nhan Vien Hai', 'Female', '2000-02-02', 'active', 1),
(303, '001095000003', '0903000003', 'staff3@shop.com', 'Nhan Vien Ba', 'Male', '2000-03-03', 'active', 1),
(304, '001095000004', '0903000004', 'staff4@shop.com', 'Nhan Vien Bon', 'Female', '2000-04-04', 'active', 1),
(305, '001095000005', '0903000005', 'staff5@shop.com', 'Nhan Vien Nam', 'Male', '2000-05-05', 'active', 1);

-- 2.2 CUSTOMER (5 rows)
INSERT INTO CUSTOMER (User_ID, Total_Order, Total_Spending, Tier_ID) VALUES
(101, 25, 6000000, 3), -- Gold
(102, 80, 20000000, 4), -- Diamond
(103, 1, 150000, 1),    -- Standard
(104, 5, 2000000, 2),   -- Silver
(105, 10, 4500000, 2);  -- Silver

-- 2.3 BANK_ACCOUNT (5 rows)
INSERT INTO BANK_ACCOUNT (Bank_account, User_ID) VALUES
('190311111111', 101),
('190322222222', 102),
('190333333333', 201),
('190344444444', 202),
('190355555555', 203);

-- ===================================================
-- 3. SHOPS & PRODUCTS
-- ===================================================

-- 3.1 SHOP_SELL (5 rows)
INSERT INTO SHOP_SELL (Shop_ID, Shop_name, Shop_type, Description, Operation_Status, Logo, Follower, Chat_response_rate, Address, Bank_Account, Email_for_Online_Bills, Stock_address, Tax_code, Type_of_Business, User_ID) VALUES
(501, 'Apple Flagship Store', 'Shopee Mall', 'Official Apple Reseller', 'active', NULL, 150000, 99.00, 'District 1, HCMC', '190333333333', 'billing@apple.vn', 'Warehouse A', 'TAX001', 'Company', 201),
(502, 'Samsung Official', 'Shopee Mall', 'Official Samsung Store', 'active', NULL, 120000, 98.00, 'Cau Giay, Hanoi', '190344444444', 'billing@samsung.vn', 'Warehouse B', 'TAX002', 'Company', 202),
(503, 'Cool Mate', 'preferred', 'Mens Fashion', 'active', NULL, 50000, 95.00, 'Tan Binh, HCMC', '190355555555', 'bill@coolmate.me', 'Warehouse C', 'TAX003', 'Company', 203),
(504, 'Hieu Sach Nhan Van', 'normal', 'Books and Stationery', 'active', NULL, 5000, 85.00, 'District 10, HCMC', '190366666666', 'nhanvan@book.com', 'Warehouse D', 'TAX004', 'Individual', 204),
(505, 'Maybelline NY', 'Shopee Mall', 'Cosmetics', 'active', NULL, 200000, 97.00, 'Ba Dinh, Hanoi', '190377777777', 'billing@maybelline.vn', 'Warehouse E', 'TAX005', 'Company', 205);

-- 3.2 SHOP_STAFF (5 rows)
INSERT INTO SHOP_STAFF ([User_ID], [Role], [Shop_ID]) VALUES
(301, 'manager', 501),
(302, 'staff', 501),
(303, 'manager', 502),
(304, 'staff', 503),
(305, 'staff', 505);

-- 3.3 PRODUCT (5 rows)
INSERT INTO PRODUCT (Product_ID, Product_name, Description, Base_Price, Total_Sales, Average_Rating, Base_Image, Product_Status, C_ID, Shop_ID) VALUES
(1001, 'iPhone 15 Pro Max', 'Titanium Design', 30000000, 100, 5.0, NULL, 'for_sale', 1, 501),
(1002, 'Samsung Galaxy S24', 'AI Phone', 25000000, 50, 4.8, NULL, 'for_sale', 1, 502),
(1003, 'Ao Thun Nam Basic', '100% Cotton', 150000, 200, 4.5, NULL, 'for_sale', 2, 503),
(1004, 'Dac Nhan Tam', 'Best Seller Book', 80000, 500, 4.9, NULL, 'for_sale', 5, 504),
(1005, 'Son Kem Maybelline', 'Super Stay Matte Ink', 180000, 1000, 4.7, NULL, 'for_sale', 4, 505);

-- 3.4 VARIANT (10 rows - 2 variants per product)
INSERT INTO VARIANT (Variant_ID, Option_Value_1, Option_Value_2, Variant_Name, Price, SKU, Variant_Status, Variant_Image, P_ID) VALUES
(2001, 'Natural Titanium', '256GB', 'iPhone 15 PM Nat 256', 30000000, 50, 'for_sale', NULL, 1001),
(2002, 'Blue Titanium', '512GB', 'iPhone 15 PM Blue 512', 35000000, 20, 'for_sale', NULL, 1001),
(2003, 'Black', '256GB', 'S24 Black', 25000000, 30, 'for_sale', NULL, 1002),
(2004, 'Yellow', '256GB', 'S24 Yellow', 25000000, 30, 'for_sale', NULL, 1002),
(2005, 'Black', 'L', 'T-Shirt Black L', 150000, 100, 'for_sale', NULL, 1003),
(2006, 'White', 'M', 'T-Shirt White M', 150000, 100, 'for_sale', NULL, 1003),
(2007, 'Standard', NULL, 'Sach Bia Mem', 80000, 50, 'for_sale', NULL, 1004),
(2008, 'Limited', NULL, 'Sach Bia Cung', 120000, 10, 'for_sale', NULL, 1004),
(2009, 'Red 115', NULL, 'Son Mau Do', 180000, 200, 'for_sale', NULL, 1005),
(2010, 'Pink 120', NULL, 'Son Mau Hong', 180000, 200, 'for_sale', NULL, 1005);

-- ===================================================
-- 4. LOGISTICS & SERVICES
-- ===================================================

-- 4.1 POST (5 rows)
INSERT INTO [POST] (Post_Code, Region, Address, Hotline, Provider_ID) VALUES
('SPX-HCM', 'Ho Chi Minh', 'Kho Cu Chi, HCM', '19001111', 1),
('SPX-HN', 'Ha Noi', 'Kho Gia Lam, HN', '19002222', 1),
('GHN-DN', 'Da Nang', 'Kho Lien Chieu, DN', '19003333', 2),
('JNT-CT', 'Can Tho', 'Kho Cai Rang, CT', '19004444', 3),
('NJV-HP', 'Hai Phong', 'Kho Hai An, HP', '19005555', 5);

-- 4.2 DRIVER (5 rows)
INSERT INTO DRIVER (Staff_ID, Full_Name, ID_Number, Driver_License, Provider_ID, Driver_Type, Truck_ID, Route_Assigned, Max_weight) VALUES
(601, 'Tai Xe A', '001090000001', 'FC-001', 1, 'Truck', 101, 'HCM-HN', 5000),
(602, 'Tai Xe B', '001090000002', 'FC-002', 1, 'Truck', 102, 'HCM-DN', 5000),
(603, 'Shipper C', '001090000003', 'A1-001', 1, 'Shipper', NULL, 'District 1', 50),
(604, 'Shipper D', '001090000004', 'A1-002', 2, 'Shipper', NULL, 'District 3', 50),
(605, 'Shipper E', '001090000005', 'A1-003', 4, 'Shipper', NULL, 'Ba Dinh', 30);

-- 4.3 TRIP (5 rows)
INSERT INTO [TRIP] (Staff_ID, Trip_ID, Arrival_Time, Departure_Time, Arrival_post_code, Departure_post_code) VALUES
(601, 1, '2025-11-20 08:00:00', '2025-11-18 08:00:00', 'SPX-HN', 'SPX-HCM'),
(601, 2, '2025-11-23 08:00:00', '2025-11-21 08:00:00', 'SPX-HCM', 'SPX-HN'),
(602, 3, '2025-11-20 12:00:00', '2025-11-19 12:00:00', 'GHN-DN', 'SPX-HCM'),
(604, 4, '2025-11-20 09:00:00', '2025-11-20 08:00:00', 'SPX-HCM', 'SPX-HCM'), -- Noi thanh
(605, 5, '2025-11-20 10:00:00', '2025-11-20 09:00:00', 'SPX-HN', 'SPX-HN');

-- 4.4 SERVICE_PACKAGE (5 rows)
INSERT INTO SERVICE_PACKAGE (Package_Name, Service_Cost, Duration, Benefit, Provider_ID) VALUES
('Goi Quang Cao Co Ban', 500000, '30 days', 0, 1),
('Goi Quang Cao Nang Cao', 2000000, '30 days', 0, 1),
('Freeship Xtra', 1000000, '30 days', 50, 2),
('Hoan Xu Xtra', 1500000, '30 days', 100, 2),
('Flash Sale Slot', 200000, '1 day', 0, 1);

-- ===================================================
-- 5. PROMOTION & VOUCHERS
-- ===================================================

-- 5.1 PROMOTION_PROGRAM (5 rows)
INSERT INTO PROMOTION_PROGRAM (Program_ID, Categories_Apply, Promotion_tier, Start_Date, End_Date) VALUES
(1, 'All', 'Tet Sale', '2025-01-01', '2025-01-30'),
(2, 'Electronics', 'Tech Day', '2025-03-03', '2025-03-03'),
(3, 'Fashion', 'Summer Sale', '2025-06-06', '2025-06-30'),
(4, 'All', '9.9 Super Sale', '2025-09-09', '2025-09-09'),
(5, 'All', '11.11 Big Sale', '2025-11-11', '2025-11-11');

-- 5.2 VOUCHER (5 rows)
INSERT INTO VOUCHER (Voucher_ID, Quantity, Voucher_Code, Voucher_Type, Discount_Type, Minimum_Order_Value, Maximum_Order_Value, Start_Date, Expiration_Date, Program_ID) VALUES
(1, 1000, 'TET2025', 'Platform', 'percent', 200000, 50000, '2025-01-01', '2025-01-30', 1),
(2, 500, 'TECH50K', 'Shop', 'fixed', 1000000, 50000, '2025-03-03', '2025-03-03', 2),
(3, 2000, 'FREESHIP', 'Shipping', 'fixed', 0, 30000, '2025-01-01', '2025-12-31', 1),
(4, 100, 'VIPDIAMOND', 'Platform', 'percent', 1000000, 500000, '2025-11-11', '2025-11-11', 5),
(5, 50, 'SHOPNEW', 'Shop', 'fixed', 50000, 10000, '2025-01-01', '2025-12-31', 1);

-- ===================================================
-- 6. TRANSACTIONS (ORDERS - SHIPMENTS - ITEMS)
-- ===================================================
-- Creating 5 COMPLETED orders to enable 5 Reviews
-- Creating mixed orders for diversity

-- ORDER 1: User 101 buys iPhone (Completed)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9001, '2025-10-01', NULL, 'Home 101', 'completed', 10001, 'Shopee Pay', 'success', 30015000, 30000000, 15000, 0, 101);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8001, 'SPX001', '2025-10-03', '2025-10-04', 1, 15000, 'successful delivery', NULL, 9001, 101);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7001, 30000000, 1, 30000000, 8001, 2001);

-- ORDER 2: User 102 buys Samsung (Completed)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9002, '2025-10-02', NULL, 'Home 102', 'completed', 10002, 'COD', 'success', 25015000, 25000000, 15000, 0, 102);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8002, 'SPX002', '2025-10-05', '2025-10-06', 1, 15000, 'successful delivery', NULL, 9002, 102);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7002, 25000000, 1, 25000000, 8002, 2003);

-- ORDER 3: User 101 buys T-Shirt (Completed)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9003, '2025-10-05', NULL, 'Home 101', 'completed', 10003, 'Shopee Pay', 'success', 165000, 150000, 15000, 0, 101);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8003, 'GHN001', '2025-10-08', '2025-10-08', 1, 15000, 'successful delivery', NULL, 9003, 101);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7003, 150000, 1, 150000, 8003, 2005);

-- ORDER 4: User 104 buys Book (Completed)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9004, '2025-10-06', NULL, 'Home 104', 'completed', 10004, 'COD', 'success', 95000, 80000, 15000, 0, 104);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8004, 'JNT001', '2025-10-09', '2025-10-09', 1, 15000, 'successful delivery', NULL, 9004, 104);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7004, 80000, 1, 80000, 8004, 2007);

-- ORDER 5: User 105 buys Lipstick (Completed)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9005, '2025-10-07', NULL, 'Home 105', 'completed', 10005, 'Shopee Pay', 'success', 195000, 180000, 15000, 0, 105);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8005, 'NJV001', '2025-10-10', '2025-10-11', 1, 15000, 'successful delivery', NULL, 9005, 105);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7005, 180000, 1, 180000, 8005, 2009);

-- ORDER 6: Order in Processing (No Shipment yet)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9006, GETDATE(), NULL, 'Home 102', 'processing', 10006, 'COD', 'processing', 30015000, 30000000, 15000, 0, 102);

-- ===================================================
-- 7. POST-SALE (REVIEWS & TRACKING)
-- ===================================================

-- 7.1 SHIPMENT_STATUS (5 rows)
INSERT INTO SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location) VALUES
(8001, 1, 'delivered', '2025-10-03 10:00:00', 'Home 101'),
(8002, 1, 'delivered', '2025-10-05 14:00:00', 'Home 102'),
(8003, 1, 'delivered', '2025-10-08 09:00:00', 'Home 101'),
(8004, 1, 'delivered', '2025-10-09 16:00:00', 'Home 104'),
(8005, 1, 'delivered', '2025-10-10 11:00:00', 'Home 105');

-- 7.2 PRODUCT_REVIEW (5 rows - Must match Completed Orders)
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID) VALUES
(1, GETDATE(), NULL, 'Dien thoai xin, muot.', 5, 1001, 101), -- From Order 9001
(2, GETDATE(), NULL, 'Man hinh dep, AI hay.', 5, 1002, 102), -- From Order 9002
(3, GETDATE(), NULL, 'Vai mac thoang mat.', 4, 1003, 101), -- From Order 9003
(4, GETDATE(), NULL, 'Sach hay, giao nhanh.', 5, 1004, 104), -- From Order 9004
(5, GETDATE(), NULL, 'Son li, lau troi.', 5, 1005, 105); -- From Order 9005

-- 7.3 ORDER_PACKAGE_TRIP (5 rows)
INSERT INTO ORDER_PACKAGE_TRIP (Shipment_ID, Staff_ID, Trip_ID) VALUES
(8001, 601, 1),
(8002, 601, 1),
(8003, 602, 3),
(8004, 604, 4),
(8005, 601, 2);

-- ===================================================
-- 8. JUNCTION TABLES (M-N)
-- ===================================================

-- 8.1 CATEGORY_HIERARCHY (5 rows)
INSERT INTO CATEGORY_HIERARCHY (Parent_Category_ID, Sub_Category_ID) VALUES 
(1, 4), -- Electronics -> Health/Beauty 
(2, 5), -- Fashion -> Books 
(1, 2), -- Demo hierarchy
(1, 3), 
(1, 5);

-- 8.2 MANAGEMENT_ENTITY_SHIPPING_PROVIDER (5 rows)
INSERT INTO MANAGEMENT_ENTITY_SHIPPING_PROVIDER (ShProvider_ID, Entity_ID) VALUES (1, 1), (2, 1), (3, 1), (4, 1), (5, 1);

-- 8.3 PROMOTION_PROGRAM_SHOP (5 rows)
INSERT INTO PROMOTION_PROGRAM_SHOP (Shop_ID, Program_ID) VALUES (501, 1), (502, 1), (503, 1), (504, 1), (505, 1);

-- 8.4 VOUCHER_SHOP (5 rows)
INSERT INTO VOUCHER_SHOP (Voucher_ID, Shop_ID) VALUES (2, 501), (2, 502), (5, 503), (5, 504), (5, 505);

-- 8.5 PRODUCT_CUSTOMER (Wishlist - 5 rows)
INSERT INTO PRODUCT_CUSTOMER (Product_ID, User_ID) VALUES (1001, 102), (1001, 103), (1002, 101), (1003, 105), (1005, 104);

PRINT '--- ALL DATA INSERTED SUCCESSFULLY ---';
GO
