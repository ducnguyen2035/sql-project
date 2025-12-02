USE [QL_SHOPEE_BTL]
GO

-- Test Procedure 1: Get shop order history

-- Lấy tất cả đơn hàng để xem trước
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

USE [QL_SHOPEE_BTL]
GO

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

-- Test Procedure 2:
EXEC SP_Get_Potential_Vip_Users 
    @Year = 2025, 
    @Min_Spending = 100000000;
GO
