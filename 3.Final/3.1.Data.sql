-- ===================================================
-- INSERT SCRIPT (FIXED & MATCHED WITH NEW SCHEMA)
-- ===================================================

USE [QL_SHOPEE_BTL];
GO
-- Dữ liệu mẫu của Quý 

-- ===================================================
-- CLEANUP SCRIPT
-- ===================================================

PRINT '--- STARTING DATABASE CLEANUP ---';
GO

DELETE FROM ORDER_PACKAGE_TRIP;
DELETE FROM SHIPMENT_STATUS;
DELETE FROM ORDER_ITEM;
DELETE FROM SHIPMENT_PACKAGE;
DELETE FROM ORDER_PAYMENT;
DELETE FROM PRODUCT_REVIEW;
DELETE FROM VARIANT;
DELETE FROM PRODUCT_CUSTOMER;
DELETE FROM PROMOTION_PROGRAM_PRODUCT;
DELETE FROM PRODUCT;
DELETE FROM CATEGORY_HIERARCHY;
DELETE FROM CATEGORY;
DELETE FROM [TRIP];
DELETE FROM DRIVER;
DELETE FROM [POST];
DELETE FROM MANAGEMENT_ENTITY_SHIPPING_PROVIDER;
DELETE FROM SHIPPING_PROVIDER;
DELETE FROM VOUCHER_CUSTOMER;
DELETE FROM VOUCHER_MEMBERSHIP_TIER;
DELETE FROM VOUCHER_SHOP;
DELETE FROM VOUCHER;
DELETE FROM PROMOTION_PROGRAM_SHOP;
DELETE FROM MANAGEMENT_ENTITY_PROMOTION_PROGRAM;
DELETE FROM PROMOTION_PROGRAM;
DELETE FROM SERVICE_PACKAGE_SHOP;
DELETE FROM SERVICE_PACKAGE;
DELETE FROM SERVICE_PROVIDER_MANAGEMENT_ENTITY;
DELETE FROM SERVICE_PROVIDER;
DELETE FROM SHOP_STAFF;
DELETE FROM SHOP_SELL;
DELETE FROM CUSTOMER;
DELETE FROM MEMBERSHIP_TIER;
DELETE FROM BANK_ACCOUNT;
DELETE FROM [USER];
DELETE FROM MANAGEMENT_ENTITY;
GO

PRINT '--- CLEANUP COMPLETE. STARTING DATA INSERT ---';
GO

-- ===================================================
-- INSERT SCRIPT - NEW DATA
-- ===================================================

-- STAGE 1: CREATE BASE DATA
-- 1. MANAGEMENT_ENTITY
INSERT INTO MANAGEMENT_ENTITY (Entity_ID, Address, Hotline, Email, Entity_Name, Director, Nation, Established_Date) 
VALUES
(1, '28F, Saigon Centre Tower 2, 67 Le Loi, Ben Nghe, D1, HCMC', '19001221', 'support@shopee.vn', 'Shopee Vietnam Ltd', 'Mr. Chris Feng', 'Vietnam', '2015-01-01');
GO

-- 2. CATEGORY
INSERT INTO CATEGORY (Category_ID, Category_name, Category_Image, [Level]) 
VALUES
(1, 'Electronics', NULL, 1),
(2, 'Fashion', NULL, 1),
(3, 'Home & Living', NULL, 1),
(4, 'Health & Beauty', NULL, 1),
(5, 'Mobile Phones', NULL, 2); 
GO

-- 3. SHIPPING_PROVIDER
INSERT INTO SHIPPING_PROVIDER (Provider_ID, Provider_Name, Coverage_Area, Weight_Limit, Size_Limit, Delivery_Method) 
VALUES
(1,'Lalamove', 'Nationwide', 50, '100x100x100', 'standard'),
(2,'Ahamove', 'Nationwide', 30, '80x80x80', 'economy'),
(3,'Ahamove', 'Nationwide', 30, '80x80x80', 'fast'),
(4,'Lalamove', 'Nationwide', 50, '120x120x120', 'standard'),
(5,'Ahamove', 'HCMC/Hanoi Internal', 20, '50x50x50', 'instant');
GO

-- 4. SERVICE_PROVIDER
INSERT INTO SERVICE_PROVIDER (Provider_ID, Provider_Name, Service_Type, Contact_Info) 
VALUES
(1, 'Shopee Ads Service', 'Advertising', 'ads@shopee.vn'),
(2, 'Freeship Xtra Provider', 'Logistics Package', 'freeship@shopee.vn'),
(3, 'Voucher Xtra Provider', 'Promotion Package', 'voucher@shopee.vn'),
(4, 'Shopee Pay Gateway', 'Payment', 'payment@shopee.vn'),
(5, 'Marketing Solutions Inc', 'External Marketing', 'contact@mkt.com');
GO

-- 5. MEMBERSHIP_TIER
INSERT INTO MEMBERSHIP_TIER (Tier_ID, Tier, Min_orders_Per_half_year, Min_spend_Per_half_year, Discount_Rate, Benefit) 
VALUES
(1, 'Standard', 0, 0, 0, 0),
(2, 'Silver', 3, 1000000, 0, 10), 
(3, 'Gold', 20, 5000000, 0, 20),
(4, 'Diamond', 75, 15000000, 0, 50);
GO
PRINT 'Stage 1 Complete: 5 base tables populated.';
GO

-- STAGE 2: DEPENDENT ENTITIES
-- 6. [USER]
INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
VALUES
(101, '001099001111', '0909123456', 'nguyenvana@gmail.com', 'Nguyen Van A', 'Male', '1999-01-15', 'active', 1),
(102, '001098002222', '0909234567', 'tranthib@gmail.com', 'Tran Thi B', 'Female', '1998-05-20', 'active', 1),
(103, '001097003333', '0909345678', 'levanc@gmail.com', 'Le Van C', 'Male', '1997-11-30', 'restricted', 1),
(201, '001088004444', '0808111222', 'phamthid@shop.com', 'Pham Thi D', 'Female', '1988-02-10', 'active', 1),
(202, '001087005555', '0808333444', 'dangvane@shop.com', 'Dang Van E', 'Male', '1987-07-07', 'active', 1);
GO

