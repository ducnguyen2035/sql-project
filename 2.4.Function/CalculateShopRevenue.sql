-- ===================================================
-- HÀM 1: TÍNH DOANH THU CỦA SHOP TRONG KHOẢNG THỜI GIAN
-- ===================================================

USE [QL_SHOPEE_BTL];
GO

create or alter function CalculateShopRevenue (
	-- Các tham số đầu vào ( YÊU CẦU )
	@shopID int,
	@startDate datetime,
	@endDate datetime
)
returns decimal(10,2)
as
begin
	-- Biến lưu kết quả
	declare @totalRevenue decimal(10,2) = 0,
			@itemRevenue decimal(10,2),
			@itemQuantity int,
			@orderDate datetime,
			@orderStatus varchar(50);

	-- Kiểm tra tham số đầu vào ( YÊU CẦU )
	if not exists (	select 1 from SHOP_SELL where Shop_ID = @shopID)
		return -1;	
	if @startDate is null or @endDate is null
		return -2;
	if @startDate > @endDate
		return -3;
	if not exists ( select 1 from PRODUCT where Shop_ID = @shopID)
		return 0;
	-- Khai báo cursor duyệt qua Order Item  ( YÊU CẦU )
	declare revenueCursor cursor fast_forward read_only for
		with
			-- Lọc trước tất cả các Variant_ID thuộc Shop này 
			ShopVariants as (
				select v.Variant_ID
				from VARIANT v
				where v.P_ID in (
					select Product_ID
					from PRODUCT
					where Shop_ID = @shopID
				)
			),
			-- Lọc trước tất cả các Order_ID đã 'completed' trong kỳ
			ValidOrders as (
				select Order_ID
				from ORDER_PAYMENT
				where Order_Status in ('completed')
					and Order_date >= @startDate
					and Order_date <= @endDate
			),
			-- Lọc trước tất cả các Shipment_ID liên quan đến các Order_ID hợp lệ
			ValidShipments as (
				select sp.Shipment_ID
				from SHIPMENT_PACKAGE sp
				where sp.Order_ID in ( select Order_ID from  ValidOrders)
			)
			-- Câu lệnh truy vấn dữ liệu ( YÊU CẦU )
			select 
				oi.Final_Item_Price,
				oi.Quantity
			from ORDER_ITEM oi
			-- Chỉ lấy các Order Item thuộc Variant và Shipment đã lọc
			where oi.Variant_ID in ( select Variant_ID from ShopVariants)
			and oi.Shipment_ID in ( select Shipment_ID from ValidShipments)

	open revenueCursor
	fetch next from revenueCursor into @itemRevenue, @itemQuantity

	-- LOOP ( YÊU CẦU )
	while @@FETCH_STATUS  = 0
	begin
		if @itemRevenue is not null
			set @totalRevenue = @totalRevenue + (@itemRevenue*@itemQuantity)
		fetch next from revenueCursor into @itemRevenue, @itemQuantity
	end
	close revenueCursor
	deallocate revenueCursor
	return @totalRevenue
end
go

