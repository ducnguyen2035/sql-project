-- ===================================================
-- INSERT SCRIPT (FIXED & MATCHED WITH NEW SCHEMA)
-- ===================================================

USE [QL_SHOPEE_BTL];
GO

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
DELETE FROM TRUCK_DRIVER;
DELETE FROM SHIPPER;
DELETE FROM DELIVERY_STAFF;
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
INSERT INTO SHIPPING_PROVIDER (Provider_ID, Coverage_Area, Weight_Limit, Size_Limit, Delivery_Method) 
VALUES
(1, 'Nationwide', 50, '100x100x100', 'standard'),
(2, 'Nationwide', 30, '80x80x80', 'economy'),
(3, 'Nationwide', 30, '80x80x80', 'fast'),
(4, 'Nationwide', 50, '120x120x120', 'standard'),
(5, 'HCMC/Hanoi Internal', 20, '50x50x50', 'instant');
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
PRINT 'Stage 2 Complete: 4 dependent tables populated.';
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
INSERT INTO SHOP_SELL (Shop_ID, Shop_name, Shop_type, Description, Operation_Status, Logo, Follower, Rating, Chat_response_rate, Address, Bank_Account, Email_for_Online_Bills, Stock_address, Tax_code, Type_of_Business, User_ID)
VALUES
(501, 'The Official Mall', 'Shopee Mall', 'Genuine products.', 'active', NULL, 15000, 4.9, 98.5, '123 Le Loi, Q1, HCM', '0123456789', 'mall@shop.com', 'Warehouse A, Q7, HCM', 'TAX001', 'Company', 201),
(502, 'Preferred Plus Shop', 'preferred', 'Quality items.', 'active', NULL, 8000, 4.8, 95.0, '456 Hai Ba Trung, Q3, HCM', '9876543210', 'preferred@shop.com', 'Warehouse B, Q9, HCM', 'TAX002', 'Individual', 202);
GO

-- 12. DELIVERY_STAFF
INSERT INTO DELIVERY_STAFF (Staff_ID, Full_Name, ID_Number, Driver_License, Provider_ID)
VALUES
(301, 'Ha Van Tai', '002080111111', 'DL123', 1),
(302, 'Do Van Chuyen', '002080222222', 'DL456', 1),
(303, 'Ly Van Toc', '002080333333', 'DL789', 3),
(304, 'Vu Van Nhanh', '002080444444', 'DL987', 5),
(305, 'Pham Van Giao', '002080555555', 'DL654', 2);
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
PRINT 'Stage 3 Complete: 4 specialized tables populated.';
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

-- 16. TRUCK_DRIVER
INSERT INTO TRUCK_DRIVER (Staff_ID, Truck_ID, Route_Assigned, Max_weight)
VALUES
(301, 10, 'Route HCM-HN', 2000),
(302, 11, 'Route HCM-DN', 1500),
(303, 12, 'Route HN-DN', 1500);
GO

-- 17. SHIPPER
INSERT INTO SHIPPER (Staff_ID, Vehicle_type, Delivery_zone)
VALUES
(304, 'motorcycle', 'HCMC District 1, 3, 4'),
(305, 'motorcycle', 'Hanoi Ba Dinh, Cau Giay');
GO

-- 18. PRODUCT
INSERT INTO PRODUCT (Product_ID, Product_name, Description, Base_Price, Total_Sales, Average_Rating, Base_Image, Product_Status, C_ID, Shop_ID)
VALUES
(1001, 'Smartphone Model X', 'Latest generation smartphone.', 10000000, 0, 0, NULL, 'for_sale', 5, 501),
(1002, 'Mens T-Shirt', '100% Cotton T-Shirt.', 150000, 0, 0, NULL, 'for_sale', 2, 502),
(1003, 'Luxury Sofa', 'High-quality leather sofa.', 5000000, 0, 0, NULL, 'for_sale', 3, 501),
(1004, 'Vitamin C Serum', 'Skincare serum for beauty.', 300000, 0, 0, NULL, 'for_sale', 4, 502),
(1005, 'Laptop Pro', 'High-end laptop for professionals.', 25000000, 0, 0, NULL, 'discontinued', 1, 501);
GO

