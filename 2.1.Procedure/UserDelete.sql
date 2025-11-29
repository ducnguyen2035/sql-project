USE [QL_SHOPEE_BTL]
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_User_Delete]
    @User_ID INT
AS
BEGIN
	SET NOCOUNT ON;
    begin try
        begin transaction
        if @User_ID is null
            throw 53200,'User_ID is required',1;
        if not exists(select 1 from dbo.[USER] where User_ID=@User_ID)
            throw 53201,'User not found',1;
        delete from dbo.[ORDER_PAYMENT] where User_ID = @User_ID;
        delete from dbo.[SHIPMENT_PACKAGE] where Customer_ID = @User_ID;
        delete from dbo.[BANK_ACCOUNT] where User_ID = @User_ID;
        delete from dbo.[CUSTOMER] where User_ID = @User_ID;
        declare @ShopIDs table(Shop_ID INT);
        insert into @ShopIDs(Shop_ID)
        SELECT Shop_ID from dbo.SHOP_SELL where User_ID = @User_ID;
        delete oi
        from dbo.ORDER_ITEM oi
        join dbo.VARIANT v on oi.Variant_ID = v.Variant_ID
        join dbo.PRODUCT pr on v.P_ID = pr.Product_ID
        join @ShopIDs soi on pr.Shop_ID = soi.Shop_ID;
        delete pc
        from dbo.PRODUCT_CUSTOMER pc
        join dbo.PRODUCT pr_pc on pc.Product_ID = pr_pc.Product_ID
        join @ShopIDs spc on pr_pc.Shop_ID = spc.Shop_ID;
        delete ppp
        from dbo.PROMOTION_PROGRAM_PRODUCT ppp
        join dbo.PRODUCT pr_ppp on ppp.Product_ID = pr_ppp.Product_ID
        join @ShopIDs sppp on pr_ppp.Shop_ID = sppp.Shop_ID;
        delete pps
        from dbo.PROMOTION_PROGRAM_SHOP pps
        join @ShopIDs spps on pps.Shop_ID = spps.Shop_ID;
        delete vs
        from dbo.VOUCHER_SHOP vs
        join @ShopIDs svs on vs.Shop_ID = svs.Shop_ID;
        delete sps
        from dbo.SERVICE_PACKAGE_SHOP sps
        join @ShopIDs ssps on sps.Shop_ID = ssps.Shop_ID;
        delete v
        from dbo.VARIANT v
        join dbo.PRODUCT pr on v.P_ID = pr.Product_ID
        join @ShopIDs sv on pr.Shop_ID = sv.Shop_ID;
        delete pr
        from dbo.PRODUCT pr
        join @ShopIDs spr on pr.Shop_ID = spr.Shop_ID;
        delete ss
        from dbo.SHOP_STAFF ss
        join @ShopIDs sss on ss.Shop_ID = sss.Shop_ID
        where ss.User_ID = @User_ID or sss.Shop_ID is not null;
        delete from dbo.SHOP_SELL WHERE User_ID = @User_ID;
        delete from dbo.[USER] where User_ID = @User_ID;
        commit transaction;
        select
            @User_ID AS DeletedUserID
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;