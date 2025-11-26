USE [QL_SHOPEE_BTL]
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Delete]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[usp_User_Delete]
    @User_ID INT,
    @Force BIT =0
AS
BEGIN
	SET NOCOUNT ON;
    begin try
        begin transaction
        if @User_ID is null
            throw 53020,'User_ID is required',1;
        if not exists(select 1 from dbo.[USER] where User_ID=@User_ID)
            throw 53021,'User not found',1;
        if @Force =0 
            begin
            if exists(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.[USER]')
            )
            throw 53022,'Dependent foreign keys reference dbo.[USER] -- use Force=1 to override', 1;
            end
        delete from dbo.[USER] where User_ID=@User_ID;
	    commit transaction;
        SELECT @User_ID AS DeletedUserID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;
