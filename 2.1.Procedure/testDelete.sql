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
	@User_ID='104'
exec dbo.usp_User_Delete
	@User_ID='105'
exec dbo.usp_User_Delete
	@User_ID='106'
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
