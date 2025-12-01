-- ===================================================
-- DỮ LIỆU BỔ SUNG CHO HÀM
-- ===================================================

USE [QL_SHOPEE_BTL];
GO

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
(1006, 'Gaming Laptop', 'High-performance gaming laptop.', 30000000, 15, 4.5, NULL, 'for_sale', 11, 503),
(1007, 'Wireless Mouse', 'Ergonomic wireless mouse.', 200000, 50, 4.2, NULL, 'for_sale', 1, 503),
(1008, 'Bluetooth Headphones', 'Noise-cancelling headphones.', 1500000, 30, 4.7, NULL, 'for_sale', 12, 503),
(1009, 'USB-C Cable', 'Fast charging cable.', 50000, 100, 4.0, NULL, 'for_sale', 1, 503),
(1010, 'Tablet 10-inch', 'Android tablet.', 5000000, 20, 4.3, NULL, 'for_sale', 5, 503),

-- Fashion (C_ID = 2, 13)
(1011, 'Womens Dress', 'Elegant evening dress.', 500000, 40, 4.6, NULL, 'for_sale', 13, 504),
(1012, 'Mens Jeans', 'Classic denim jeans.', 350000, 60, 4.4, NULL, 'for_sale', 2, 504),
(1013, 'Summer Hat', 'Stylish sun hat.', 120000, 80, 4.1, NULL, 'for_sale', 2, 504),
(1014, 'Leather Wallet', 'Premium leather wallet.', 250000, 45, 4.5, NULL, 'for_sale', 2, 504),

-- Home & Living (C_ID = 3, 15)
(1015, 'Wooden Table', 'Solid wood dining table.', 8000000, 10, 4.8, NULL, 'for_sale', 15, 505),
(1016, 'Office Chair', 'Comfortable office chair.', 2500000, 25, 4.4, NULL, 'for_sale', 15, 505),
(1017, 'LED Lamp', 'Modern LED desk lamp.', 300000, 70, 4.2, NULL, 'for_sale', 3, 505),

-- Health & Beauty (C_ID = 4, 14)
(1018, 'Face Cream', 'Anti-aging face cream.', 450000, 55, 4.6, NULL, 'for_sale', 14, 506),
(1019, 'Shampoo 500ml', 'Natural hair shampoo.', 180000, 90, 4.3, NULL, 'for_sale', 4, 506),
(1020, 'Massage Oil', 'Relaxing massage oil.', 220000, 35, 4.5, NULL, 'for_sale', 4, 506),

-- Sports (C_ID = 6)
(1021, 'Yoga Mat', 'Non-slip yoga mat.', 400000, 65, 4.7, NULL, 'for_sale', 6, 507),
(1022, 'Dumbbell Set', '10kg dumbbell set.', 800000, 30, 4.4, NULL, 'for_sale', 6, 507),

-- Books (C_ID = 7)
(1023, 'Fiction Novel', 'Bestselling fiction.', 150000, 120, 4.8, NULL, 'for_sale', 7, 508),
(1024, 'Self-Help Book', 'Inspirational guide.', 180000, 95, 4.6, NULL, 'for_sale', 7, 508),

-- Toys (C_ID = 8)
(1025, 'Building Blocks', 'Educational toy set.', 350000, 75, 4.5, NULL, 'for_sale', 8, 509);
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