-- 7. [POST]
INSERT INTO [POST] (Post_Code, Region, Address, Hotline, Provider_ID)
VALUES
('SPX-HCM-Q1', 'Ho Chi Minh', '123 Le Loi, Q1, HCM', '19001221', 1), 
('GHTK-HN-BD', 'Ha Noi', '456 Ba Dinh, Hanoi', '1900636677', 2), 
('GHN-DN-HC', 'Da Nang', '789 Hai Chau, Da Nang', '1900636688', 3), 
('JNT-HCM-Q7', 'Ho Chi Minh', '321 Nguyen Thi Thap, Q7, HCM', '19001088', 4), 
('GRAB-HN-CG', 'Ha Noi', '654 Cau Giay, Hanoi', '02871098588', 5); 
GO

-- 8. SERVICE_PACKAGE
INSERT INTO SERVICE_PACKAGE (Package_Name, Service_Cost, Duration, Benefit, Provider_ID)
VALUES
('Shopee Ads - Keyword', 500000, '30 days', 0, 1),
('Freeship Xtra', 1000000, '30 days', 50, 2),
('Voucher Xtra', 1000000, '30 days', 100, 3),
('ShopeePay Discount', 0, 'N/A', 5, 4),
('Facebook Ads Campaign', 2000000, '14 days', 0, 5);
GO

-- 9. PROMOTION_PROGRAM
INSERT INTO PROMOTION_PROGRAM (Program_ID, Categories_Apply, Promotion_tier, Start_Date, End_Date)
VALUES
(1, 'All', '12.12 Flash Sale', '2025-12-12 00:00:00', '2025-12-12 23:59:59'),
(2, 'Electronics', 'Tech Super Sale', '2025-11-01 00:00:00', '2025-11-20 23:59:59'), 
(3, 'Fashion', 'Fashion Week', '2025-11-01 00:00:00', '2025-11-27 23:59:59'), 
(4, 'Home & Living', 'Home Sale', '2025-11-25 00:00:00', '2025-11-30 23:59:59'),
(5, 'All', 'Black Friday', '2025-11-28 00:00:00', '2025-11-28 23:59:59');
GO

-- STAGE 3: SPECIALIZED ROLES AND SHOPS
-- 10. CUSTOMER
INSERT INTO CUSTOMER (User_ID, Total_Order, Total_Spending, Tier_ID)
VALUES
(101, 25, 6000000, 3), 
(102, 1, 500000, 1),  
(103, 5, 2000000, 2);  
GO

-- 11. SHOP_SELL
INSERT INTO SHOP_SELL (Shop_ID, Shop_name, Shop_type, Description, Operation_Status, Logo, Follower, Chat_response_rate, Address, Bank_Account, Email_for_Online_Bills, Stock_address, Tax_code, Type_of_Business, User_ID)
VALUES
(501, 'The Official Mall', 'Shopee Mall', 'Genuine products.', 'active', NULL, 15000, 98.5, '123 Le Loi, Q1, HCM', '0123456789', 'mall@shop.com', 'Warehouse A, Q7, HCM', 'TAX001', 'Company', 201),
(502, 'Preferred Plus Shop', 'preferred', 'Quality items.', 'active', NULL, 8000, 95.0, '456 Hai Ba Trung, Q3, HCM', '9876543210', 'preferred@shop.com', 'Warehouse B, Q9, HCM', 'TAX002', 'Individual', 202);
GO

-- 13. BANK_ACCOUNT
INSERT INTO BANK_ACCOUNT (Bank_account, User_ID)
VALUES
('111122223333', 101),
('444455556666', 101),
('777788889999', 102),
('012345678910', 201),
('109876543210', 202);
GO

-- STAGE 4: STAFF SPECIALIZATION, PRODUCTS, VOUCHERS
-- 14. Add 3 new Users to act as Staff
INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
VALUES
(104, '001096006666', '0909456789', 'staff1@shop.com', 'Staff Member 1', 'Female', '2000-01-01', 'active', 1),
(105, '001095007777', '0909567890', 'staff2@shop.com', 'Staff Member 2', 'Male', '2001-02-02', 'active', 1),
(106, '001094008888', '0909678901', 'staff3@shop.com', 'Staff Member 3', 'Female', '2002-03-03', 'active', 1);
GO

-- 15. SHOP_STAFF
INSERT INTO SHOP_STAFF ([User_ID], [Role], [Shop_ID])
VALUES
(201, 'super_admin', 501),
(202, 'super_admin', 502),
(104, 'manager', 501),      
(105, 'staff', 501),       
(106, 'staff', 502);       
GO

-- 16. DRIVER
INSERT INTO DRIVER (Staff_ID,Full_Name,ID_Number,Driver_License,Provider_ID, Driver_Type, Truck_ID, Route_Assigned, Max_weight)
VALUES
(301, 10,'Nguyen Van A' ,null,1,'Shipper',  null, 'Route HCM-HN', 2000),
(302, 11,'Doan Thi B'   ,null,2,'Truck',    null, 'Route HCM-DN', 1500),
(303, 12,'Tran Quoc C'  ,null,3,'Shipper',  null, 'Route HN-DN' , 1500);
GO
-- 17. PRODUCT
INSERT INTO PRODUCT (Product_ID, Product_name, Description, Base_Price, Total_Sales, Average_Rating, Base_Image, Product_Status, C_ID, Shop_ID)
VALUES
(1001, 'Smartphone Model X', 'Latest generation smartphone.', 10000000, 0, 0, '3.Final/Image/iphone-x-64gb.jpg' , 'for_sale', 5, 501),
(1002, 'Mens T-Shirt', '100% Cotton T-Shirt.', 150000, 0, 0, '3.Final/Image/Tshirt.jpg', 'for_sale', 2, 502),
(1003, 'Luxury Sofa', 'High-quality leather sofa.', 5000000, 0, 0, '3.Final/Image/sofa_luxury.jpg', 'for_sale', 3, 501),
(1004, 'Vitamin C Serum', 'Skincare serum for beauty.', 300000, 0, 0, '3.Final/Image/serum-vitamin-c-han-quoc.jpg', 'for_sale', 4, 502),
(1005, 'Laptop Pro', 'High-end laptop for professionals.', 25000000, 0, 0, '3.Final/Image/macbook_pro.jpg', 'discontinued', 1, 501);
GO

