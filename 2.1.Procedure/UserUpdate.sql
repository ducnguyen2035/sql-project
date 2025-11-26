USE [QL_SHOPEE_BTL]
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Update]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[usp_User_Update]
    @User_ID INT,
    @ID_number VARCHAR(50) = NULL,
    @Phone_number VARCHAR(20) = NULL,
    @Email VARCHAR(255) = NULL,
    @Full_name VARCHAR(100) = NULL,
    @Gender VARCHAR(10) = NULL,
    @Account_status VARCHAR(50) = NULL,
    @Entity_ID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
    begin try
        begin transaction
        if @User_ID is null
            throw 53010,'User_ID is required',1;
        if OBJECT_ID(N'dbo.[USER]')is null
            throw 53011,'Target table dbo.[USER] does not exist',1;
        if not exists(select 1 from dbo.[USER] where User_ID=@User_ID)
            throw 53012,'User not found',1;
        if @Entity_ID IS NOT NULL AND OBJECT_ID(N'dbo.MANAGEMENT_ENTITY') IS NULL
            throw 53013, 'Reference table dbo.MANAGEMENT_ENTITY does not exist', 1;
        if @Entity_ID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.MANAGEMENT_ENTITY WHERE Entity_ID = @Entity_ID)
            throw 53014, 'Entity_ID does not reference existing MANAGEMENT_ENTITY', 1;
        if @Gender not in ('Other','Female','Male')
            throw 53015,'Gender must belong to one of three:Other,Female,Male',1;
        if @Account_status not in('restricted','warning','active')
            throw 53016,'Account status must belong to one of three status:restricted,warning,active',1;
        Update dbo.[USER]
        SET
            ID_number = COALESCE(@ID_number, ID_number),
            Phone_number = COALESCE(@Phone_number, Phone_number),
            Email = COALESCE(@Email, Email),
            Full_name = COALESCE(@Full_name, Full_name),
            Gender = COALESCE(@Gender, Gender),
            Birthday = COALESCE(@Birthday, Birthday),
            Account_status = COALESCE(@Account_status, Account_status),
            Entity_ID = COALESCE(@Entity_ID, Entity_ID)
        WHERE User_ID = @User_ID;
	commit transaction;
    SELECT @User_ID AS UpdatedUserID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;
