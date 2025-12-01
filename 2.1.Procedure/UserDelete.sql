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
        if exists (select 1 from dbo.CUSTOMER where User_ID = @User_ID) and exists(select 1 from dbo.ORDER_PAYMENT where User_ID = @User_ID)
            throw 53202, 'Cannot delete:User is a customer who also has orders.', 1;
        if exists (select 1 from dbo.SHOP_SELL where User_ID = @User_ID)
            throw 53203, 'Cannot delete:User is a shop owner.', 1;
        if exists (select 1 from dbo.CUSTOMER where User_ID = @User_ID)
            throw 53204, 'Cannot delete:User is a customer who has no order.', 1;
        delete from dbo.BANK_ACCOUNT where User_ID = @User_ID;
        delete from dbo.SHOP_STAFF where User_ID = @User_ID;
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