-- 18. VOUCHER
INSERT INTO VOUCHER (Voucher_ID, Quantity, Voucher_Code, Voucher_Type, Discount_Type, Minimum_Order_Value, Maximum_Order_Value, Start_Date, Expiration_Date, Program_ID)
VALUES
(1, 100, 'SALE1212', 'Platform', 'percent', 100000, 500000, '2025-12-12 00:00:00', '2025-12-12 23:59:59', 1),
(2, 50, 'TECHSALE', 'Shop', 'fixed', 5000000, 10000000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 2),
(3, 500, 'FASHION20K', 'Shop', 'fixed', 150000, 200000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 3),
(4, 10, 'EXPIREDVOUCHER', 'Platform', 'fixed', 0, 100000, '2020-01-01 00:00:00', '2020-01-02 23:59:59', 5),
(5, 0, 'OUTOFSTOCK', 'Shipping', 'fixed', 0, 150000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 5);
GO

-- STAGE 5: CREATE PRODUCT DETAILS (VARIANTS)
INSERT INTO VARIANT (Variant_ID, Option_Value_1, Option_Value_2, Variant_Name, Price, SKU, Variant_Status, Variant_Image, P_ID)
VALUES
(2001, 'Black', '128GB', 'Smartphone X (Black, 128GB)', 10000000, 100, 'for_sale', NULL, 1001),
(2002, 'White', '256GB', 'Smartphone X (White, 256GB)', 11000000, 50, 'for_sale', NULL, 1001),
(2003, 'Red', 'L', 'Mens T-Shirt (Red, L)', 150000, 100, 'for_sale', NULL, 1002),
(2004, 'Blue', 'M', 'Mens T-Shirt (Blue, M)', 150000, 2, 'for_sale', NULL, 1002),
(2005, '30ml', NULL, 'Vitamin C Serum (30ml)', 300000, 100, 'for_sale', NULL, 1004),
(2006, '16-inch', 'Silver', 'Laptop Pro (16-inch, Silver)', 25000000, 10, 'discontinued', NULL, 1005);
GO

-- STAGE 6: CREATE TRANSACTION SCENARIOS (ORDERS)

-- SCENARIO 1: Successful Order
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9001, GETDATE(), 'TECHSALE', '123 Nguyen Trai, Q1, HCM', 'processing', 10001, 'Credit Card', 'processing', 9015000, 10000000, 15000, 1000000, 101);
GO
-- [FIXED]: Removed Provider_ID, Changed type to 'successful delivery'
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8001, 'SPX0001', NULL, '2025-11-20', 1, 15000, 'successful delivery', NULL, 9001, 101);
GO
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7001, 10000000, 2, 9000000, 8001, 2001);
GO

-- SCENARIO 2: Successful Order
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9002, GETDATE(), 'FASHION20K', '456 Le Lai, Q4, HCM', 'processing', 10002, 'Shopee Pay', 'processing', 295000, 300000, 15000, 20000, 102);
GO
-- [FIXED]: Removed Provider_ID, Changed type to 'successful delivery'
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8002, 'SPX0002', NULL, '2025-11-25', 1, 15000, 'successful delivery', NULL, 9002, 102);
GO
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7002, 150000, 1, 140000, 8002, 2003);
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7003, 150000, 1,  150000, 8002, 2004);
GO

-- SCENARIO 3: "Completed" Order
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9004, '2025-11-01 10:00:00', NULL, '123 Nguyen Trai, Q1, HCM', 'completed', 10004, 'COD', 'success', 320000, 300000, 20000, 0, 101);
GO
-- [FIXED]: Removed Provider_ID, Changed type to 'successful delivery'
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8004, 'SPX0004', '2025-11-03 12:00:00', '2025-11-03', 1, 20000, 'successful delivery', NULL, 9004, 101);
GO
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7004, 300000, 1, 300000, 8004, 2005);
GO

-- STAGE 7: OPERATIONS, POST-SALE, & REVIEW TESTS
-- 23. [TRIP]
INSERT INTO [TRIP] (Staff_ID, Trip_ID, Arrival_Time, Departure_Time, Arrival_post_code, Departure_post_code)
VALUES
(301, 1, '2025-11-19 08:00:00', '2025-11-18 08:00:00', 'GHTK-HN-BD', 'SPX-HCM-Q1'),
(301, 2, '2025-11-21 08:00:00', '2025-11-20 08:00:00', 'SPX-HCM-Q1', 'GHTK-HN-BD'),
(302, 3, '2025-11-23 12:00:00', '2025-11-22 12:00:00', 'GHN-DN-HC', 'SPX-HCM-Q1'),
(303, 4, '2025-11-24 10:00:00', '2025-11-23 10:00:00', 'GHN-DN-HC', 'GHTK-HN-BD'),
(301, 5, '2025-11-25 08:00:00', '2025-11-24 08:00:00', 'GHTK-HN-BD', 'SPX-HCM-Q1');
GO

