USE [QL_SHOPEE_BTL]
GO
CREATE OR ALTER   PROCEDURE [dbo].[usp_User_Update]
    @User_ID INT,
    @ID_number VARCHAR(50) =null,
    @Phone_number VARCHAR(50)=null ,
    @Email VARCHAR(255)=null ,
    @Full_name VARCHAR(100)=null,
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
        if @ID_number is not null
        begin
            if LEN(@ID_number) <> 12
            OR @ID_number NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                throw 53103,'ID_number must be exactly 12 digits.', 1;
        end
        if @ID_number is not null
        begin
            if exists(select 1 from dbo.[USER] where ID_number = @ID_number and User_ID <> @User_ID)
                throw 53104,'ID_number already used by another user',1;
        end
        if @Phone_number is not null
        begin   
            if left(@Phone_number,1)<>'0'
                throw 53105,'Invalid Phone_number, Phone_number must start with 0.', 1;   
        end
        if  @Phone_number is not null
            if len(@Phone_number)<>10
                throw 53106,'Invalid Phone_number, Phone_number must be exactly 10 digits ', 1;
        if @Phone_number is not null
        begin   
            if @Phone_number not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                throw 53107,'Invalid Phone_number, Phone_number must contain only digit.', 1;   
        end
        if @Phone_number is not null
        begin   
            if left(@Phone_number,1)<>'0'
                throw 53108,'Invalid Phone_number, Phone_number must start with 0.', 1;   
        end
        if @Phone_number is not null
        begin
            if exists(select 1 from dbo.[USER] where Phone_number = @Phone_number and User_ID <> @User_ID)
                throw 53109,'Phone_number already used by another user',1;
        end
        if @Email is not null
        begin
            if charindex('@', @Email) = 0
                throw 53110, 'Email must contain ''@'' ', 1;
        end
        if @Email is not null
        begin 
            if charindex(' ', @Email) > 0
                throw 53111,'Email must not contain spaces.',1;
        end
        if @Email is not null
        begin
            if exists(select 1 from dbo.[USER] where Email = @Email and User_ID <> @User_ID)
                throw 53112,'Email already used by another user',1;
        end
        if @Full_name is not null
        begin
            if replace(@Full_name,' ','') like '%[^A-Za-z]%'
                throw 53113,'Full_name must contain only letters and single spaces between words.',1;
        end
        if datalength(@Full_name)<>datalength(ltrim(rtrim(@Full_name)))
            throw 53114,'Full_name must not have leading or trailing spaces.',1;
        if charindex('  ', @Full_name) > 0
            throw 53115,'Full_name must not contain more than one space between words.',1;
        if @Gender is not null and @Gender not in ('Other','Female','Male')
            throw 53116,'Invalid gender, gender must belong to one of three:Other, Female, Male',1;
        if @Birthday is not null
        begin
            if @Birthday > cast(getdate()as date)
                throw 53117,'Birthday cannot be in the future.', 1;
            declare @Age int;
            set @Age = datediff(year,@Birthday,getdate())
            - case when dateadd(year,datediff(year,@Birthday,getdate()),@Birthday) > getdate() then 1 else 0 end;
            if @Age < 0 or @Age > 150
                throw 53118,'Age must be between 0 and 150.', 1;
        end
        if @Account_status is not null and @Account_status not in('restricted','warning','active')
            throw 53119,'Invalid account status, account status must belong to one of three status:restricted, warning, active',1;
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
end;