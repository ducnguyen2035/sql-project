USE [QL_SHOPEE_BTL];
GO
--- ===================================================
--phần của đức
-- Test cases for dbo.usp_User_Insert
--trả về lỗi require id number
exec dbo.usp_User_Insert   
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi id number đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='001099001111',--trùng với user id 101
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phải đủ 12 chữ số
exec dbo.usp_User_Insert
	@ID_number ='01234567891011',-- thừa 1 chữ số
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='01234567891',-- thiếu 1 chữ số
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi yêu cầu phone number
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phone number đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',--trung voi user id 101
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phone number không bắt đầu bằng số 0
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='01234567891',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
---trả về lỗi phone number không có đúng 10 chữ số
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='012345678910',-- dư 2 chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='012345678',-- thiếu 1 chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi phone number chứa ký tự không phải chữ số
exec dbo.usp_User_Insert
    @ID_number ='012345678910',
    @Phone_number ='012a456789',-- chứa ký tự không phải chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi yêu cầu email
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email =null,
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi email đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='nguyenvana@gmail.com',--trùng với email user id 101
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi email cần phải có dấu @
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abchcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi email không được tồn tại dấu cách
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hc mut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi yêu cầu full name
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi full name tồn tại khoảng trắng ở đầu hoặc cuối
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name =' Dang Kieu D',--khoảng trắng ở đầu
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D   ',--khoảng trắng ở cuối
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi full name tồn tại nhiều khoảng trắng ở giữa
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang   Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi full name tồn tại ký tự không phải chữ cái
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D6',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi giới tính không hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Mal',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi birthday ko thể thuộc về tương lai
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='2026-1-1',
    @Account_status ='active'
-- trả về lỗi tuổi không thuộc khoảng hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1800-4-30',
    @Account_status ='active'
-- trả về lỗi account status không hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='activ'
-- insert thành công
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- kiểm tra phần vừa insert
SELECT TOP (1000) [User_ID]
      ,[ID_number]
      ,[Phone_number]
      ,[Email]
      ,[Full_name]
      ,[Gender]
      ,[Birthday]
      ,[Account_status]
      ,[Entity_ID]
  FROM [QL_SHOPEE_BTL].[dbo].[USER]
-- Test cases for dbo.usp_User_Update
-- yêu cầu user id
exec dbo.usp_User_Update
	@User_ID=null
--user id không tồn tại
exec dbo.usp_User_Update
	@User_ID='204'
-- id number phải có đúng 12 số
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='5678910111211'-- dư 1 số
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='56789101112'-- thiếu 1 số
--id number được dùng bởi user khác
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='001098002222' -- dùng bởi user id 102
--phone number không bắt đầu bằng số 0
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='1123456789'
-- phone number khác 10 chữ số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='012345678910'-- nhiều hơn 10 số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='012345678'-- ít hơn 10 số
--phone number tồn tại ký tự khác chữ số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='0123456s89'
--phone number được dùng bởi người khác
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='0909456789'--dùng bới user id 104
-- email thiếu @
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='applegmail.com'
--email có khoảng trắng
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='app le@gmail.com'
--email được dùng bởi người khác
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='phamthid@shop.com'
-- full name có tồn tại ký tự khác chữ cái trong tên
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan Kieu D6'
-- full name có khoảng trắng trước hoặc sau
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan Kieu D '-- có khoảng trắng ở sau
-- full name có khoảng trắng trước 
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name=' Doan Kieu D'-- có khoảng trắng ở trước
-- full name có khoảng trắng ở giữa
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan  Kieu D'
-- gender không hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Gender='Femal'
--birthday trong tương lai
exec dbo.usp_User_Update
	@User_ID='203',
	@Birthday='2070-1-1'
--birthday không nằm trong khoảng hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Birthday='1800-1-1'
-- account status không hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Account_status='restricte'
-- Test cases for dbo.usp_User_Delete
--Yêu cầu user id
exec dbo.usp_User_Delete
    @User_ID=null
--Không tồn tại người dùng
SELECT TOP (1000) [User_ID]
      ,[ID_number]
      ,[Phone_number]
      ,[Email]
      ,[Full_name]
      ,[Gender]
      ,[Birthday]
      ,[Account_status]
      ,[Entity_ID]
  FROM [QL_SHOPEE_BTL].[dbo].[USER]
exec dbo.usp_User_Delete
    @User_ID='100'
--người dùng là customer sở hữu orders
SELECT TOP (1000) [Order_ID]
      ,[Order_date]
      ,[Voucher_code]
      ,[Address]
      ,[Order_Status]
      ,[Payment_ID]
      ,[Payment_Method]
      ,[Payment_Status]
      ,[Payed_value]
      ,[Product_value]
      ,[Shipment_value]
      ,[Voucher_value]
      ,[User_ID]
  FROM [QL_SHOPEE_BTL].[dbo].[ORDER_PAYMENT]