-- 24. SHIPMENT_STATUS
INSERT INTO SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location)
VALUES
(8001, 1, 'preparing', '2025-11-18 11:00:00', 'Shop 501 Warehouse'),
(8001, 2, 'shipping', '2025-11-18 15:00:00', 'SPX-HCM-Q1'),
(8002, 1, 'preparing', '2025-11-22 12:00:00', 'Shop 502 Warehouse'),
(8002, 2, 'shipping', '2025-11-22 16:00:00', 'GHTK-HN-BD'),
(8004, 1, 'delivered', '2025-11-03 12:00:00', 'Customer Address'); 
GO

-- 25. PRODUCT_REVIEW
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
VALUES
(1, GETDATE(), NULL, 'Good product, fast delivery.', 5, 1004, 101);
GO

-- STAGE 8: POPULATE M-N LINKING TABLES
-- 26. CATEGORY_HIERARCHY
INSERT INTO CATEGORY_HIERARCHY (Parent_Category_ID, Sub_Category_ID)
VALUES
(1, 5); 
GO
-- 27. ORDER_PACKAGE_TRIP
INSERT INTO ORDER_PACKAGE_TRIP (Shipment_ID, Staff_ID, Trip_ID)
VALUES
(8001, 301, 1), 
(8002, 302, 3); 
GO
-- 28. REMAINING M-N TABLES
INSERT INTO MANAGEMENT_ENTITY_SHIPPING_PROVIDER (ShProvider_ID, Entity_ID) VALUES (1, 1), (2, 1), (3, 1), (4, 1), (5, 1);
GO
INSERT INTO SERVICE_PROVIDER_MANAGEMENT_ENTITY (Provider_ID, Entity_ID) VALUES (1, 1), (2, 1), (3, 1), (4, 1), (5, 1);
GO
INSERT INTO MANAGEMENT_ENTITY_PROMOTION_PROGRAM (Entity_ID, Program_ID) VALUES (1, 1), (1, 2), (1, 3), (1, 4), (1, 5);
GO
INSERT INTO PROMOTION_PROGRAM_SHOP (Shop_ID, Program_ID) VALUES (501, 2), (501, 5), (502, 3), (502, 5);
GO
INSERT INTO PROMOTION_PROGRAM_PRODUCT (Product_ID, Program_ID) VALUES (1001, 2), (1001, 5), (1002, 3), (1005, 2);
GO
INSERT INTO VOUCHER_SHOP (Voucher_ID, Shop_ID) VALUES (2, 501), (3, 502);
GO
INSERT INTO VOUCHER_CUSTOMER (Voucher_ID, User_ID) VALUES (2, 101), (3, 101), (3, 102);
GO
INSERT INTO VOUCHER_MEMBERSHIP_TIER (Voucher_ID, Tier_ID) VALUES (2, 3), (2, 4), (3, 1), (3, 2), (3, 3);
GO
INSERT INTO PRODUCT_CUSTOMER (Product_ID, User_ID) VALUES (1001, 101), (1002, 102), (1004, 101), (1004, 102);
GO
INSERT INTO SERVICE_PACKAGE_SHOP (Package_Name, Shop_ID) VALUES ('Freeship Xtra', 501), ('Freeship Xtra', 502), ('Voucher Xtra', 501);
GO


-- ==============================================================================
-- CORE DATA SETUP
-- 

-- ===================================================
-- DỮ LIỆU BỔ SUNG CHO HÀM
-- ===================================================
--Data của dũng
-- 1. THÊM CATEGORY

INSERT INTO CATEGORY (Category_ID, Category_name, Category_Image, [Level]) 
VALUES
(6, 'Sports & Outdoors', NULL, 1),
(7, 'Books & Media', NULL, 1),
(8, 'Toys & Games', NULL, 1),
(9, 'Automotive', NULL, 1),
(10, 'Pet Supplies', NULL, 1),
(11, 'Laptops', NULL, 2),        -- Sub of Electronics
(12, 'Headphones', NULL, 2),     -- Sub of Electronics
(13, 'Womens Fashion', NULL, 2), -- Sub of Fashion
(14, 'Skincare', NULL, 2),       -- Sub of Health & Beauty
(15, 'Furniture', NULL, 2);      -- Sub of Home & Living
GO

INSERT INTO CATEGORY_HIERARCHY (Parent_Category_ID, Sub_Category_ID)
VALUES
(1, 11), -- Electronics -> Laptops
(1, 12), -- Electronics -> Headphones
(2, 13), -- Fashion -> Womens Fashion
(4, 14), -- Health & Beauty -> Skincare
(3, 15); -- Home & Living -> Furniture
GO

PRINT '✓ Đã thêm 10 categories mới';
GO

-- 2. THÊM USER VÀ CUSTOMER

INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
VALUES
(107, '001093009991', '0909111111', 'customer1@gmail.com', 'Le Thi H', 'Female', '1995-01-10', 'active', 1),
(108, '001092009992', '0909222222', 'customer2@gmail.com', 'Pham Van I', 'Male', '1996-02-15', 'active', 1),
(109, '001091009993', '0909333333', 'customer3@gmail.com', 'Hoang Thi K', 'Female', '1997-03-20', 'active', 1),
(110, '001090009994', '0909444444', 'customer4@gmail.com', 'Nguyen Van L', 'Male', '1998-04-25', 'active', 1),
(111, '001089009995', '0909555555', 'customer5@gmail.com', 'Tran Thi M', 'Female', '1999-05-30', 'active', 1),
(112, '001088009996', '0909666666', 'customer6@gmail.com', 'Vo Van N', 'Male', '2000-06-05', 'active', 1),
(113, '001087009997', '0909777777', 'customer7@gmail.com', 'Do Thi O', 'Female', '1994-07-10', 'active', 1),
(114, '001086009998', '0909888888', 'customer8@gmail.com', 'Bui Van P', 'Male', '1993-08-15', 'active', 1),
(115, '001085009999', '0909999999', 'customer9@gmail.com', 'Dang Thi Q', 'Female', '1992-09-20', 'active', 1),
(116, '001084009900', '0908111111', 'customer10@gmail.com', 'Ngo Van R', 'Male', '1991-10-25', 'active', 1),
(117, '001083009901', '0908222222', 'customer11@gmail.com', 'Mai Thi S', 'Female', '1990-11-30', 'active', 1),
(118, '001082009902', '0908333333', 'customer12@gmail.com', 'Ha Van T', 'Male', '1989-12-05', 'active', 1);
GO

