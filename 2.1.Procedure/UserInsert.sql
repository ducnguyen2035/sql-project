USE [QL_SHOPEE_BTL]
GO
CREATE OR ALTER   PROCEDURE [dbo].[usp_User_Insert]
	@ID_number VARCHAR(12),
    @Phone_number VARCHAR(10),
    @Email VARCHAR(255),
    @Full_name VARCHAR(100),
    @Gender VARCHAR(10)=null,
    @Birthday DATE=null,
    @Account_status VARCHAR(50)=null,
    @Entity_ID INT =1
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @NewUserID int;
	begin try
        begin transaction;
        if OBJECT_ID(N'dbo.[USER]') is null
            throw 53000,'Target table dbo.[USER] does not exist.',1;
        if @ID_number is null 
            throw 53001,'ID_number is required',1;
        if @ID_number is not null and exists(select 1 from dbo.[USER] where ID_number = @ID_number)
            throw 53002,'ID_number already exists.', 1;
        if @ID_number is not null
        begin
            if LEN(@ID_number) <> 12
               OR @ID_number NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            throw 53003,'ID_number must be exactly 12 digits.', 1;
        end
        if @Phone_number is null
            throw 53004,'Phone_number is required',1;
        if @Phone_number is not null and exists(select 1 from dbo.[USER] where Phone_number = @Phone_number)
            throw 53005,'Phone_number already exist.',1;
        if @Phone_number is not null
        begin   
            if len(@Phone_number)<>10
                or left(@Phone_number,1)<>'0'
                or @Phone_number not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            throw 53006,'Invalid Phone_number, Phone_number must be exactly 10 digits and start with 0.', 1;   
        end
        if @Email is null
            throw 53007,'Email is required',1;
        if @Email is not null and exists(select 1 from dbo.[USER] where Email = @Email)
            throw 53008,'Email already exist.',1;
        if @Email is not null
        begin
            if charindex('@', @Email) = 0
                throw 53009, 'Email must contain ''@'' ', 1;
        end
        if @Email is not null
        begin 
            if charindex(' ', @Email) > 0
                throw 53010,'Email must not contain spaces.',1;
        end
        if @Full_name is null or len(Ltrim(Rtrim(@Full_name)))=0
            throw 53011,'Full_name is required',1;
        if @Full_name is not null and exists(select 1 from dbo.[USER] where Full_name = @Full_name)
            throw 53012,'Full_name already exist',1;
        if @Gender not in ('Other','Female','Male')
            throw 53013,'Gender must belong to one of three:Other, Female, Male',1;
        if @Birthday is not null
        begin
            if @Birthday > cast(getdate()as date)
                THROW 53014,'Birthday cannot be in the future.', 1;
            DECLARE @Age int;
            set @Age = datediff(year,@Birthday,getdate())
            - case when dateadd(year,datediff(year,@Birthday,getdate()),@Birthday) > getdate() then 1 else 0 end;
            if @Age < 0 or @Age > 150
                THROW 53015,'Age must be between 0 and 150.', 1;
        end
        if @Account_status not in('restricted','warning','active')
            throw 53016,'Account status must belong to one of three status:restricted, warning, active',1;
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
