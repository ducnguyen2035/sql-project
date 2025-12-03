USE [QL_SHOPEE_BTL]
GO

-- Test Procedure 1: Get shop order history

-- Lấy tất cả đơn hàng để xem trước
SELECT 
    s.Shop_ID, 
    s.Shop_name, 
    COUNT(DISTINCT sp.Order_ID) AS [So_Luong_Don_Hang]
FROM SHOP_SELL s
JOIN PRODUCT p ON s.Shop_ID = p.Shop_ID
JOIN VARIANT v ON p.Product_ID = v.P_ID
JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
GROUP BY s.Shop_ID, s.Shop_name
ORDER BY [So_Luong_Don_Hang] DESC;

EXEC SP_Get_Shop_Order_History
    @Shop_ID = 502,
    @Start_date = '2024-01-01 00:00:00.000',
    @End_date = '2024-12-31 00:00:00.000';
GO




-- Test Procedure 2:
EXEC SP_Get_Potential_Vip_Users 
    @Year = 2025, 
    @Min_Spending = 3000000;
GO