INSERT INTO CUSTOMER (User_ID, Total_Order, Total_Spending, Tier_ID)
VALUES
(107, 5, 2500000, 2),   -- Silver
(108, 10, 4000000, 2),  -- Silver
(109, 2, 800000, 1),    -- Standard
(110, 15, 7000000, 3),  -- Gold
(111, 3, 1500000, 1),   -- Standard
(112, 8, 3500000, 2),   -- Silver
(113, 1, 500000, 1),    -- Standard
(114, 12, 5500000, 3),  -- Gold
(115, 0, 0, 1),         -- Standard (chưa mua gì)
(116, 4, 2000000, 1),   -- Standard
(117, 6, 3000000, 2),   -- Silver
(118, 20, 8000000, 3);  -- Gold
GO

PRINT '✓ Đã thêm 12 customers mới';
GO

-- 3. THÊM SHOP

INSERT INTO [USER] (User_ID, ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
VALUES
(203, '001081009903', '0808777777', 'shop3@shop.com', 'Shop Owner 3', 'Male', '1985-01-01', 'active', 1),
(204, '001080009904', '0808888888', 'shop4@shop.com', 'Shop Owner 4', 'Female', '1986-02-02', 'active', 1),
(205, '001079009905', '0808999999', 'shop5@shop.com', 'Shop Owner 5', 'Male', '1987-03-03', 'active', 1),
(206, '001078009906', '0807111111', 'shop6@shop.com', 'Shop Owner 6', 'Female', '1988-04-04', 'active', 1),
(207, '001077009907', '0807222222', 'shop7@shop.com', 'Shop Owner 7', 'Male', '1989-05-05', 'active', 1),
(208, '001076009908', '0807333333', 'shop8@shop.com', 'Shop Owner 8', 'Female', '1990-06-06', 'active', 1),
(209, '001075009909', '0807444444', 'shop9@shop.com', 'Shop Owner 9', 'Male', '1991-07-07', 'active', 1),
(210, '001074009910', '0807555555', 'shop10@shop.com', 'Shop Owner 10', 'Female', '1992-08-08', 'active', 1);
GO

INSERT INTO SHOP_SELL (Shop_ID, Shop_name, Shop_type, Description, Operation_Status, Logo, Follower, Chat_response_rate, Address, Bank_Account, Email_for_Online_Bills, Stock_address, Tax_code, Type_of_Business, User_ID)
VALUES
(503, 'Tech Paradise', 'normal', 'Best tech products.', 'active', NULL, 5000, 92.0, '111 Tech St, Q1, HCM', '1231231231', 'tech@shop.com', 'Warehouse C', 'TAX003', 'Individual', 203),
(504, 'Fashion Hub', 'preferred', 'Trendy fashion items.', 'active', NULL, 7000, 94.0, '222 Fashion Rd, Q3, HCM', '2342342342', 'fashion@shop.com', 'Warehouse D', 'TAX004', 'Company', 204),
(505, 'Home Comfort', 'normal', 'Furniture and decor.', 'active', NULL, 3000, 88.0, '333 Home Ave, Q5, HCM', '3453453453', 'home@shop.com', 'Warehouse E', 'TAX005', 'Individual', 205),
(506, 'Beauty Store', 'preferred', 'Beauty products.', 'active', NULL, 6000, 96.0, '444 Beauty St, Q7, HCM', '4564564564', 'beauty@shop.com', 'Warehouse F', 'TAX006', 'Individual', 206),
(507, 'Sports Zone', 'normal', 'Sports equipment.', 'active', NULL, 4000, 90.0, '555 Sport Rd, Q10, HCM', '5675675675', 'sports@shop.com', 'Warehouse G', 'TAX007', 'Company', 207),
(508, 'Book World', 'normal', 'Books and media.', 'active', NULL, 2000, 85.0, '666 Book Ave, Q2, HCM', '6786786786', 'books@shop.com', 'Warehouse H', 'TAX008', 'Individual', 208),
(509, 'Toy Kingdom', 'preferred', 'Toys for all ages.', 'active', NULL, 5500, 93.0, '777 Toy St, Q4, HCM', '7897897897', 'toys@shop.com', 'Warehouse I', 'TAX009', 'Company', 209),
(510, 'Pet Corner', 'normal', 'Pet supplies.', 'active', NULL, 3500, 89.0, '888 Pet Rd, Q6, HCM', '8908908908', 'pets@shop.com', 'Warehouse J', 'TAX010', 'Individual', 210);
GO

PRINT '✓ Đã thêm 8 shops mới';
GO

-- 4. THÊM PRODUCT

INSERT INTO PRODUCT (Product_ID, Product_name, Description, Base_Price, Total_Sales, Average_Rating, Base_Image, Product_Status, C_ID, Shop_ID)
VALUES
-- Electronics (C_ID = 1, 5, 11, 12)
(1006, 'Gaming Laptop', 'High-performance gaming laptop.', 30000000, 15, 4.5, '3.Final/Image/laptop_gaming.jpg', 'for_sale', 11, 503),
(1007, 'Wireless Mouse', 'Ergonomic wireless mouse.', 200000, 50, 4.2, '3.Final/Image/WirelessMouse.jpg', 'for_sale', 1, 503),
(1008, 'Bluetooth Headphones', 'Noise-cancelling headphones.', 1500000, 30, 4.7, '3.Final/Image/BluetoothHeadphones.jpg', 'for_sale', 12, 503),
(1009, 'USB-C Cable', 'Fast charging cable.', 50000, 100, 4.0, '3.Final/Image/USB-CCable.jpeg', 'for_sale', 1, 503),
(1010, 'Tablet 10-inch', 'Android tablet.', 5000000, 20, 4.3, '3.Final/Image/Tablet10-inch.jpg', 'for_sale', 5, 503),
-- Fashion (C_ID = 2, 13)
(1011, 'Womens Dress', 'Elegant evening dress.', 500000, 40, 4.6, '3.Final/Image/WomensDress.jpg', 'for_sale', 13, 504),
(1012, 'Mens Jeans', 'Classic denim jeans.', 350000, 60, 4.4, '3.Final/Image/MensJeans.jpg', 'for_sale', 2, 504),
(1013, 'Summer Hat', 'Stylish sun hat.', 120000, 80, 4.1, '3.Final/Image/SummerHat.jpg', 'for_sale', 2, 504),
(1014, 'Leather Wallet', 'Premium leather wallet.', 250000, 45, 4.5, '3.Final/Image/LeatherWallet.jpg', 'for_sale', 2, 504),

-- Home & Living (C_ID = 3, 15)
(1015, 'Wooden Table', 'Solid wood dining table.', 8000000, 10, 4.8, '3.Final/Image/WoodenTable.jpg', 'for_sale', 15, 505),
(1016, 'Office Chair', 'Comfortable office chair.', 2500000, 25, 4.4, '3.Final/Image/OfficeChair.jpg', 'for_sale', 15, 505),
(1017, 'LED Lamp', 'Modern LED desk lamp.', 300000, 70, 4.2, '3.Final/Image/LEDLamp.webp', 'for_sale', 3, 505),

-- Health & Beauty (C_ID = 4, 14)
(1018, 'Face Cream', 'Anti-aging face cream.', 450000, 55, 4.6, '3.Final/Image/FaceCream.jpg', 'for_sale', 14, 506),
(1019, 'Shampoo 500ml', 'Natural hair shampoo.', 180000, 90, 4.3, '3.Final/Image/Shampoo500ml.jpg', 'for_sale', 4, 506),
(1020, 'Massage Oil', 'Relaxing massage oil.', 220000, 35, 4.5, '3.Final/Image/MassageOil.png', 'for_sale', 4, 506),

-- Sports (C_ID = 6)
(1021, 'Yoga Mat', 'Non-slip yoga mat.', 400000, 65, 4.7, '3.Final/Image/YogaMat.jpg', 'for_sale', 6, 507),
(1022, 'Dumbbell Set', '10kg dumbbell set.', 800000, 30, 4.4, '3.Final/Image/DumbbellSet.jpg', 'for_sale', 6, 507),
-- Books (C_ID = 7)
(1023, 'Fiction Novel', 'Bestselling fiction.', 150000, 120, 4.8, '3.Final/Image/FictionNovel.jpg', 'for_sale', 7, 508),
(1024, 'Self-Help Book', 'Inspirational guide.', 180000, 95, 4.6, '3.Final/Image/Self-HelpBook.jpg', 'for_sale', 7, 508),
-- Toys (C_ID = 8)
(1025, 'Building Blocks', 'Educational toy set.', 350000, 75, 4.5, '3.Final/Image/BuildingBlocks.jpg', 'for_sale', 8, 509);
GO

PRINT '✓ Đã thêm 20 products mới';
GO

-- 5. THÊM VARIANT

INSERT INTO VARIANT (Variant_ID, Option_Value_1, Option_Value_2, Variant_Name, Price, SKU, Variant_Status, Variant_Image, P_ID)
VALUES
-- Product 1006 (Gaming Laptop)
(2007, 'Black', '16GB RAM', 'Gaming Laptop (Black, 16GB)', 30000000, 10, 'for_sale', NULL, 1006),
(2008, 'Silver', '32GB RAM', 'Gaming Laptop (Silver, 32GB)', 35000000, 5, 'for_sale', NULL, 1006),

-- Product 1007 (Wireless Mouse)
(2009, 'Black', NULL, 'Wireless Mouse (Black)', 200000, 50, 'for_sale', NULL, 1007),
(2010, 'White', NULL, 'Wireless Mouse (White)', 200000, 40, 'for_sale', NULL, 1007),

-- Product 1008 (Headphones)
(2011, 'Black', NULL, 'Bluetooth Headphones (Black)', 1500000, 30, 'for_sale', NULL, 1008),
(2012, 'Blue', NULL, 'Bluetooth Headphones (Blue)', 1500000, 25, 'for_sale', NULL, 1008),

-- Product 1009 (USB-C)
(2013, '1m', NULL, 'USB-C Cable (1m)', 50000, 100, 'for_sale', NULL, 1009),
(2014, '2m', NULL, 'USB-C Cable (2m)', 70000, 80, 'for_sale', NULL, 1009),

-- Product 1010 (Tablet)
(2015, 'Black', '64GB', 'Tablet (Black, 64GB)', 5000000, 20, 'for_sale', NULL, 1010),
(2016, 'Silver', '128GB', 'Tablet (Silver, 128GB)', 6000000, 15, 'for_sale', NULL, 1010),

-- Product 1011 (Dress)
(2017, 'Red', 'M', 'Womens Dress (Red, M)', 500000, 40, 'for_sale', NULL, 1011),
(2018, 'Black', 'L', 'Womens Dress (Black, L)', 500000, 35, 'for_sale', NULL, 1011),

-- Product 1012 (Jeans)
(2019, 'Blue', '32', 'Mens Jeans (Blue, 32)', 350000, 60, 'for_sale', NULL, 1012),
(2020, 'Black', '34', 'Mens Jeans (Black, 34)', 350000, 55, 'for_sale', NULL, 1012),

-- Product 1013 (Hat)
(2021, 'Beige', NULL, 'Summer Hat (Beige)', 120000, 80, 'for_sale', NULL, 1013),

-- Product 1014 (Wallet)
(2022, 'Brown', NULL, 'Leather Wallet (Brown)', 250000, 45, 'for_sale', NULL, 1014),

-- Product 1015 (Table)
(2023, 'Oak', NULL, 'Wooden Table (Oak)', 8000000, 10, 'for_sale', NULL, 1015),

-- Product 1016 (Chair)
(2024, 'Black', NULL, 'Office Chair (Black)', 2500000, 25, 'for_sale', NULL, 1016),

-- Product 1017 (Lamp)
(2025, 'White', NULL, 'LED Lamp (White)', 300000, 70, 'for_sale', NULL, 1017),

-- Product 1018 (Face Cream)
(2026, '50ml', NULL, 'Face Cream (50ml)', 450000, 55, 'for_sale', NULL, 1018),

-- Product 1019 (Shampoo)
(2027, 'Natural', NULL, 'Shampoo (500ml)', 180000, 90, 'for_sale', NULL, 1019),

-- Product 1020 (Oil)
(2028, 'Lavender', NULL, 'Massage Oil (Lavender)', 220000, 35, 'for_sale', NULL, 1020),

-- Product 1021 (Yoga Mat)
(2029, 'Purple', NULL, 'Yoga Mat (Purple)', 400000, 65, 'for_sale', NULL, 1021),
(2030, 'Green', NULL, 'Yoga Mat (Green)', 400000, 60, 'for_sale', NULL, 1021),

-- Product 1022 (Dumbbell)
(2031, '10kg', NULL, 'Dumbbell Set (10kg)', 800000, 30, 'for_sale', NULL, 1022),

-- Product 1023 (Novel)
(2032, 'Hardcover', NULL, 'Fiction Novel (Hardcover)', 150000, 120, 'for_sale', NULL, 1023),

-- Product 1024 (Self-Help)
(2033, 'Paperback', NULL, 'Self-Help Book (Paperback)', 180000, 95, 'for_sale', NULL, 1024),

-- Product 1025 (Blocks)
(2034, 'Multi-color', NULL, 'Building Blocks (100pcs)', 350000, 75, 'for_sale', NULL, 1025),
(2035, 'Multi-color', NULL, 'Building Blocks (200pcs)', 500000, 50, 'for_sale', NULL, 1025);
GO

PRINT '✓ Đã thêm 30 variants mới';
GO

-- 6. THÊM ORDER_PAYMENT CHO NHIỀU CUSTOMER

-- Customer 107 (mua Electronics, Fashion)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9101, '2025-11-05', NULL, '111 St', 'completed', 10101, 'Credit Card', 'success', 1515000, 1500000, 15000, 0, 107),
(9102, '2025-11-10', NULL, '111 St', 'completed', 10102, 'COD', 'success', 515000, 500000, 15000, 0, 107);
GO

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8101, 'SPX101', '2025-11-07', '2025-11-07', 1, 15000, 'successful delivery', NULL, 9101, 107),
(8102, 'SPX102', '2025-11-12', '2025-11-12', 1, 15000, 'successful delivery', NULL, 9102, 107);
GO

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7101, 1500000, 1, 1500000, 8101, 2011), -- Headphones
(7102, 500000, 1, 500000, 8102, 2017);   -- Dress
GO