SELECT TOP (1000) [User_ID]
      ,[Total_Order]
      ,[Total_Spending]
      ,[Tier_ID]
  FROM [QL_SHOPEE_BTL].[dbo].[CUSTOMER]
exec dbo.usp_User_Delete
	@User_ID='101'
exec dbo.usp_User_Delete
	@User_ID='102'
--người dùng sở hữu shop
SELECT TOP (1000) [Shop_ID]
      ,[Shop_name]
      ,[Shop_type]
      ,[Description]
      ,[Operation_Status]
      ,[Logo]
      ,[Follower]
      ,[Chat_response_rate]
      ,[Address]
      ,[Bank_Account]
      ,[Email_for_Online_Bills]
      ,[Stock_address]
      ,[Tax_code]
      ,[Type_of_Business]
      ,[User_ID]
  FROM [QL_SHOPEE_BTL].[dbo].[SHOP_SELL]
exec dbo.usp_User_Delete
	@User_ID='201'
exec dbo.usp_User_Delete
	@User_ID='202'
-- người dùng là customer không có order.
exec dbo.usp_User_Delete
	@User_ID='103'
-- trường hợp delete thành công
exec dbo.usp_User_Delete
	@User_ID='104'
exec dbo.usp_User_Delete
	@User_ID='105'
exec dbo.usp_User_Delete
	@User_ID='106'

--================================================
--phần của tùng
-- Test Trigger 8:VOUCHER MINIMUM SPEND VALIDATION 

-- Reset 
-- Reset 
DELETE FROM ORDER_PAYMENT WHERE Order_ID IN (99, 100, 101, 102);
-- Thêm đơn hàng dưới giá trị min_voucher -> trigger chặn
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (99, '2024-11-15 10:00:00', 'TECHSALE', '999 Test St', 'processing', 99, 'Shopee Pay', 'processing', 450000, 450000, 50000, 50000, 101); -- User 101

-- Thêm đơn hàng nằm trong min-max voucher -> hợp lệ
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (100, GETDATE(), 'TECHSALE', 'Test St', 'processing', 100, 'COD', 'processing', 5500000, 6000000, 0, 500000, 101);

-- Thêm đơn hàng không sử dụng voucher -> trigger để đi qua
INSERT INTO ORDER_PAYMENT (Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)
    VALUES (101, GETDATE(), NULL, 'Test St', 'processing', 101, 'COD', 'processing', 100000, 100000, 0, 0, 101);

-- Update giá trị đơn đã tạo < min_voucher -> trigger chặn
UPDATE ORDER_PAYMENT
SET Product_value = 100000, Payed_value = 100000
WHERE Order_ID = 100;





-- Test Trigger 9: Check product rating update


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
EXEC SP_Get_Potential_Vip_Users 
    @Year = 2025, 
    @Min_Spending = 100000000;
GO

-- ===================================================
--phần của dũng
-- Khối lệnh dùng để test các hàm, muốn kiểm tra tham số nào của sản phẩm thì thêm  vào tập kết quả cuối cùng, và group by
DECLARE @CUSTID INT = 110;
DECLARE @LIMIT INT = 10;

-- Tạo và hiển thị bảng kiểm tra
WITH PurchasedCategories AS (
    SELECT DISTINCT p.C_ID
    FROM PRODUCT p
    INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
    INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
    INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
    INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
    WHERE op.User_ID = @CUSTID AND op.Order_Status = 'completed'
),
AllProducts AS (
    -- Priority 3: Buy Again (1008, 1011)
    SELECT DISTINCT p.Product_ID, 3 AS Priority
    FROM PRODUCT p
    INNER JOIN VARIANT v ON p.Product_ID = v.P_ID
    INNER JOIN ORDER_ITEM oi ON v.Variant_ID = oi.Variant_ID
    INNER JOIN SHIPMENT_PACKAGE sp ON oi.Shipment_ID = sp.Shipment_ID
    INNER JOIN ORDER_PAYMENT op ON sp.Order_ID = op.Order_ID
    WHERE op.User_ID = @CUSTID AND op.Order_Status = 'completed' AND p.Product_Status = 'for_sale'
    
    UNION ALL
    
    -- Priority 2: Cross-Category (Sản phẩm cùng C_ID 12, 13)
    SELECT p.Product_ID, 2 AS Priority
    FROM PRODUCT p
    WHERE p.C_ID IN (SELECT C_ID FROM PurchasedCategories) AND p.Product_Status = 'for_sale'
    
    UNION ALL
    
    -- Priority 1: Top Rated
    SELECT TOP 20 Product_ID, 1 AS Priority
    FROM PRODUCT
    WHERE Product_Status = 'for_sale' AND Average_Rating IS NOT NULL
    ORDER BY Average_Rating DESC, Total_Sales DESC
)
-- Tập kết quả cuối cùng (MAX Priority, sắp xếp và giới hạn)
SELECT TOP (@LIMIT)
    ap.Product_ID,
    MAX(ap.Priority) AS Final_Priority,
    p.Product_name,
	p.C_ID,
	p.Average_Rating
