-- ==============================================================================
-- TEST SCENARIOS
-- ==============================================================================
USE [QL_SHOPEE_BTL]
GO


-- Test Trigger 1:

-- Reset 
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (99, 100, 101, 102, 103);


-- Thêm đơn hàng dưới giá trị min_voucher -> trigger chặn
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (99, '2024-11-15 10:00:00', 'TECHSALE', '999 Test St', 'processing', 99, 'Shopee Pay', 'processing', 450000, 450000, 50000, 50000, 101); -- User 101

-- Thêm đơn hàng nằm trong min-max voucher -> hợp lệ
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (100, GETDATE(), 'TECHSALE', 'Test St', 'processing', 100, 'COD', 'processing', 5500000, 6000000, 0, 500000, 101);

-- Thêm đơn hàng không sử dụng voucher -> trigger để đi qua
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (101, GETDATE(), NULL, 'Test St', 'processing', 101, 'COD', 'processing', 100000, 100000, 0, 0, 101);

-- Thêm đơn hàng với Voucher không có trong kho Voucher
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (102, GETDATE(), 'SALETULANH', 'BachKhoaTPHCM', 'processing', 102, 'Shopee Pay', 'processing', 500000, 700000, 50000, 250000, 101);

-- Thêm đơn hàng trên giá trị max_voucher -> trigger chặn
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (103, GETDATE(), 'FASHION20K', 'Test Max Address', 'processing', 9995, 'COD', 'processing', 280000, 300000, 0, 20000, 101);

UPDATE ORDER_PAYMENT
SET Product_value = 1000000, Payed_value = 500000
WHERE Order_ID = 100;





-- Test Trigger 2: Check product rating update

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu hoặc mở bảng product để xem tất cả sản phẩm để show
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1008;

-- Xử lý đơn hàng 100 qua các bảng để thành trạng thái 'success'

UPDATE ORDER_PAYMENT 
SET Order_Status = 'completed', 
    Payment_Status = 'success'
WHERE Order_ID = 100

DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID = 100; 
INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (8100, 100, 'TRK-TEST-100', 'successful delivery', 101, 0);

IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 9000)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (9000, 'Test Headphone Unit', 1500000, 100, 1008, 'for_sale');

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (7100, 8100, 9000, 1, 30000000, 30000000);

-- Thêm đánh giá cho đơn hàng 100
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (300, GETDATE(), NULL, 'Test Rating Order 100', 1, 1008, 101);

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1008;

-- Tạo người mua tiếp để check
IF NOT EXISTS (SELECT 1 FROM VARIANT WHERE Variant_ID = 9001)
    INSERT INTO VARIANT (Variant_ID, Variant_Name, Price, SKU, P_ID, Variant_Status)
    VALUES (9001, 'Test Headphone Unit 2', 30000000, 1, 1008, 'for_sale');

-- Tao Don Hang cho User 102

INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
VALUES (200, GETDATE(), NULL, 'User 102 Address', 'completed', 200, 'COD', 'success', 30000000, 30000000, 0, 0, 102); -- User 102

INSERT INTO SHIPMENT_PACKAGE (Shipment_ID, Order_ID, Tracking_Number, Shipment_type, Customer_ID, Shipping_Fee)
VALUES (8500, 200, 'TRK-USER102', 'successful delivery', 102, 0);

INSERT INTO ORDER_ITEM (Order_Item_ID, Shipment_ID, Variant_ID, Quantity, Price_at_Purchase, Final_Item_Price)
VALUES (7500, 8500, 9001, 1, 30000000, 30000000);

-- Thêm đánh giá cho đơn hàng tiếp theo
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 301;
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (301, GETDATE(), NULL, 'Excellent!', 5, 1008, 102);

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1008;

-- Update đánh giá -> AVG đổi như nào
UPDATE PRODUCT_REVIEW 
SET Rating_Star = 4, Comment = 'Changed my mind, it is good'
WHERE Review_ID = 300;

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1008;

-- Xóa đánh giá
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 300;
-- Điểm AVG thành bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1008;

-- Reset
DELETE FROM PRODUCT_REVIEW WHERE Review_ID IN (300, 301);
DELETE FROM ORDER_ITEM WHERE Shipment_ID IN (8100, 8500);
DELETE FROM SHIPMENT_STATUS 
    WHERE Shipment_ID IN (SELECT Shipment_ID FROM SHIPMENT_PACKAGE WHERE Order_ID = 100);
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID IN (100, 200);
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (100, 200);
DELETE FROM VARIANT WHERE Variant_ID = 9000 AND Variant_ID = 9001;
GO