-- Customer 108 (mua Electronics, Home)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9103, '2025-11-08', NULL, '222 St', 'completed', 10103, 'Shopee Pay', 'success', 215000, 200000, 15000, 0, 108),
(9104, '2025-11-15', NULL, '222 St', 'completed', 10104, 'Bank Transfer', 'success', 2515000, 2500000, 15000, 0, 108);
GO

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8103, 'SPX103', '2025-11-09', '2025-11-09', 1, 15000, 'successful delivery', NULL, 9103, 108),
(8104, 'SPX104', '2025-11-17', '2025-11-17', 1, 15000, 'successful delivery', NULL, 9104, 108);
GO

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7103, 200000, 1, 200000, 8103, 2009),   -- Mouse
(7104, 2500000, 1, 2500000, 8104, 2024); -- Chair
GO

-- Customer 110 (mua nhiều categories khác nhau)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES
(9105, '2025-11-12', NULL, '333 St', 'completed', 10105, 'Credit Card', 'success', 415000, 400000, 15000, 0, 110),
(9106, '2025-11-18', NULL, '333 St', 'completed', 10106, 'COD', 'success', 815000, 800000, 15000, 0, 110),
(9107, '2025-11-20', NULL, '333 St', 'completed', 10107, 'Shopee Pay', 'success', 165000, 150000, 15000, 0, 110);
GO

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES
(8105, 'SPX105', '2025-11-14', '2025-11-14', 1, 15000, 'successful delivery', NULL, 9105, 110),
(8106, 'SPX106', '2025-11-20', '2025-11-20', 1, 15000, 'successful delivery', NULL, 9106, 110),
(8107, 'SPX107', '2025-11-22', '2025-11-22', 1, 15000, 'successful delivery', NULL, 9107, 110);
GO

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7105, 400000, 1, 400000, 8105, 2029),   -- Yoga Mat
(7106, 800000, 1, 800000, 8106, 2031),   -- Dumbbell
(7107, 150000, 1, 150000, 8107, 2032);   -- Novel
GO

