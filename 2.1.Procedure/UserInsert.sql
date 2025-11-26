USE [QL_SHOPEE_BTL]
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Insert]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
I.User
*/
ALTER   PROCEDURE [dbo].[usp_User_Insert]
	@ID_number VARCHAR(50)=null,
    @Phone_number VARCHAR(20)=null,
    @Email VARCHAR(255)=null,
    @Full_name VARCHAR(100),
    @Gender VARCHAR(10)=null,
    @Birthday DATE=null,
    @Account_status VARCHAR(50)=null,
    @Entity_ID INT =null
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @NewUserID int;
	begin try
        begin transaction;
        if @Full_name is null or len(Ltrim(Rtrim(@Full_name)))=0
            throw 53000,'Full_name is required',1;
        if OBJECT_ID(N'dbo.[USER]') is null
            throw 53001,'Target table dbo.[USER] does not exist.',1;
        if @Entity_ID is not null and OBJECT_ID(N'dbo.MANAGEMENT_ENTITY')is null
            throw 53002,'Reference table dbo.MANAGEMENT_ENTITY does not exist.',1;
        if @Entity_ID is not null and not exists(select 1 from dbo.MANAGEMENT_ENTITY where Entity_ID=@Entity_ID)
            throw 53003,'Entity_ID does not reference existing MANAGEMENT_ENTITY.',1;
        if @ID_number is not null and exists(select 1 from dbo.[USER] where ID_number = @ID_number)
            throw 53004,'ID_number already exists.', 1;
        if @Phone_number is not null and exists(select 1 from dbo.[USER] where Phone_number = @Phone_number)
            throw 53005,'Phone_number already exist.',1;
        if @Email is not null and exists(select 1 from dbo.[USER] where Email = @Email)
            throw 53006,'Email already exist.',1;
        if @Gender not in ('Other','Female','Male')
            throw 53007,'Gender must belong to one of three:Other,Female,Male',1;
        if @Account_status not in('restricted','warning','active')
            throw 53008,'Account status must belong to one of three status:restricted,warning,active',1;
        SELECT @NewUserID = ISNULL(MAX(User_ID), 0) + 1 FROM dbo.[USER];
        INSERT INTO dbo.[USER] (User_ID,ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
        VALUES (@NewUserID,@ID_number, @Phone_number, @Email, @Full_name, @Gender, @Birthday, @Account_status, @Entity_ID);
        COMMIT TRANSACTION;
    end try
    begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;
