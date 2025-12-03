USE [QL_SHOPEE_BTL];
GO

-- Thủ tục thêm vào bảng user
CREATE OR ALTER   PROCEDURE [dbo].[usp_User_Insert]
	@ID_number VARCHAR(50)=null,
    @Phone_number VARCHAR(50)=null,
    @Email VARCHAR(255)=null,
    @Full_name VARCHAR(100)=null,
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
            if left(@Phone_number,1)<>'0'
                throw 53006,'Invalid Phone_number, Phone_number must start with 0.', 1;   
        end
        if  @Phone_number is not null
            if len(@Phone_number)<>10
                throw 53007,'Invalid Phone_number, Phone_number must be exactly 10 digits ', 1;
        if @Phone_number is not null
        begin   
            if @Phone_number not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                throw 53008,'Invalid Phone_number, Phone_number must contain only digit.', 1;   
        end
        if @Email is null
            throw 53009,'Email is required',1;
        if @Email is not null and exists(select 1 from dbo.[USER] where Email = @Email)
            throw 53010,'Email already exist.',1;
        if @Email is not null
        begin
            if charindex('@', @Email) = 0
                throw 53011, 'Email must contain ''@'' ', 1;
        end
        if @Email is not null
        begin 
            if charindex(' ', @Email) > 0
                throw 53012,'Email must not contain spaces.',1;
        end
        if @Full_name is null or len(ltrim(rtrim(@Full_name)))=0
            throw 53013,'Full_name is required',1;
        if @Full_name is not null
        begin
            if replace(@Full_name,' ','') like '%[^A-Za-z]%'
                throw 53014,'Full_name must contain only letters and single spaces between words.',1;
        end
        if datalength(@Full_name)<>datalength(ltrim(rtrim(@Full_name)))
            throw 53015,'Full_name must not have leading or trailing spaces.',1;
        if charindex('  ',@Full_name)>0
            throw 53016,'Full_name must not contain more than one space between words.',1;
        if @Gender not in ('Other','Female','Male')
            throw 53017,'Invalid Gender, gender must belong to one of three:Other, Female, Male',1;
        if @Birthday is not null
        begin
            if @Birthday > cast(getdate()as date)
                throw 53018,'Birthday cannot be in the future.', 1;
            declare @Age int;
            set @Age = datediff(year,@Birthday,getdate())
            - case when dateadd(year,datediff(year,@Birthday,getdate()),@Birthday) > getdate() then 1 else 0 end;
            if @Age < 0 or @Age > 150
                throw 53019,'Age must be between 0 and 150.', 1;
        end
        if @Account_status not in('restricted','warning','active')
            throw 53020,'Invalid account status, account status must belong to one of three status:restricted, warning, active',1;
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
GO
--- Thủ tục cập nhật bảng user
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
GO
--- Thủ tục xóa user
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
GO
-- ===================================================
--  THỦ TỤC 1: LẤY LỊCH SỬ ĐƠN HÀNG CHI TIẾT CỦA MỘT SHOP 

IF OBJECT_ID('SP_Get_Shop_Order_History', 'P') IS NOT NULL
    DROP PROCEDURE SP_Get_Shop_Order_History;
GO 

CREATE PROCEDURE SP_Get_Shop_Order_History
    @Shop_ID INT --add date
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.Order_ID,
        o.Order_Date,
        sp.Tracking_Number,
        (
            SELECT TOP 1 ss.Status_Name
            FROM SHIPMENT_STATUS ss
            WHERE ss.Shipment_ID = sp.Shipment_ID
            ORDER BY ss.Updated_time DESC, ss.Status_ID DESC
        ) AS Current_Shipment_Status,
        v.Variant_Name,
        oi.Quantity,
        oi.Price_at_Purchase,
        Final_Item_Price AS Total_Item_Amount
    FROM 
        ORDER_PAYMENT o

    JOIN 
        SHIPMENT_PACKAGE sp ON o.Order_ID = sp.Order_ID
    JOIN 
        ORDER_ITEM oi ON sp.Shipment_ID = oi.Shipment_ID
    JOIN 
        VARIANT v ON oi.Variant_ID = v.Variant_ID
    JOIN 
        PRODUCT p ON v.P_ID = p.Product_ID
    WHERE 
        p.Shop_ID = @Shop_ID
    ORDER BY 
        o.Order_Date DESC, o.Order_ID ASC; 
END;
GO

--  THỦ TỤC 2

IF OBJECT_ID('SP_Get_Potential_Vip_Users', 'P') IS NOT NULL
    DROP PROCEDURE SP_Get_Potential_Vip_Users;
GO

CREATE PROCEDURE SP_Get_Potential_Vip_Users
    @Year INT, 
    @Min_Spending DECIMAL(15,2)
AS
BEGIN
    SET NOCOUNT ON;


    -- [Ràng buộc 1]: Mức chi tiêu phải là số dương
    IF @Min_Spending <= 0
    BEGIN
        RAISERROR('Lỗi tham số: Mức chi tiêu tối thiểu (@Min_Spending) phải lớn hơn 0.', 16, 1);
        RETURN;
    END

    -- [Ràng buộc 2]: Năm báo cáo phải hợp lý (Từ 2015 đến hiện tại)
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    
    IF @Year < 2015 OR @Year > @CurrentYear
    BEGIN
        DECLARE @Err VARCHAR(200) = 'Lỗi tham số: Năm báo cáo (@Year) phải từ 2015 đến năm hiện tại (' + CAST(@CurrentYear AS VARCHAR) + ').';
        RAISERROR(@Err, 16, 1);
        RETURN;
    END
    
    SELECT 
        u.User_ID,
        u.Full_name,
        u.Email,
        COUNT(o.Order_ID) AS [Tong_So_Don],         -- 1. Aggregate Function (COUNT)
        SUM(o.Payed_value) AS [Tong_Chi_Tieu]       -- 1. Aggregate Function (SUM)
    FROM 
        [USER] u
    JOIN 
        ORDER_PAYMENT o ON u.User_ID = o.User_ID    -- 6. Liên kết 2 bảng trở lên ([USER] và ORDER_PAYMENT)
    WHERE 
        o.Order_Status = 'completed'                -- 4. WHERE
        AND YEAR(o.Order_Date) = @Year              -- 4. WHERE
    GROUP BY 
        u.User_ID, u.Full_name, u.Email             -- 2. GROUP BY
    HAVING 
        SUM(o.Payed_value) >= @Min_Spending         -- 3. HAVING
    ORDER BY 
        [Tong_Chi_Tieu] DESC;                       -- 5. ORDER BY
END;
GO