-- 1. REVIEWS CHO PRODUCT 1008 (Headphones, User 107, 108, 110)
-- Total 10 reviews (5 sao, 3 sao, 1 sao)
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Rating_Star, P_ID, User_ID)
VALUES
-- THÁNG 9/2025 (Để test logic lọc ngày)
(201, '2025-09-15 10:00:00', 5, 1008, 107), -- User 107 (5 sao)
(202, '2025-09-20 12:00:00', 4, 1008, 108), -- User 108 (4 sao)
-- THÁNG 11/2025 (Để test tính Average Rating)
(203, '2025-11-05 10:00:00', 3, 1008, 110), -- User 110 (3 sao)
(204, '2025-11-15 12:00:00', 1, 1008, 107), -- User 107 (1 sao)
(205, '2025-11-25 15:00:00', 5, 1008, 108); -- User 108 (5 sao)
GO

-- 2. REVIEWS CHO PRODUCT 1023 (Fiction Novel, User 110)
-- 4 Reviews để test logic phân bố ngày
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Rating_Star, P_ID, User_ID)
VALUES
(206, '2025-10-01 08:00:00', 5, 1023, 110), -- User 110 (5 sao)
(207, '2025-11-01 09:00:00', 3, 1023, 110), -- User 110 (3 sao)
(208, '2025-11-15 11:00:00', 5, 1023, 110), -- User 110 (5 sao)
(209, '2025-11-28 14:00:00', 4, 1023, 110); -- User 110 (4 sao)
GO