FROM AllProducts ap
JOIN PRODUCT p ON ap.Product_ID = p.Product_ID
GROUP BY ap.Product_ID, p.Product_name, p.C_ID, p.Average_Rating
ORDER BY Final_Priority DESC, ap.Product_ID;

--====================================================--

-- TEST HAM 1: PRODUCT_RECOMMENDATION_ENGINE
DECLARE @RecResult1 NVARCHAR(MAX);
-- Customer 107 đã mua (Headphones, Dress). Category đã mua: 12, 13.
SET @RecResult1 = dbo.ProductRecommendationEngine(107, 4); 
SELECT @RecResult1 AS Recommendation_Result_C107;
GO

--- TEST 2: Customer 110 đã mua Novel (1023). Category đã mua: 6, 7.
DECLARE @RecResult2 NVARCHAR(MAX);
-- Product 1024 (Self-Help Book) thuộc C_ID 7 -> Priority 2.
SET @RecResult2 = dbo.ProductRecommendationEngine(110, 5);
SELECT @RecResult2 AS Recommendation_Result_C110;
GO

--- TEST 3: Kiểm tra Customer ID không tồn tại
DECLARE @RecResult3 NVARCHAR(MAX);
-- Sử dụng UserID 9999 (không tồn tại trong CUSTOMER)
SET @RecResult3 = dbo.ProductRecommendationEngine(9999, 5); 
SELECT @RecResult3 AS Recommendation_Result_C9999;
GO

--- TEST 4: KIỂM TRA GIỚI HẠN MẶC ĐỊNH (@limitRange = NULL)
DECLARE @RecResult4 NVARCHAR(MAX);
-- Truyền giá trị NULL cho @limitRange
SET @RecResult4 = dbo.ProductRecommendationEngine(107, NULL); 
SELECT @RecResult4 AS Recommendation_Result_Limit_NULL;
GO

--- TEST 5: KIỂM TRA GIỚI HẠN MẶC ĐỊNH (@limitRange = 0)
DECLARE @RecResult5 NVARCHAR(MAX);
-- Truyền giá trị 0 cho @limitRange
SET @RecResult5 = dbo.ProductRecommendationEngine(107, 0); 
SELECT @RecResult5 AS Recommendation_Result_Limit_ZERO;
GO

-- ===================================================
-- TEST HAM 2: CalculateProductAverageRating
-- ===================================================

-- TEST 1: Lỗi: Product ID không hợp lệ (<= 0). Mong đợi: -2
SELECT dbo.CalculateProductAverageRating(0, '2025-11-01', '2025-12-31') AS Result_Error_Minus2;
GO

-- TEST 2: Lỗi: Product ID không tồn tại (Ví dụ: 99999). Mong đợi: -1
SELECT dbo.CalculateProductAverageRating(99999, '2025-11-01', '2025-12-31') AS Result_Error_Minus1;
GO

-- TEST 3: Lỗi: Thiếu tham số ngày (EndDate = NULL). Mong đợi: -3
SELECT dbo.CalculateProductAverageRating(1004, '2025-11-01', NULL) AS Result_Error_Minus3;
GO

-- TEST 4: Lỗi: Logic ngày (StartDate > EndDate). Mong đợi: -4
SELECT dbo.CalculateProductAverageRating(1004, '2025-12-31', '2025-11-01') AS Result_Error_Minus4;
GO

-- TEST 5: Lỗi: Khoảng thời gian tối thiểu (< 30 ngày). Mong đợi: -5
SELECT dbo.CalculateProductAverageRating(1004, '2025-11-01', '2025-11-15') AS Result_Error_Minus5;
GO

-- Test 6: Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1008, '2025-09-15', '2025-12-15') AS Result;
GO

-- Test 7 : Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1016, '2025-09-15', '2025-12-15') AS Result;
GO

-- Test 8: Tính điểm đánh giá trung bình hợp lệ
SELECT dbo.CalculateProductAverageRating(1023, '2025-10-15', '2025-12-15') AS Result;
GO