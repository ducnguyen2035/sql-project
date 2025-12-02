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


-- Test Procedure 2:
EXEC SP_Get_Shop_Order_History @Shop_ID = 1;