-- 19. VOUCHER
INSERT INTO VOUCHER (Voucher_ID, Quantity, Voucher_Code, Voucher_Type, Discount_Type, Minimum_Order_Value, Maximum_Order_Value, Start_Date, Expiration_Date, Program_ID)
VALUES
(1, 100, 'SALE1212', 'Platform', 'percent', 100000, 50000, '2025-12-12 00:00:00', '2025-12-12 23:59:59', 1),
(2, 50, 'TECHSALE', 'Shop', 'fixed', 5000000, 1000000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 2),
(3, 500, 'FASHION20K', 'Shop', 'fixed', 150000, 20000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 3),
(4, 10, 'EXPIREDVOUCHER', 'Platform', 'fixed', 0, 10000, '2020-01-01 00:00:00', '2020-01-02 23:59:59', 5),
(5, 0, 'OUTOFSTOCK', 'Shipping', 'fixed', 0, 15000, '2025-11-01 00:00:00', '2025-11-30 23:59:59', 5);
GO
PRINT 'Stage 4 Complete: 6 tables populated (Staff, Product, Voucher...).';
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
PRINT 'Stage 5 Complete: VARIANT table populated.';
GO

-- STAGE 6: CREATE TRANSACTION SCENARIOS (ORDERS)
PRINT '--- STARTING TRANSACTION SCENARIOS ---';
GO

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
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7001, 10000000, 2, 'TECHSALE', 9000000, 8001, 2001);
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
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7002, 150000, 1, 'FASHION20K', 140000, 8002, 2003);
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7003, 150000, 1, NULL, 150000, 8002, 2004);
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
INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
VALUES
(7004, 300000, 1, NULL, 300000, 8004, 2005);
GO

-- SCENARIO 4: FAILED Order (Trigger 2)
PRINT '--- SCENARIO 4: (EXPECTING ERROR) Order by User 103 (restricted) ---';
BEGIN TRY
    INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES
    (9003, GETDATE(), NULL, '789 Cong Hoa, Tan Binh, HCM', 'processing', 10003, 'COD', 'processing', 150000, 150000, 0, 0, 103); 
END TRY
BEGIN CATCH
    PRINT 'CAUGHT ERROR (Success): ' + ERROR_MESSAGE();
END CATCH;
GO

-- SCENARIO 5: FAILED Order (Trigger 1)
PRINT '--- SCENARIO 5: (EXPECTING ERROR) Buying 3 T-shirts (only 1 in stock) ---';
BEGIN TRY
    INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES
    (9005, GETDATE(), NULL, '111 CMT8, Q10, HCM', 'processing', 10005, 'COD', 'processing', 465000, 450000, 15000, 0, 102);
    
    -- [FIXED]: Removed Provider_ID, Changed type to 'successful delivery'
    INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Order_ID, Customer_ID)
    VALUES
    (8005, 'SPX0005', NULL, '2025-11-18', 1, 15000, 'successful delivery', NULL, 9005, 102);

    INSERT INTO ORDER_ITEM (Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
    VALUES
    (7005, 150000, 3, NULL, 150000, 8005, 2004);
END TRY
BEGIN CATCH
    PRINT 'CAUGHT ERROR (Success): ' + ERROR_MESSAGE();
    IF EXISTS (SELECT 1 FROM ORDER_PAYMENT WHERE Order_ID = 9005)
    BEGIN
        DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID = 9005;
        DELETE FROM ORDER_PAYMENT WHERE Order_ID = 9005;
        PRINT 'Rolled back failed Order 9005.';
    END
END CATCH;
GO

PRINT 'Stage 6 Complete: Transaction scenarios executed.';
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
PRINT '--- SCENARIO 7: (EXPECTING SUCCESS) User 101 reviews a purchased product ---';
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
VALUES
(1, GETDATE(), NULL, 'Good product, fast delivery.', 5, 1004, 101);
GO

PRINT '--- SCENARIO 8: (EXPECTING ERROR) User 102 reviews an un-purchased product ---';
BEGIN TRY
    INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES
    (2, GETDATE(), NULL, 'I think this is good.', 4, 1004, 102); 
END TRY
BEGIN CATCH
    PRINT 'CAUGHT ERROR (Success): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Stage 7 Complete: Operations tables and Review tests executed.';
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

PRINT '--- ALL STAGES COMPLETE ---';
PRINT 'Sample data has been inserted and triggers have been tested.';
PRINT 'Stock for Variant 2001 (Smartphone) is now 98.';
PRINT 'Stock for Variant 2003 (Red T-Shirt) is now 99.';
PRINT 'Stock for Variant 2004 (Blue T-Shirt) is now 1.';
PRINT 'Stock for Variant 2005 (Serum) is now 99.';
PRINT '1 valid Review (ID 1) has been created.';
GO