-- 3. REVIEW CHO PRODUCT 1016 (Office Chair, User 108)
-- 1 Review để test case 1 review
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Rating_Star, P_ID, User_ID)
VALUES
(210, '2025-11-18 16:00:00', 4, 1016, 108); -- User 108 (4 sao)
GO



-- ==============================================================================

INSERT INTO VARIANT (Variant_ID, Option_Value_1, Option_Value_2, Variant_Name, Price, SKU, Variant_Status, Variant_Image, P_ID) 
VALUES
-- Cho Shop 502 (Fashion): Restock Áo thun
(2036, 'Red', 'L', 'Mens T-Shirt (Red, L) - Batch 2', 150000, 100, 'for_sale', NULL, 1002),
-- Cho Shop 502: Lô Serum mới
(2037, '30ml', NULL, 'Vitamin C Serum (30ml) - Batch 2', 300000, 100, 'for_sale', NULL, 1004),
-- Cho Shop 501: iPhone bản giới hạn (Cho User 101)
(2038, 'Gold', '1TB', 'iPhone 15 PM Gold - VIP 1', 40000000, 10, 'for_sale', NULL, 1001),
-- Cho Shop 502: Áo thun bán sỉ (Cho User 110)
(2039, 'Blue', 'M', 'Mens T-Shirt (Blue, M) - Batch 3', 150000, 500, 'for_sale', NULL, 1002),
-- Cho Shop 501: iPhone bản giới hạn (Cho User 110 - Năm 2024)
(2040, 'Titanium', '1TB', 'iPhone 15 PM Titan - VIP 2', 40000000, 10, 'for_sale', NULL, 1001);
GO

-- 2. TẠO CÁC GIAO DỊCH LỊCH SỬ VÀ VIP (NỐI TIẾP ID TỪ 9108)

-- [Đơn 9108] - Năm 2024 (Quá khứ): User 107 mua Serum (Variant 2037)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9108, '2024-03-15 14:00:00', NULL, '111 St', 'completed', 10108, 'COD', 'success', 315000, 300000, 15000, 0, 107);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8108, 'SPX-OLD-01', '2024-03-17 10:00:00', '2024-03-17 00:00:00', 1, 15000, 'successful delivery', NULL, 9108, 107);

INSERT INTO SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location)
VALUES (8108, 1, 'delivered', '2024-03-17 10:00:00', 'Customer Address');

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7108, 300000, 1, 300000, 8108, 2037);


-- [Đơn 9109] - Năm 2024 (Quá khứ): User 108 mua Áo thun (Variant 2036)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9109, '2024-08-20 10:00:00', NULL, '222 St', 'completed', 10109, 'Shopee Pay', 'success', 165000, 150000, 15000, 0, 108);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8109, 'SPX-OLD-02', '2024-08-22 14:00:00', '2024-08-22 00:00:00', 1, 15000, 'successful delivery', NULL, 9109, 108);

INSERT INTO SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location)
VALUES (8109, 1, 'delivered', '2024-08-22 14:00:00', 'Customer Address');

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7109, 150000, 1, 150000, 8109, 2036);


-- [Đơn 9110] - Năm 2025 (Hiện tại): User 110 mua Sỉ Áo thun (Variant 2039)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9110, '2025-12-05 09:00:00', NULL, '333 St', 'completed', 10110, 'Bank Transfer', 'success', 1550000, 1500000, 50000, 0, 110);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8110, 'SPX-NEW-01', '2025-12-07 09:00:00', '2025-12-07 00:00:00', 1, 50000, 'successful delivery', NULL, 9110, 110);

INSERT INTO SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location)
VALUES (8110, 1, 'delivered', '2025-12-07 09:00:00', 'Customer Address');

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7110, 150000, 10, 1500000, 8110, 2039);


-- [Đơn 9111] - Năm 2025: User 101 mua iPhone VIP (Variant 2038)
-- Mục đích: Đẩy User 101 lên Top VIP 2025 (40 Triệu)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9111, '2025-05-15 10:00:00', NULL, '123 Le Loi', 'completed', 10111, 'Credit Card', 'success', 40000000, 40000000, 0, 0, 101);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8111, 'VIP-01', '2025-05-17 10:00:00', '2025-05-17 00:00:00', 1, 0, 'successful delivery', NULL, 9111, 101);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7111, 40000000, 1, 40000000, 8111, 2038);


-- [Đơn 9112] - Năm 2024: User 110 mua iPhone VIP (Variant 2040)
-- Mục đích: User 110 là VIP năm ngoái (80 Triệu)
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (9112, '2024-12-20 10:00:00', NULL, '333 St', 'completed', 10112, 'Credit Card', 'success', 80000000, 80000000, 0, 0, 110);

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
VALUES (8112, 'VIP-OLD', '2024-12-22 10:00:00', '2024-12-22 00:00:00', 1, 0, 'successful delivery', NULL, 9112, 110);

INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES (7112, 40000000, 2, 80000000, 8112, 2040);