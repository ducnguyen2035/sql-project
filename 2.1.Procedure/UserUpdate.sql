USE [QL_SHOPEE_BTL]
GO
CREATE OR ALTER   PROCEDURE [dbo].[usp_User_Update]
    @User_ID INT,
    @ID_number VARCHAR(12) ,
    @Phone_number VARCHAR(10) ,
    @Email VARCHAR(255) ,
    @Full_name VARCHAR(100),
    @Gender VARCHAR(10) = NULL,
    @Birthday DATE=null,
    @Account_status VARCHAR(50) = NULL,
    @Entity_ID INT = 1
AS
BEGIN
	SET NOCOUNT ON;
    begin try
        begin transaction
        if OBJECT_ID(N'dbo.[USER]')is null
            throw 53100,'Target table dbo.[USER] does not exist',1;
        if @User_ID is null
            throw 53101,'User_ID is required',1;
        if not exists(select 1 from dbo.[USER] where User_ID=@User_ID)
            throw 53102,'User not found',1;
        if @ID_number is null 
            throw 53103,'ID_number is required',1;
        if not exists(select 1 from dbo.[USER] where ID_number=@ID_number)
            throw 53104,'ID_number not found',1;
        if @ID_number is not null
        begin
            if LEN(@ID_number) <> 12
            OR @ID_number NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            throw 53105,'ID_number must be exactly 12 digits.', 1;
        end
        if @ID_number is not null
        begin
            if exists(select 1 from dbo.[USER] where ID_number = @ID_number and User_ID <> @User_ID)
                throw 53106,'ID_number already used by another user',1;
        end
        if @Phone_number is null
            throw 53107,'Phone_number is required',1;
        if not exists(select 1 from dbo.[USER] where Phone_number=@Phone_number)
            throw 53108,'Phone_number not found',1;
        if @Phone_number is not null
        begin   
            if len(@Phone_number)<>10
                or left(@Phone_number,1)<>'0'
                or @Phone_number not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            throw 53109,'Invalid Phone_number, Phone_number must be exactly 10 digits and start with 0.', 1;   
        end
        if @Phone_number is not null
        begin
            if exists(select 1 from dbo.[USER] where Phone_number = @Phone_number and User_ID <> @User_ID)
                throw 53110,'Phone_number already used by another user',1;
        end
        if @Email is null
            throw 53111,'Email is required',1;
        if not exists(select 1 from dbo.[USER] where Email=@Email)
            throw 53112,'Email not found',1;
        if @Email is not null
        begin
            if charindex('@', @Email) = 0
                throw 53113, 'Email must contain ''@'' ', 1;
        end
        if @Email is not null
        begin 
            if charindex(' ', @Email) > 0
                throw 53114,'Email must not contain spaces.',1;
        end
        if @Email is not null
        begin
            if exists(select 1 from dbo.[USER] where Email = @Email and User_ID <> @User_ID)
                throw 53115,'Email already used by another user',1;
        end
        if @Full_name is null or len(Ltrim(Rtrim(@Full_name)))=0
            throw 53116,'Full_name is required',1;
        if not exists(select 1 from dbo.[USER] where @Full_name=@Full_name)
            throw 53117,'@Full_name not found',1;
        if @Gender is not null and @Gender not in ('Other','Female','Male')
            throw 53118,'Gender must belong to one of three:Other,Female,Male',1;
        if @Birthday is not null
        begin
            if @Birthday > cast(getdate()as date)
                throw 53119,'Birthday cannot be in the future.', 1;
            declare @Age int;
            set @Age = datediff(year,@Birthday,getdate())
            - case when dateadd(year,datediff(year,@Birthday,getdate()),@Birthday) > getdate() then 1 else 0 end;
            if @Age < 0 or @Age > 150
                throw 53120,'Age must be between 0 and 150.', 1;
        end
        if @Account_status is not null and @Account_status not in('restricted','warning','active')
            throw 53121,'Account status must belong to one of three status:restricted,warning,active',1;
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
