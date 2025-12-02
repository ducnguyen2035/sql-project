-- ==============================================================================
-- TEST SCENARIOS
-- ==============================================================================
USE [QL_SHOPEE_BTL]
GO


-- Test Trigger 1:

-- Reset 
DELETE FROM ORDER_PAYMENT WHERE Order_ID >= 99;
-- Thêm đơn hàng dưới giá trị min_voucher -> trigger chặn
INSERT INTO ORDER_PAYMENT VALUES
(99, '2024-11-15 10:00:00', 'TECH500K', '999 Test St', 'processing', 99, 'Shopee Pay', 'processing', 450000, 450000, 50000, 50000, 1);

-- Thêm đơn hàng nằm trong min-max voucher -> hợp lệ
INSERT INTO ORDER_PAYMENT VALUES
(100, GETDATE(), 'TECHSALE', 'Test St', 'processing', 100, 'COD', 'processing', 5500000, 6000000, 0, 500000, 1);

-- Thêm đơn hàng không sử dụng voucher -> trigger để đi qua
INSERT INTO ORDER_PAYMENT VALUES
(101, GETDATE(), NULL, 'Test St', 'processing', 101, 'COD', 'processing', 100000, 100000, 0, 0, 1);

-- Thêm đơn hàng vượt quá max voucher -> trigger chặn
INSERT INTO ORDER_PAYMENT VALUES
(102, GETDATE(), 'TECH500K', 'Bach Khoa HCM', 'processing', 102, 'COD', 'processing', 500000000, 50050000, 50000, 100000, 1);

-- Update giá trị đơn đã tạo < min_voucher -> trigger chặn
UPDATE ORDER_PAYMENT
SET Product_value = 100000, Payed_value = 100000 
WHERE Order_ID = 100;





-- Test Trigger 2: Check product rating update


-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu hoặc mở bảng product để xem tất cả sản phẩm để show
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

-- Xử lý đơn hàng 100 qua các bảng để thành trạng thái 'success'
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

-- Thêm đánh giá cho đơn hàng 100
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (999, GETDATE(), NULL, 'Test Rating Order 100', 1, 1, 1);

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

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

-- Thêm đánh giá cho đơn hàng tiếp theo
INSERT INTO PRODUCT_REVIEW (Review_ID, Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
    VALUES (1000, GETDATE(), NULL, 'Excellent!', 5, 1, 2);

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

-- Update đánh giá -> AVG đổi như nào
UPDATE PRODUCT_REVIEW 
SET Rating_Star = 4, Comment = 'Changed my mind, it is good'
WHERE Review_ID = 999;

-- Coi product 1 hiện đang đánh giá trung bình bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

-- Xóa đánh giá
DELETE FROM PRODUCT_REVIEW WHERE Review_ID = 1000;
-- Điểm AVG thành bao nhiêu
SELECT Product_ID, Product_Name, Average_Rating FROM PRODUCT WHERE Product_ID = 1;

-- Reset
DELETE FROM PRODUCT_REVIEW WHERE Review_ID IN (999, 1000);
DELETE FROM ORDER_ITEM WHERE Shipment_ID IN (
    SELECT Shipment_ID FROM SHIPMENT_PACKAGE WHERE Order_ID IN (100, 200)
);
DELETE FROM SHIPMENT_PACKAGE WHERE Order_ID IN (100, 200);
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (100, 200);
DELETE FROM VARIANT WHERE Variant_ID = 2;



