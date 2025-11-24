/*
I.User
*/
CREATE or alter PROCEDURE dbo.usp_User_Insert
	@ID_number VARCHAR(50) = NULL,
    @Phone_number VARCHAR(20) = NULL,
    @Email VARCHAR(255) = NULL,
    @Full_name VARCHAR(100),
    @Gender VARCHAR(10) = NULL,
    @Birthday DATE = NULL,
    @Account_status VARCHAR(50) = 'active',
    @Entity_ID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	begin try
        begin transaction;
        if @Full_name is null or len(Ltrim(Rtrim(@Full_name)))=0
            throw 53000,'Full_name is required',1;
        if OBJECT_ID(N'dbo.[USER]') is null
            throw 53001,'Target table dbo.[USER] does not exist',1;
        if @Entity_ID is not null and OBJECT_ID(N'dbo.MANAGEMENT_ENTITY')is null
            throw 53002,'Reference table dbo.MANAGEMENT_ENTITY does not exist',1;
        if @Entity_ID is not null and not exists(select 1 from dbo.MANAGEMENT_ENTITY where Entity_ID=@Entity_ID)
            throw 53003,'Entity_ID does not reference existing MANAGEMENT_ENTITY',1;
        INSERT INTO dbo.[USER] (ID_number, Phone_number, Email, Full_name, Gender, Birthday, Account_status, Entity_ID)
        VALUES (@ID_number, @Phone_number, @Email, @Full_name, @Gender, @Birthday, @Account_status, @Entity_ID);
        DECLARE @NewUserID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @NewUserID AS InsertedUserID;
    end try
    begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;
GO
CREATE or alter PROCEDURE dbo.usp_User_Update
    @User_ID INT,
    @ID_number VARCHAR(50) = NULL,
    @Phone_number VARCHAR(20) = NULL,
    @Email VARCHAR(255) = NULL,
    @Full_name VARCHAR(100) = NULL,
    @Gender VARCHAR(10) = NULL,
    @Birthday DATE = NULL,
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
GO
CREATE or alter PROCEDURE dbo.usp_User_Delete
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
GO
/*
II.Product
*/
CREATE or alter PROCEDURE dbo.usp_Product_Insert
    @Product_name VARCHAR(255),
    @Description VARCHAR(max)=null,
    @Base_Price decimal(10,2),
    @Total_Sales Int = NULL,
    @Average_Rating decimal(3,2)=null,
    @Base_Image varbinary(max)=null,
    @Product_Status varchar(50)='for_sale',
    @C_ID int=null,
    @Shop_ID int=null
AS
BEGIN
	SET NOCOUNT ON;
	begin try
        begin transaction;
        if @Product_name is null or len(Ltrim(Rtrim(@Product_name)))=0
            throw 53100,'Product_name is required',1;
        if @Base_Price is null or @Base_Price<0
            throw 53101,'Base_Price is required and must be non negative',1;
        if @Product_Status not in ('discontinued','paused','for_sale')
            throw 53102,'Invalid Product_Status,must belong to one of three roles: discontinued,paused,for_sale',1;
        if @C_ID is not null 
            begin  
                if OBJECT_ID(N'dbo.CATEGORY')is null or not exists(select 1 from dbo.CATEGORY where Category_ID=@C_ID)
                    throw 53103,'C_ID does not reference existing CATEGORY',1;
            end
        if @Shop_ID is not null 
            begin   
                if OBJECT_ID(N'dbo.SHOP_SELL')is null or not exists(select 1 from dbo.SHOP_SELL where Shop_ID=@Shop_ID)
                    throw 53104,'Shop_ID does not reference existing SHOP_SELL',1;
            end
        INSERT INTO dbo.PRODUCT (Product_name, Description, Base_Price, Total_Sales, Average_Rating, Base_Image, Product_Status, C_ID, Shop_ID)
        VALUES (@Product_name, @Description, @Base_Price, @Total_Sales, @Average_Rating, @Base_Image, @Product_Status, @C_ID, @Shop_ID);
        DECLARE @InsertedProductID INT = CONVERT(INT, SCOPE_IDENTITY());
        commit transaction;
        select @InsertedProductID as InsertedProductID;
    end try
    begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
END;
GO
create or alter procedure dbo.usp_Product_Update
    @Product_ID INT,
    @Product_Name VARCHAR(255)=null,
    @Description VARCHAR(max)=null,
    @Base_Price decimal(10,2)=null,
    @Total_Sales Int = NULL,
    @Average_Rating decimal(3,2)=null,
    @Base_Image varbinary(max)=null,
    @Product_Status varchar(50)=null,
    @C_ID int=null,
    @Shop_ID int=null
as 
begin
set nocount on;
    begin try
        begin transaction;
    if @Product_ID is null
        throw 53110,'Product_ID is required',1;
    IF OBJECT_ID(N'dbo.PRODUCT') IS NULL
        throw 53111, 'Target table dbo.PRODUCT does not exist', 1;
    if not exists(select 1 from dbo.PRODUCT where Product_ID=@Product_ID)
        throw 53112,'Product not found',1;
    if @Base_Price is not null and @Base_Price<0
        throw 53113,'base price must be non negative',1;
    if @Product_Status is not null and @Product_Status not in ('discontinued','paused','for_sale')
        throw 53114,'Invalid Product_Status,must belong to one of three roles: discontinued,paused,for_sale',1;
    if @C_ID is not null 
            begin  
                if OBJECT_ID(N'dbo.CATEGORY')is null or not exists(select 1 from dbo.CATEGORY where Category_ID=@C_ID)
                    throw 53115,'C_ID does not reference existing CATEGORY',1;
            end
    if @Shop_ID is not null 
            begin   
                if OBJECT_ID(N'dbo.SHOP_SELL')is null or not exists(select 1 from dbo.SHOP_SELL where Shop_ID=@Shop_ID)
                    throw 53116,'Shop_ID does not reference existing SHOP_SELL',1;
            end
    UPDATE dbo.PRODUCT
    SET
        Product_Name=COALESCE(@Product_Name,Product_Name),
        Description = COALESCE(@Description,Description),
        Base_Price = COALESCE(@Base_Price, Base_Price),
        Total_Sales = COALESCE(@Total_Sales, Total_Sales),
        Average_Rating = COALESCE(@Average_Rating, Average_Rating),
        Base_Image = CASE WHEN @Base_Image IS NULL THEN Base_Image ELSE @Base_Image END,
        Product_Status = COALESCE(@Product_Status, Product_Status),
        C_ID = COALESCE(@C_ID, C_ID),
        Shop_ID = COALESCE(@Shop_ID, Shop_ID)
    WHERE Product_ID = @Product_ID;
    commit transaction;
    SELECT @Product_ID AS UpdatedProductID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_Product_Delete
    @Product_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Product_ID is null 
			throw 53120,'Product_ID is required',1;
        -- check record exists
		if not exists(SELECT 1 FROM dbo.PRODUCT WHERE Product_ID = @Product_ID)
            throw 53121, 'Product not found', 1;
        -- check FK dependents and block when Force=0
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.PRODUCT')
			)
			throw 53122,'Cannot delete: dependent foreign key constraints reference dbo.PRODUCT. Use Force=1 to override.', 1;
		end
        -- delete
		DELETE FROM dbo.PRODUCT WHERE Product_ID=@Product_ID;
        commit transaction;
        SELECT @Product_ID as DeletedProductID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
III.Shop_Sell
*/
CREATE OR ALTER PROCEDURE dbo.usp_ShopSell_Insert
    @Shop_name VARCHAR(255),
    @Shop_type VARCHAR(100) = NULL,
    @Description VARCHAR(MAX) = NULL,
    @Operation_Status VARCHAR(50) = 'open',
    @Logo VARBINARY(MAX) = NULL,
    @Follower INT = null,
    @Rating DECIMAL(3,2) = NULL,
    @Chat_response_rate DECIMAL(5,2) = NULL,
    @Address VARCHAR(max) = NULL,
    @Bank_Account VARCHAR(100) = NULL,
    @Email_for_Online_Bills VARCHAR(255) = NULL,
    @Stock_address VARCHAR(max) = NULL,
    @Tax_code VARCHAR(50) = NULL,
    @Type_of_Business VARCHAR(100) = NULL,
    @User_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @Shop_name IS NULL OR LEN(LTRIM(RTRIM(@Shop_name))) = 0
            throw 53200, 'Shop_name is required', 1;
        if @User_ID IS NOT NULL AND (OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID))
            throw 53201, 'User_ID does not reference existing [USER]', 1;
        if @Shop_type not in ('normal','preferred','Shopee Mall')
            throw 53202,'Invalid shop type,must belong to one of three types:normal,preferred,Shopee Mall',1;      
        INSERT INTO dbo.SHOP_SELL (Shop_name, Shop_type, Description, Operation_Status, Logo, Follower, Rating, Chat_response_rate, Address, Bank_Account, Email_for_Online_Bills, Stock_address, Tax_code, Type_of_Business, User_ID)
        VALUES (@Shop_name, @Shop_type, @Description, @Operation_Status, @Logo, @Follower, @Rating, @Chat_response_rate, @Address, @Bank_Account, @Email_for_Online_Bills, @Stock_address, @Tax_code, @Type_of_Business, @User_ID);
        DECLARE @InsertedShopID INT = CONVERT(INT, SCOPE_IDENTITY());
        commit transaction;
        SELECT @InsertedShopID AS InsertedShopID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_ShopSell_Update
    @Shop_ID INT,
    @Shop_name VARCHAR(255) = NULL,
    @Shop_type VARCHAR(100) = NULL,
    @Description VARCHAR(MAX) = NULL,
    @Operation_Status VARCHAR(50) = NULL,
    @Logo VARBINARY(MAX) = NULL,
    @Follower INT = NULL,
    @Rating DECIMAL(5,2) = NULL,
    @Chat_response_rate DECIMAL(5,2) = NULL,
    @Address VARCHAR(500) = NULL,
    @Bank_Account VARCHAR(100) = NULL,
    @Email_for_Online_Bills VARCHAR(255) = NULL,
    @Stock_address VARCHAR(500) = NULL,
    @Tax_code VARCHAR(100) = NULL,
    @Type_of_Business VARCHAR(100) = NULL,
    @User_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @Shop_ID IS NULL
            throw 53210, 'Shop_ID is required', 1;
        if OBJECT_ID(N'dbo.SHOP_SELL') IS NULL
            throw 53211, 'Target table dbo.SHOP_SELL does not exist', 1;
        if NOT EXISTS(SELECT 1 FROM dbo.SHOP_SELL WHERE Shop_ID = @Shop_ID)
            throw 53212, 'Shop not found', 1;
        if @User_ID IS NOT NULL AND (OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID))
            throw 53213, 'User_ID does not reference existing [USER]', 1;
        UPDATE dbo.SHOP_SELL
        SET
            Shop_name = COALESCE(@Shop_name, Shop_name),
            Shop_type = COALESCE(@Shop_type, Shop_type),
            Description = COALESCE(@Description, Description),
            Operation_Status = COALESCE(@Operation_Status, Operation_Status),
            Logo = CASE WHEN @Logo IS NULL THEN Logo ELSE @Logo END,
            Follower = COALESCE(@Follower, Follower),
            Rating = COALESCE(@Rating, Rating),
            Chat_response_rate = COALESCE(@Chat_response_rate, Chat_response_rate),
            Address = COALESCE(@Address, Address),
            Bank_Account = COALESCE(@Bank_Account, Bank_Account),
            Email_for_Online_Bills = COALESCE(@Email_for_Online_Bills, Email_for_Online_Bills),
            Stock_address = COALESCE(@Stock_address, Stock_address),
            Tax_code = COALESCE(@Tax_code, Tax_code),
            Type_of_Business = COALESCE(@Type_of_Business, Type_of_Business),
            User_ID = COALESCE(@User_ID, User_ID)
        WHERE Shop_ID = @Shop_ID;
        commit transaction;
        SELECT @Shop_ID AS UpdatedShopID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_ShopSell_Delete
    @Shop_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @Shop_ID IS NULL
            throw 53220,'Shop_ID is required', 1;
        if NOT EXISTS(SELECT 1 FROM dbo.SHOP_SELL WHERE Shop_ID = @Shop_ID)
            throw 53221,'Shop not found', 1;
        if @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.SHOP_SELL')
            )
                THROW 53222, 'Dependent foreign keys reference dbo.SHOP_SELL -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.SHOP_SELL WHERE Shop_ID = @Shop_ID;
        commit transaction;
        SELECT @Shop_ID AS DeletedShopID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
/*
IV.Customer
*/
CREATE OR ALTER PROCEDURE dbo.usp_Customer_Insert
    @User_ID INT,
    @Total_Order INT = null,
    @Total_Spending DECIMAL(12,2) = 0.00,
    @Tier_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @User_ID IS NULL
            throw 53300, 'User_ID is required', 1;
        if OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID)
            throw 53301, 'User_ID does not reference existing [USER]', 1;
        if @Tier_ID IS NOT NULL AND (OBJECT_ID(N'dbo.MEMBERSHIP_TIER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.MEMBERSHIP_TIER WHERE Tier_ID = @Tier_ID))
            throw 53302, 'Tier_ID does not reference existing MEMBERSHIP_TIER', 1;
        if EXISTS(SELECT 1 FROM dbo.CUSTOMER WHERE User_ID = @User_ID)
            throw 53303, 'Customer already exists for this User_ID', 1;
        INSERT INTO dbo.CUSTOMER (User_ID, Total_Order, Total_Spending, Tier_ID)
        VALUES (@User_ID, @Total_Order, @Total_Spending, @Tier_ID);
        commit transaction;
        SELECT @User_ID AS InsertedUserID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go

CREATE OR ALTER PROCEDURE dbo.usp_Customer_Update
    @User_ID INT,
    @Total_Order INT = NULL,
    @Total_Spending DECIMAL(12,2) = NULL,
    @Tier_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @User_ID IS NULL
            throw 53310, 'User_ID is required', 1;
        if OBJECT_ID(N'dbo.CUSTOMER') IS NULL
            throw 53311, 'Target table dbo.CUSTOMER does not exist', 1;
        if NOT EXISTS(SELECT 1 FROM dbo.CUSTOMER WHERE User_ID = @User_ID)
            throw 53312, 'Customer not found', 1;
        if @Tier_ID IS NOT NULL AND (OBJECT_ID(N'dbo.MEMBERSHIP_TIER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.MEMBERSHIP_TIER WHERE Tier_ID = @Tier_ID))
            throw 53313, 'Tier_ID does not reference existing MEMBERSHIP_TIER', 1;
        UPDATE dbo.CUSTOMER
        SET
            Total_Order = COALESCE(@Total_Order, Total_Order),
            Total_Spending = COALESCE(@Total_Spending, Total_Spending),
            Tier_ID = COALESCE(@Tier_ID, Tier_ID)
        WHERE User_ID = @User_ID;
        commit transaction;
        SELECT @User_ID AS UpdatedUserID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_Customer_Delete
    @User_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        if @User_ID IS NULL
            throw 53320, 'User_ID is required', 1;
        if NOT EXISTS(SELECT 1 FROM dbo.CUSTOMER WHERE User_ID = @User_ID)
            throw 53321, 'Customer not found', 1;
        if @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.CUSTOMER')
            )
                throw 53322, 'Dependent foreign keys reference dbo.CUSTOMER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.CUSTOMER WHERE User_ID = @User_ID;
        commit transaction;
        SELECT @User_ID AS DeletedUserID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
/*
V.Shop_staff
*/
Create or alter procedure dbo.usp_ShopStaff_Insert
	@User_ID INT,
	@Shop_ID INT=null,
	@Role VARCHAR(50) = 'staff'
as 
begin
 set nocount on;
 begin try
	begin transaction;
	if @User_ID is null
		throw 53400,'User_id is required',1;
    if NOT EXISTS (SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID)
        THROW 53401, 'User_ID does not reference an existing user.', 1;
    if NOT EXISTS (SELECT 1 FROM dbo.SHOP_SELL WHERE Shop_ID = @Shop_ID)
        THROW 53402, 'Shop_ID does not reference an existing shop.', 1;
	if @role not in ('super admin','manager','staff')
		throw 53403,'Invalid role, must belong to one of three roles: super admin, manager, staff',1;
    IF EXISTS (SELECT 1 FROM dbo.SHOP_STAFF WHERE User_ID = @User_ID AND Shop_ID = @Shop_ID)
        THROW 53404, 'Duplicate: SHOP_STAFF already exists for this User_ID and Shop_ID.', 1;
	IF OBJECT_ID('dbo.[USER]') IS NULL 
        THROW 53405, 'Reference table dbo.[USER] does not exist.', 1;
    IF OBJECT_ID('dbo.SHOP_SELL') IS NULL 
        THROW 53406, 'Reference table dbo.SHOP_SELL does not exist.', 1;
    IF OBJECT_ID('dbo.SHOP_STAFF') IS NULL 
        THROW 53407, 'Target table dbo.SHOP_STAFF does not exist.', 1;
    -- Perform insert
    INSERT INTO dbo.SHOP_STAFF (User_ID, Role, Shop_ID) VALUES (@User_ID, @Role, @Shop_ID);
    COMMIT TRANSACTION;
    SELECT @User_ID AS insertedUserID, @Shop_ID AS insertedShopID;
end try
begin catch
	if XACT_STATE()<>0 rollback transaction;
	throw;
end catch
end;
go
CREATE or alter PROCEDURE dbo.usp_ShopStaff_Update
    @User_ID INT,
    @Shop_ID INT,
    @NewRole VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @User_ID IS NULL 
            THROW 53410,'User_ID is required',1;
        IF @Shop_ID IS NULL 
            THROW 53411,'Shop_ID is required',1;
        IF @NewRole IS NULL OR @NewRole NOT IN ('super admin','manager','staff') 
            THROW 53412,'Invalid or missing role.',1;
        IF NOT EXISTS (SELECT 1 FROM dbo.SHOP_STAFF WHERE User_ID = @User_ID AND Shop_ID = @Shop_ID)
            THROW 53413,'Record does not exist to update.',1;
        IF OBJECT_ID('dbo.SHOP_STAFF') IS NULL
            THROW 53414,'Target table dbo.SHOP_STAFF does not exist.',1;
        -- perform update
        UPDATE dbo.SHOP_STAFF SET Role = @NewRole WHERE User_ID = @User_ID AND Shop_ID = @Shop_ID;
        COMMIT TRANSACTION;
        SELECT @User_ID AS updatedUserID, @Shop_ID AS updatedShopID, @NewRole AS updatedRole;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ShopStaff_Delete
    @User_ID INT,
    @Shop_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @User_ID is null 
			throw 53420,'User_ID is required',1;
		if @Shop_ID is null 
			throw 53421,'Shop_ID is required',1;
        -- check record exists
		if not exists (SELECT 1 FROM dbo.SHOP_STAFF WHERE User_ID = @User_ID AND Shop_ID = @Shop_ID)
            throw 53422, 'Record does not exist; nothing to delete.', 1;
        -- check FK dependents and block when Force=0
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.SHOP_STAFF')
			)
			throw 53423,'Cannot delete: dependent foreign key constraints reference dbo.SHOP_STAFF. Use Force=1 to override.', 1;
		end
        -- delete
		DELETE FROM dbo.SHOP_STAFF WHERE User_ID = @User_ID AND Shop_ID = @Shop_ID;
        commit transaction;
        SELECT @User_ID AS deletedUserID, @Shop_ID AS deletedShopID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
VI.Variant
*/
create or alter procedure dbo.usp_Variant_Insert
    @ProductID INT,
    @Variant_Name VARCHAR(255),
    @Option_Value_1 VARCHAR(100)=null,
    @Option_Value_2 varchar(100)=null,
    @Price decimal(10,2)=0.00,
    @SKU int =null,
    @Variant_Status VARCHAR(50) = 'paused',
    @Variant_Image VARBINARY(MAX) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Variant_Name is null or len(ltrim(rtrim(@Variant_Name)))=0
        throw 53500,'Variant_Name is required',1;
    if @Price <0
        throw 53501,'Price must be non-negative',1;
    if OBJECT_ID('dbo.PRODUCT') is null
        throw 53502,'Reference table dbo.PRODUCT does not exist',1;
    if not exists(select 1 from dbo.PRODUCT where Product_ID=@ProductID)
        throw 53503,'Product not found',1;
    Insert into dbo.VARIANT(Option_Value_1,Option_Value_2,Variant_Name,Price,SKU,Variant_Status,Variant_Image)
    values(@Option_Value_1,@Option_Value_2,@Variant_Name,@Price, @SKU, @Variant_Status, @Variant_Image);
    DECLARE @InsertedProductID INT = CONVERT(INT, SCOPE_IDENTITY());
    SELECT @InsertedProductID AS P_ID;
    commit transaction;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_Variant_Update
    @Variant_ID Int,
    @Variant_Name VARCHAR(255)=null,
    @Option_Value_1 VARCHAR(100)=null,
    @Option_Value_2 varchar(100)=null,
    @Price decimal(10,2)=0.00,
    @SKU int =null,
    @Variant_Status VARCHAR(50) = null,
    @Variant_Image VARBINARY(MAX) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Variant_ID is null
        throw 53510,'Variant_ID is required',1;
    IF OBJECT_ID('dbo.VARIANT') IS NULL
        throw 53511, 'Target table dbo.VARIANT does not exist', 1;
    if not exists(select 1 from dbo.VARIANT where Variant_ID=@Variant_ID)
        throw 53512,'Variant not found',1;
    if @Price is not null and @Price<0
        throw 53513,'price must be non negative',1;
    UPDATE dbo.VARIANT
    SET
        Variant_Name=COALESCE(@Variant_Name, Variant_Name),
        Option_Value_1=COALESCE(@Option_Value_1, Option_Value_1),
        Option_Value_2=COALESCE(@Option_Value_2, Option_Value_2),
        Price=COALESCE(@Price, Price),
        SKU=COALESCE(@SKU, SKU),
        Variant_Status = COALESCE(@Variant_Status, Variant_Status),
        Variant_Image = CASE WHEN @Variant_Image IS NULL THEN Variant_Image ELSE @Variant_Image END
    WHERE Variant_ID = @Variant_ID;
    commit transaction;
    SELECT @Variant_ID AS UpdatedVariantID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
/*
VII.Order_Payment.
*/
create or alter procedure dbo.usp_OrderPayment_Insert
    @Order_ID Int,
    @Order_date datetime,
    @Voucher_code VARCHAR(50)=null,
    @Address varchar(max)=null,
    @Order_Status VARCHAR(100)=NULL,
    @Payment_ID INT=NULL,
    @Payment_Method VARCHAR(50)=NULL,
    @Payment_Status VARCHAR(50)=NULL,
    @Payed_value DECIMAL(10,2)=NULL,
    @Product_value DECIMAL(10,2)=NULL,
    @Shipment_value DECIMAL(10,2)=NULL,
    @Voucher_value DECIMAL(10,2)=NULL,
    @User_ID INT=NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Order_ID is null
            throw 53600,'Order_ID is required',1;
        if @Order_date is null 
            throw 53601,'Order_Date is required',1;
        if @User_ID is not null AND (OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID))
            THROW 53602, 'User_ID does not reference existing USER', 1;
        if @Voucher_code is not null AND (OBJECT_ID(N'dbo.VOUCHER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.VOUCHER WHERE Voucher_Code = @Voucher_code))
            throw 53603,'Voucher code does not reference existing Voucher',1;
        if EXISTS(SELECT 1 FROM dbo.ORDER_PAYMENT WHERE Order_ID = @Order_ID)
            throw 53604,'Order payment already exists',1;
        Insert into dbo.ORDER_PAYMENT(Order_ID, Order_date, Voucher_code, Address, Order_Status, Payment_ID, Payment_Method, Payment_Status, Payed_value, Product_value, Shipment_value, Voucher_value, User_ID)     
        values(@Order_ID, @Order_date, @Voucher_code, @Address, @Order_Status, @Payment_ID, @Payment_Method, @Payment_Status, @Payed_value, @Product_value, @Shipment_value, @Voucher_value, @User_ID)
        commit transaction;
        select @Order_ID as InsertedOrderID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_OrderPayment_Update
    @Order_ID Int,
    @Order_date datetime,
    @Voucher_code VARCHAR(50)=null,
    @Address varchar(max)=null,
    @Order_Status VARCHAR(100)=NULL,
    @Payment_ID INT=NULL,
    @Payment_Method VARCHAR(50)=NULL,
    @Payment_Status VARCHAR(50)=NULL,
    @Payed_value DECIMAL(10,2)=NULL,
    @Product_value DECIMAL(10,2)=NULL,
    @Shipment_value DECIMAL(10,2)=NULL,
    @Voucher_value DECIMAL(10,2)=NULL,
    @User_ID INT=NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Order_ID is null
        throw 53610,'Order_ID is required',1;
    IF OBJECT_ID(N'dbo.ORDER_PAYMENT') IS NULL
        throw 53611, 'Target table dbo.ORDER_PAYMENT does not exist', 1;
    if @User_ID is not null AND (OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID))
        THROW 53612, 'User_ID does not reference existing USER', 1;
    if @Voucher_code is not null AND (OBJECT_ID(N'dbo.VOUCHER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.VOUCHER WHERE Voucher_Code = @Voucher_code))
        throw 53613,'Voucher code does not reference existing Voucher',1;
    UPDATE dbo.ORDER_PAYMENT
    SET
        Order_date = COALESCE(@Order_date, Order_date),
        Voucher_code = COALESCE(@Voucher_code, Voucher_code),
        Address = COALESCE(@Address, Address),
        Order_Status = COALESCE(@Order_Status, Order_Status),
        Payment_ID = COALESCE(@Payment_ID, Payment_ID),
        Payment_Method = COALESCE(@Payment_Method, Payment_Method),
        Payment_Status = COALESCE(@Payment_Status, Payment_Status),
        Payed_value = COALESCE(@Payed_value, Payed_value),
        Product_value = COALESCE(@Product_value, Product_value),
        Shipment_value = COALESCE(@Shipment_value, Shipment_value),
        Voucher_value = COALESCE(@Voucher_value, Voucher_value),
        User_ID = COALESCE(@User_ID, User_ID)
    WHERE Order_ID=@Order_ID;
    commit transaction;
    SELECT @Order_ID AS UpdatedOrderID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_OrderPayment_Delete
    @Order_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Order_ID is null 
			throw 53620,'Order_ID is required',1;
		if not exists (SELECT 1 FROM dbo.ORDER_PAYMENT WHERE Order_ID = @Order_ID)
            throw 53621, 'Record does not exist; nothing to delete.', 1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.ORDER_PAYMENT')
			)
			throw 53622,'Cannot delete: dependent foreign key constraints reference dbo.ORDER_PAYMENT. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.ORDER_PAYMENT WHERE Order_ID = @Order_ID ;
        commit transaction;
        SELECT @Order_ID AS deletedOrderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
VIII.Order_Item.
*/
create or alter procedure dbo.usp_OrderItem_Insert
    @Order_Item_ID Int,
    @Price_at_Purchase DECIMAL(10,2)=NULL,
    @Quantity INT = NULL,
    @Shop_Voucher VARCHAR(100)=NULL,
    @Final_Item_Price DECIMAL(10,2)=NULL,
    @Shipment_ID INT = NULL,
    @Variant_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Order_Item_ID is null
            throw 53700,'Order_Item_ID is required',1;
        if @Quantity is not null AND @Quantity<=0
            THROW 53701, 'Quantity must be greater than 0', 1;
        if @Shipment_ID is not null AND (OBJECT_ID(N'dbo.SHIPMENT_PACKAGE') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID))
            throw 53702,'Shipment_ID does not reference existing SHIPMENT_PACKAGE',1;
        if EXISTS(SELECT 1 FROM dbo.ORDER_ITEM WHERE Order_Item_ID = @Order_Item_ID)
            throw 53703,'Order item already exists',1;
        Insert into dbo.ORDER_ITEM(Order_Item_ID, Price_at_Purchase, Quantity, Shop_Voucher, Final_Item_Price, Shipment_ID, Variant_ID)
        values(@Order_Item_ID, @Price_at_Purchase, @Quantity, @Shop_Voucher, @Final_Item_Price, @Shipment_ID, @Variant_ID);
        commit transaction;
        select @Order_Item_ID as InsertedOrderItemID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_OrderItem_Update
    @Order_Item_ID Int,
    @Price_at_Purchase DECIMAL(10,2)=NULL,
    @Quantity INT = NULL,
    @Shop_Voucher VARCHAR(100)=NULL,
    @Final_Item_Price DECIMAL(10,2)=NULL,
    @Shipment_ID INT = NULL,
    @Variant_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Order_Item_ID is null
        throw 53710,'Order_Item_ID is required',1;
    IF OBJECT_ID(N'dbo.ORDER_ITEM') IS NULL
        throw 53711, 'Target table dbo.ORDER_ITEM does not exist', 1;
    if not exists(SELECT 1 FROM dbo.ORDER_ITEM WHERE Order_Item_ID = @Order_Item_ID)
        throw 53712,'Order item not found',1;
    if @Quantity is not null AND @Quantity<=0
        throw 53713,'Quantity must be greater than 0', 1;
    if @Shipment_ID is not null AND (OBJECT_ID(N'dbo.SHIPMENT_PACKAGE') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID))
        throw 53714,'Shipment_ID does not reference existing SHIPMENT_PACKAGE',1;
    IF @Variant_ID IS NOT NULL AND (OBJECT_ID(N'dbo.VARIANT') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.VARIANT WHERE Variant_ID=@Variant_ID))
        throw 53715,'Variant_ID does not reference existing VARIANT',1;
    UPDATE dbo.ORDER_ITEM
    SET
        Price_at_Purchase = COALESCE(@Price_at_Purchase, Price_at_Purchase),
        Quantity = COALESCE(@Quantity, Quantity),
        Shop_Voucher = COALESCE(@Shop_Voucher, Shop_Voucher),
        Final_Item_Price = COALESCE(@Final_Item_Price, Final_Item_Price),
        Shipment_ID = COALESCE(@Shipment_ID, Shipment_ID),
        Variant_ID = COALESCE(@Variant_ID, Variant_ID)
    WHERE Order_Item_ID=@Order_Item_ID
    commit transaction;
    SELECT @Order_Item_ID AS UpdatedOrderItemID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_OrderItem_Delete
    @Order_Item_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Order_Item_ID is null 
			throw 53720,'Order_Item_ID is required',1;
		if not exists (SELECT 1 FROM dbo.ORDER_ITEM WHERE Order_Item_ID = @Order_Item_ID)
            throw 53721, 'Record does not exist; nothing to delete.', 1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.ORDER_ITEM')
			)
			throw 53722,'Cannot delete: dependent foreign key constraints reference dbo.ORDER_ITEM. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.ORDER_ITEM WHERE Order_Item_ID = @Order_Item_ID ;
        commit transaction;
        SELECT @Order_Item_ID AS deletedOrderItemID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
IX.Promotion program.
*/
create or alter procedure dbo.usp_PromotionProgram_Insert
    @Program_ID INT,
    @Categories_Apply VARCHAR(max) = NULL,
    @Promotion_tier VARCHAR(100) = NULL,
    @Start_Date DATETIME = NULL,
    @End_Date DATETIME = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Program_ID is null
            throw 53800,'Program_ID is required',1;
        if @Start_Date is not null AND @End_Date is not null and @End_Date < @Start_Date
            throw 53801,'End_Date must be after Start_Date',1;
        if EXISTS(SELECT 1 FROM dbo.PROMOTION_PROGRAM WHERE Program_ID = @Program_ID)
            throw 53802,'Promotion program already exists',1;
        Insert into dbo.PROMOTION_PROGRAM(Program_ID, Categories_Apply, Promotion_tier, Start_Date, End_Date)
        values(@Program_ID, @Categories_Apply, @Promotion_tier, @Start_Date, @End_Date);
        commit transaction;
        select @Program_ID as InserteProgramID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_PromotionProgram_Update
    @Program_ID INT,
    @Categories_Apply VARCHAR(max) = NULL,
    @Promotion_tier VARCHAR(100) = NULL,
    @Start_Date DATETIME = NULL,
    @End_Date DATETIME = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Program_ID is null
        throw 53810,'Program_ID is required',1;
    IF OBJECT_ID(N'dbo.PROMOTION_PROGRAM') IS NULL
        throw 53811, 'Target table dbo.PROMOTION_PROGRAM does not exist', 1;
    if not exists(SELECT 1 FROM dbo.PROMOTION_PROGRAM WHERE Program_ID = @Program_ID)
        throw 53812,'Promotion program not found',1;
    if @Start_Date is not null AND @End_Date is not null and @End_Date < @Start_Date
        throw 53813,'End_Date must be after Start_Date',1;
    UPDATE dbo.PROMOTION_PROGRAM
    SET
        Categories_Apply = COALESCE(@Categories_Apply, Categories_Apply),
        Promotion_tier = COALESCE(@Promotion_tier, Promotion_tier),
        Start_Date = COALESCE(@Start_Date, Start_Date),
        End_Date = COALESCE(@End_Date, End_Date)
    WHERE Program_ID=@Program_ID
    commit transaction;
    SELECT @Program_ID AS UpdatedProgramID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_PromotionProgram_Delete
    @Program_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Program_ID is null
            throw 53820,'Program_ID is required',1;
        if not exists(SELECT 1 FROM dbo.PROMOTION_PROGRAM WHERE Program_ID = @Program_ID)
            throw 53821,'Promotion program not found',1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.PROMOTION_PROGRAM')
			)
			throw 53822,'Cannot delete: dependent foreign key constraints reference dbo.PROMOTION_PROGRAM. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.PROMOTION_PROGRAM WHERE Program_ID = @Program_ID;
        commit transaction;
        SELECT @Program_ID AS deletedProgramID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
X.Voucher.
*/
create or alter procedure dbo.usp_Voucher_Insert
    @Voucher_ID INT ,
    @Quantity INT = NULL,
    @Voucher_Code VARCHAR(50) = NULL,
    @Voucher_Type VARCHAR(50) = NULL,
    @Discount_Type VARCHAR(50) = NULL,
    @Minimum_Order_Value DECIMAL(10,2) = NULL,
    @Maximum_Order_Value DECIMAL(10,2) = NULL,
    @Start_Date DATETIME = NULL,
    @Expiration_Date DATETIME = NULL,
    @Program_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Voucher_ID is null
            throw 53900,'Voucher_ID is required',1;
        if @Start_Date is not null AND @Expiration_Date IS NOT NULL AND @Expiration_Date < @Start_Date
            throw 53901,'Expiration_Date must be after Start_Date',1;
        if @Program_ID IS NOT NULL AND (OBJECT_ID(N'dbo.PROMOTION_PROGRAM') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.PROMOTION_PROGRAM WHERE Program_ID=@Program_ID))
            throw 53902,'Program_ID does not reference existing Promotion_Program',1;
        if EXISTS(SELECT 1 FROM dbo.VOUCHER WHERE Voucher_ID = @Voucher_ID)
            throw 53903,'Voucher already exists',1;
        Insert into dbo.VOUCHER (Voucher_ID, Quantity, Voucher_Code, Voucher_Type, Discount_Type, Minimum_Order_Value, Maximum_Order_Value, Start_Date, Expiration_Date, Program_ID)
        values(@Voucher_ID, @Quantity, @Voucher_Code, @Voucher_Type, @Discount_Type, @Minimum_Order_Value, @Maximum_Order_Value, @Start_Date, @Expiration_Date, @Program_ID);
        commit transaction;
        select @Voucher_ID as InsertedVoucherID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_Voucher_Update
    @Voucher_ID INT ,
    @Quantity INT = NULL,
    @Voucher_Code VARCHAR(50) = NULL,
    @Voucher_Type VARCHAR(50) = NULL,
    @Discount_Type VARCHAR(50) = NULL,
    @Minimum_Order_Value DECIMAL(10,2) = NULL,
    @Maximum_Order_Value DECIMAL(10,2) = NULL,
    @Start_Date DATETIME = NULL,
    @Expiration_Date DATETIME = NULL,
    @Program_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Voucher_ID is null
       throw 53910,'Voucher_ID is required',1;
    if OBJECT_ID(N'dbo.VOUCHER') is null
        throw 53911,'Target table dbo.VOUCHER does not exist',1;
    if @Start_Date is not null AND @Expiration_Date IS NOT NULL AND @Expiration_Date < @Start_Date
       throw 53912,'Expiration_Date must be after Start_Date',1;
    if @Program_ID IS NOT NULL AND (OBJECT_ID(N'dbo.PROMOTION_PROGRAM') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.PROMOTION_PROGRAM WHERE Program_ID=@Program_ID))
       throw 53913,'Program_ID does not reference existing Promotion_Program',1;
    if not EXISTS(SELECT 1 FROM dbo.VOUCHER WHERE Voucher_ID = @Voucher_ID)
       throw 53914,'Voucher not found',1;
    UPDATE dbo.VOUCHER
    SET
        Quantity = COALESCE(@Quantity, Quantity),
        Voucher_Code = COALESCE(@Voucher_Code, Voucher_Code),
        Voucher_Type = COALESCE(@Voucher_Type, Voucher_Type),
        Discount_Type = COALESCE(@Discount_Type, Discount_Type),
        Minimum_Order_Value = COALESCE(@Minimum_Order_Value, Minimum_Order_Value),
        Maximum_Order_Value = COALESCE(@Maximum_Order_Value, Maximum_Order_Value),
        Start_Date = COALESCE(@Start_Date, Start_Date),
        Expiration_Date = COALESCE(@Expiration_Date, Expiration_Date),
        Program_ID = COALESCE(@Program_ID, Program_ID)
    WHERE Voucher_ID=@Voucher_ID
    commit transaction;
    SELECT @Voucher_ID AS UpdatedVoucherID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_Voucher_Delete
    @Voucher_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Voucher_ID is null
            throw 53920,'Voucher_ID is required',1;
        if not exists(SELECT 1 FROM dbo.VOUCHER WHERE Voucher_ID = @Voucher_ID)
            throw 53921,'Voucher not found',1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.VOUCHER')
			)
			throw 53922,'Cannot delete: dependent foreign key constraints reference dbo.VOUCHER. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.VOUCHER WHERE Voucher_ID = @Voucher_ID;
        commit transaction;
        SELECT @Voucher_ID AS deletedVoucherID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
XI.Trip.
*/
create or alter procedure dbo.usp_Trip_Insert
    @Trip_ID INT,
    @Staff_ID INT,
    @Arrival_Time DATETIME = NULL,
    @Departure_Time DATETIME = NULL,
    @Arrival_post_code VARCHAR(20) = NULL,
    @Departure_post_code VARCHAR(20) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Trip_ID is null
            throw 54000,'Trip_ID is required',1;
        if @Staff_ID is null
            throw 54001,'Staff_ID is required',1;
        if OBJECT_ID(N'dbo.DELIVERY_STAFF') is null or not exists(SELECT 1 FROM dbo.DELIVERY_STAFF WHERE Staff_ID=@Staff_ID) 
            throw 54002,'Staff_ID does not reference existing DELIVERY_STAFF',1;
        if EXISTS(SELECT 1 FROM dbo.TRIP WHERE Trip_ID= @Trip_ID)
            throw 54003,'Trip already exists',1;
        Insert into dbo.TRIP(Trip_ID, Staff_ID, Arrival_Time, Departure_Time, Arrival_post_code, Departure_post_code)
        values(@Trip_ID, @Staff_ID, @Arrival_Time, @Departure_Time, @Arrival_post_code, @Departure_post_code);
        commit transaction;
        select @Trip_ID as InsertedTripID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_Trip_Update
    @Trip_ID INT,
    @Arrival_Time DATETIME = NULL,
    @Departure_Time DATETIME = NULL,
    @Arrival_post_code VARCHAR(20) = NULL,
    @Departure_post_code VARCHAR(20) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Trip_ID is null
       throw 54010,'Trip_ID is required',1;
    if OBJECT_ID(N'dbo.TRIP') is null
        throw 54011,'Target table dbo.TRIP does not exist',1;
    if not EXISTS(SELECT 1 FROM dbo.TRIP WHERE Trip_ID = @Trip_ID)
       throw 54012,'Trip not found',1;
    UPDATE dbo.TRIP
    SET
        Arrival_Time = COALESCE(@Arrival_Time, Arrival_Time), 
        Departure_Time = COALESCE(@Departure_Time, Departure_Time), 
        Arrival_post_code = COALESCE(@Arrival_post_code, Arrival_post_code),
        Departure_post_code = COALESCE(@Departure_post_code, Departure_post_code) 
    WHERE Trip_ID=@Trip_ID;
    commit transaction;
    SELECT @Trip_ID AS UpdatedTripID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_Trip_Delete
    @Trip_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Trip_ID is null
            throw 54020,'Trip_ID is required',1;
        if not EXISTS(SELECT 1 FROM dbo.TRIP WHERE Trip_ID = @Trip_ID)
            throw 54021,'Trip not found',1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.TRIP')
			)
			throw 54022,'Cannot delete: dependent foreign key constraints reference dbo.TRIP. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.TRIP WHERE Trip_ID = @Trip_ID;
        commit transaction;
        SELECT @Trip_ID AS deletedTripID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
XII.Shipment Package.
*/
create or alter procedure dbo.usp_ShipmentPackage_Insert
    @Tracking_Number VARCHAR(100)=NULL,
    @Delivery_Date DATETIME = NULL,
    @Estimated_Delivery_Date DATETIME = NULL,
    @Group_ID INT = NULL,
    @Shipping_Fee DECIMAL(10,2) = NULL,
    @Shipment_type VARCHAR(50) = NULL,
    @Reason VARCHAR(max) = NULL,
    @Provider_ID INT = NULL,
    @Order_ID INT = NULL,
    @Customer_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Order_ID is not null and (OBJECT_ID(N'dbo.ORDER_PAYMENT') is null or not exists(SELECT 1 FROM dbo.ORDER_PAYMENT WHERE Order_ID = @Order_ID))
            THROW 54100, 'Order_ID does not reference existing ORDER_PAYMENT', 1;
        if @Customer_ID is not null and (OBJECT_ID(N'dbo.CUSTOMER') is null or not exists(SELECT 1 FROM dbo.CUSTOMER WHERE User_ID = @Customer_ID))
            THROW 54101, 'Customer_ID does not reference existing CUSTOMER', 1;
        if @Provider_ID is not null and (OBJECT_ID(N'dbo.SHIPPING_PROVIDER') is null or not exists(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 54102, 'Provider_ID does not reference existing SHIPPING_PROVIDER', 1;
        Insert into dbo.SHIPMENT_PACKAGE(Tracking_Number, Delivery_Date, Estimated_Delivery_Date, Group_ID, Shipping_Fee, Shipment_type, Reason, Provider_ID, Order_ID, Customer_ID)
        values(@Tracking_Number, @Delivery_Date, @Estimated_Delivery_Date, @Group_ID, @Shipping_Fee, @Shipment_type, @Reason, @Provider_ID, @Order_ID, @Customer_ID);
        DECLARE @NewShipmentID INT = CONVERT(INT, SCOPE_IDENTITY());
        commit transaction;
        select @NewShipmentID as InsertedShipmentID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_ShipmentPackage_Update
    @Shipment_ID INT,
    @Tracking_Number VARCHAR(100)=NULL,
    @Delivery_Date DATETIME = NULL,
    @Estimated_Delivery_Date DATETIME = NULL,
    @Group_ID INT = NULL,
    @Shipping_Fee DECIMAL(10,2) = NULL,
    @Shipment_type VARCHAR(50) = NULL,
    @Reason VARCHAR(max) = NULL,
    @Provider_ID INT = NULL,
    @Order_ID INT = NULL,
    @Customer_ID INT = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Shipment_ID is null
       throw 54110,'Shipment_ID is required',1;
    if OBJECT_ID(N'dbo.SHIPMENT_PACKAGE') is null
        throw 54111,'Target table dbo.SHIPMENT_PACKAGE does not exist',1;
    if not EXISTS(SELECT 1 FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID)
       throw 54112,'Shipment not found',1;
    if @Order_ID IS NOT NULL AND (OBJECT_ID(N'dbo.ORDER_PAYMENT') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.ORDER_PAYMENT WHERE Order_ID=@Order_ID))
       throw 54113,'Order_ID does not reference existing ORDER_PAYMENT',1;
    IF @Customer_ID IS NOT NULL AND (OBJECT_ID(N'dbo.CUSTOMER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.CUSTOMER WHERE User_ID = @Customer_ID))
       THROW 54114, 'Customer_ID does not reference existing CUSTOMER', 1;
    IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SHIPPING_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID))
       THROW 54115, 'Provider_ID does not reference existing SHIPPING_PROVIDER', 1;
    UPDATE dbo.SHIPMENT_PACKAGE
    SET
        Tracking_Number = COALESCE(@Tracking_Number, Tracking_Number),
        Delivery_Date = COALESCE(@Delivery_Date, Delivery_Date),
        Estimated_Delivery_Date = COALESCE(@Estimated_Delivery_Date, Estimated_Delivery_Date),
        Group_ID = COALESCE(@Group_ID, Group_ID),
        Shipping_Fee = COALESCE(@Shipping_Fee, Shipping_Fee),
        Shipment_type = COALESCE(@Shipment_type, Shipment_type),
        Reason = COALESCE(@Reason, Reason),
        Provider_ID = COALESCE(@Provider_ID, Provider_ID),
        Order_ID = COALESCE(@Order_ID, Order_ID),
        Customer_ID = COALESCE(@Customer_ID, Customer_ID)
    WHERE Shipment_ID = @Shipment_ID;
    commit transaction;
    SELECT @Shipment_ID AS UpdatedShipmentID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
CREATE OR ALTER PROCEDURE dbo.usp_ShipmentPackage_Delete
    @Shipment_ID INT,
    @Force BIT = 0
as
begin 
	set nocount on;
	begin try
		begin transaction;
		if @Shipment_ID is null
            throw 54120,'Shipment_ID is required',1;
        if not EXISTS(SELECT 1 FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID)
            throw 54121,'Shipment not found',1;
		if @Force=0
		begin 
			if EXISTS(
				select 1
				from sys.foreign_keys fk
				join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
				where fkc.referenced_object_id=OBJECT_ID('dbo.SHIPMENT_PACKAGE')
			)
			throw 54122,'Cannot delete: dependent foreign key constraints reference dbo.SHIPMENT_PACKAGE. Use Force=1 to override.', 1;
		end
		DELETE FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID;
        commit transaction;
        SELECT @Shipment_ID AS deletedShipmentID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/*
XIII.Shipment Status.
*/
create or alter procedure dbo.usp_ShipmentStatus_Insert
    @Shipment_ID INT,
    @Status_ID INT,
    @Status_Name VARCHAR(255) = NULL,
    @Updated_time DATETIME = NULL,
    @Current_Location VARCHAR(255) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Shipment_ID is null
            throw 54200,'Shipment_ID is required', 1;
        if @Status_ID is null
            throw 54201,'Status_ID is required', 1;
        if OBJECT_ID(N'dbo.SHIPMENT_PACKAGE') is null or not exists(SELECT 1 FROM dbo.SHIPMENT_PACKAGE WHERE Shipment_ID = @Shipment_ID)
            throw 54202, 'Shipment_ID does not reference existing SHIPMENT_PACKAGE', 1;
        if exists(SELECT 1 FROM dbo.SHIPMENT_STATUS WHERE Shipment_ID = @Shipment_ID AND Status_ID = @Status_ID)
            throw 54203, 'Status already exists for this shipment',1;
        INSERT INTO dbo.SHIPMENT_STATUS (Shipment_ID, Status_ID, Status_Name, Updated_time, Current_Location)
        VALUES (@Shipment_ID, @Status_ID, @Status_Name, @Updated_time, @Current_Location);
        commit transaction;
        select @Shipment_ID as InsertedShipmentID,@Status_ID AS InsertedStatusID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_ShipmentStatus_Update
    @Shipment_ID INT,
    @Status_ID INT,
    @Status_Name VARCHAR(100) = NULL,
    @Updated_time DATETIME = NULL,
    @Current_Location VARCHAR(255) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Shipment_ID is null
            throw 54210,'Shipment_ID is required', 1;
        if @Status_ID is null
            throw 54211,'Status_ID is required', 1;
        if OBJECT_ID(N'dbo.SHIPMENT_STATUS') is null
            throw 54212,'Target table dbo.SHIPMENT_STATUS does not exist', 1;
        if not exists(SELECT 1 FROM dbo.SHIPMENT_STATUS WHERE Shipment_ID=@Shipment_ID AND Status_ID = @Status_ID)
            throw 54213,'Status record not found',1;
        UPDATE dbo.SHIPMENT_STATUS
        SET
            Status_Name = COALESCE(@Status_Name, Status_Name),
            Updated_time = COALESCE(@Updated_time, Updated_time),
            Current_Location = COALESCE(@Current_Location, Current_Location)
        WHERE Shipment_ID = @Shipment_ID AND Status_ID = @Status_ID;
        commit transaction;
        select @Shipment_ID AS UpdatedShipmentID, @Status_ID AS UpdatedStatusID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_ShipmentStatus_Delete
    @Shipment_ID INT,
    @Status_ID INT
as 
begin
    set nocount on;
    begin try
        begin transaction;
    if @Shipment_ID is null
       throw 54220,'Shipment_ID is required',1;
    if @Status_ID is null
       throw 54221,'Status_ID is required', 1;
    if not EXISTS(SELECT 1 FROM dbo.SHIPMENT_STATUS WHERE Shipment_ID = @Shipment_ID and Status_ID=@Status_ID)
       throw 54222,'Status not found',1;
    DELETE FROM dbo.SHIPMENT_STATUS WHERE Shipment_ID = @Shipment_ID AND Status_ID = @Status_ID;
    commit transaction;
    SELECT @Shipment_ID AS DeletedShipmentID,@Status_ID as DeletedStatusID;
end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
/*
XIV.Shipper.
*/
create or alter procedure dbo.usp_Shipper_Insert
    @Staff_ID INT,
    @Vehicle_type VARCHAR(100) = NULL,
    @Delivery_zone VARCHAR(max) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Staff_ID is null
            throw 54300,'Staff_ID is required', 1;
        if OBJECT_ID(N'dbo.DELIVERY_STAFF') is null or not exists(SELECT 1 FROM dbo.DELIVERY_STAFF WHERE Staff_ID = @Staff_ID)
            throw 54301, 'Staff_ID does not reference existing DELIVERY_STAFF', 1;
        if exists(SELECT 1 FROM dbo.SHIPPER WHERE Staff_ID = @Staff_ID)
            throw 54302, 'Shipper already exists for this Staff_ID',1;
        INSERT INTO dbo.SHIPPER (Staff_ID, Vehicle_type, Delivery_zone) 
        VALUES (@Staff_ID, @Vehicle_type, @Delivery_zone);
        commit transaction;
        select @Staff_ID AS InsertedStaffID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_Shipper_Update
    @Staff_ID INT,
    @Vehicle_type VARCHAR(100) = NULL,
    @Delivery_zone VARCHAR(max) = NULL
as 
begin
    set nocount on;
    begin try
        begin transaction;
        if @Staff_ID is null
            throw 54310,'Staff_ID is required', 1;
        if OBJECT_ID(N'dbo.SHIPPER') is null
            throw 54311,'Target table dbo.SHIPPER does not exist', 1;
        if not exists(SELECT 1 FROM dbo.SHIPPER WHERE Staff_ID = @Staff_ID)
            throw 54312,'Shipper not found',1;
        UPDATE dbo.SHIPPER
        SET
            Vehicle_type = COALESCE(@Vehicle_type, Vehicle_type),
            Delivery_zone = COALESCE(@Delivery_zone, Delivery_zone)
        WHERE Staff_ID = @Staff_ID;
        commit transaction;
        select @Staff_ID AS UpdatedStaffID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
create or alter procedure dbo.usp_Shipper_Delete
    @Staff_ID INT,
    @Force Bit=0
as
begin
    set nocount on;
    begin try
        begin transaction;
        if @Staff_ID is null
            throw 54320,'Staff_ID is required', 1;
        if OBJECT_ID(N'dbo.SHIPPER') is null
            throw 54321,'Target table dbo.SHIPPER does not exist', 1;
        if not exists(SELECT 1 FROM dbo.SHIPPER WHERE Staff_ID = @Staff_ID)
            throw 54322,'Shipper not found',1;
        BEGIN
            IF EXISTS(
                SELECT 1
                FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.SHIPPER')
            )
                THROW 54323, 'Dependent foreign keys reference dbo.SHIPPER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.SHIPPER WHERE Staff_ID = @Staff_ID;
        commit transaction;
        select @Staff_ID AS DeletedStaffID;
    end try
begin catch
    if XACT_STATE()<>0 rollback transaction;
    throw;
end catch;
end;
go
/*
XV.Delivery Staff.
*/
CREATE OR ALTER PROCEDURE dbo.usp_DeliveryStaff_Insert
    @Full_Name VARCHAR(100) = NULL,
    @ID_Number VARCHAR(50) = NULL,
    @Driver_License VARCHAR(50) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Full_Name IS NULL OR LEN(LTRIM(RTRIM(@Full_Name))) = 0
            THROW 54500, 'Full_Name is required', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SHIPPING_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 54501, 'Provider_ID does not reference existing SHIPPING_PROVIDER', 1;
        INSERT INTO dbo.DELIVERY_STAFF (Full_Name, ID_Number, Driver_License, Provider_ID)
        VALUES (@Full_Name, @ID_Number, @Driver_License, @Provider_ID);
        DECLARE @InsertedDeliveryStaffID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedDeliveryStaffID AS InsertedStaffID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DeliveryStaff_Update
    @Staff_ID INT,
    @Full_Name VARCHAR(100) = NULL,
    @ID_Number VARCHAR(50) = NULL,
    @Driver_License VARCHAR(50) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Staff_ID IS NULL
            THROW 54510, 'Staff_ID is required', 1;
        IF OBJECT_ID(N'dbo.DELIVERY_STAFF') IS NULL
            THROW 54511, 'Target table dbo.DELIVERY_STAFF does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.DELIVERY_STAFF WHERE Staff_ID = @Staff_ID)
            THROW 54512, 'Delivery staff not found', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SHIPPING_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 54513, 'Provider_ID does not reference existing SHIPPING_PROVIDER', 1;
        UPDATE dbo.DELIVERY_STAFF
        SET Full_Name = COALESCE(@Full_Name, Full_Name),
            ID_Number = COALESCE(@ID_Number, ID_Number),
            Driver_License = COALESCE(@Driver_License, Driver_License),
            Provider_ID = COALESCE(@Provider_ID, Provider_ID)
        WHERE Staff_ID = @Staff_ID;
        COMMIT TRANSACTION;
        SELECT @Staff_ID AS UpdatedStaffID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DeliveryStaff_Delete
    @Staff_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Staff_ID IS NULL
            THROW 54520, 'Staff_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.DELIVERY_STAFF WHERE Staff_ID = @Staff_ID)
            THROW 54521, 'Delivery staff not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.DELIVERY_STAFF')
            )
                THROW 54522, 'Dependent foreign keys reference dbo.DELIVERY_STAFF -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.DELIVERY_STAFF WHERE Staff_ID = @Staff_ID;
        COMMIT TRANSACTION;
        SELECT @Staff_ID AS DeletedStaffID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
/*
XVI.Shipping Provider.
*/
CREATE OR ALTER PROCEDURE dbo.usp_ShippingProvider_Insert
    @Coverage_Area VARCHAR(max) = NULL,
    @Weight_Limit DECIMAL(10,2) = NULL,
    @Size_Limit VARCHAR(50) = NULL,
    @Delivery_Method VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.SHIPPING_PROVIDER (Coverage_Area, Weight_Limit, Size_Limit, Delivery_Method)
        VALUES ( @Coverage_Area, @Weight_Limit, @Size_Limit, @Delivery_Method);
        DECLARE @InsertedProviderID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedProviderID AS InsertedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ShippingProvider_Update
    @Provider_ID INT,
    @Coverage_Area VARCHAR(500) = NULL,
    @Weight_Limit DECIMAL(18,2) = NULL,
    @Size_Limit VARCHAR(100) = NULL,
    @Delivery_Method VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Provider_ID IS NULL
            THROW 54610, 'Provider_ID is required', 1;
        IF OBJECT_ID(N'dbo.SHIPPING_PROVIDER') IS NULL
            THROW 54611, 'Target table dbo.SHIPPING_PROVIDER does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID)
            THROW 54612, 'Shipping provider not found', 1;
        UPDATE dbo.SHIPPING_PROVIDER
        SET Coverage_Area = COALESCE(@Coverage_Area, Coverage_Area),
            Weight_Limit = COALESCE(@Weight_Limit, Weight_Limit),
            Size_Limit = COALESCE(@Size_Limit, Size_Limit),
            Delivery_Method = COALESCE(@Delivery_Method, Delivery_Method)
        WHERE Provider_ID = @Provider_ID;
        COMMIT TRANSACTION;
        SELECT @Provider_ID AS UpdatedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ShippingProvider_Delete
    @Provider_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Provider_ID IS NULL
            THROW 54620, 'Provider_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID)
            THROW 54621, 'Shipping provider not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.SHIPPING_PROVIDER')
            )
                THROW 54622, 'Dependent foreign keys reference dbo.SHIPPING_PROVIDER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.SHIPPING_PROVIDER WHERE Provider_ID = @Provider_ID;
        COMMIT TRANSACTION;
        SELECT @Provider_ID AS DeletedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
/*
XVII.Truck driver.
*/
CREATE OR ALTER PROCEDURE dbo.usp_TruckDriver_Insert
    @Truck_ID INT = NULL,
    @Route_Assigned VARCHAR(max) = NULL,
    @Max_weight DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.TRUCK_DRIVER (Truck_ID, Route_Assigned, Max_weight)
        VALUES (@Truck_ID, @Route_Assigned, @Max_weight);
        DECLARE @InsertedDriverID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedDriverID AS InsertedDriverID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_TruckDriver_Update
    @Staff_ID INT,
    @Truck_ID INT = NULL,
    @Route_Assigned VARCHAR(max) = NULL,
    @Max_weight DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Staff_ID IS NULL
            THROW 54710, 'Staff_ID is required', 1;
        IF OBJECT_ID(N'dbo.TRUCK_DRIVER') IS NULL
            THROW 54711, 'Target table dbo.TRUCK_DRIVER does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.TRUCK_DRIVER WHERE Staff_ID = @Staff_ID)
            THROW 54712, 'Truck driver not found', 1;
        UPDATE dbo.TRUCK_DRIVER
        SET Truck_ID = COALESCE(@Truck_ID, Truck_ID),
            Route_Assigned = COALESCE(@Route_Assigned, Route_Assigned),
            Max_weight = COALESCE(@Max_weight, Max_weight)
        WHERE Staff_ID = @Staff_ID;
        COMMIT TRANSACTION;
        SELECT @Staff_ID AS UpdatedDriverID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_TruckDriver_Delete
    @Staff_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Staff_ID IS NULL
            THROW 54720, 'Staff_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.TRUCK_DRIVER WHERE Staff_ID = @Staff_ID)
            THROW 54721, 'Truck driver not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.TRUCK_DRIVER')
            )
                THROW 54722, 'Dependent foreign keys reference dbo.TRUCK_DRIVER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.TRUCK_DRIVER WHERE Staff_ID = @Staff_ID;
        COMMIT TRANSACTION;
        SELECT @Staff_ID AS DeletedDriverID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
/*
XVIII.Bank Account.
*/
CREATE OR ALTER PROCEDURE dbo.usp_BankAccount_Insert
    @Bank_account VARCHAR(100),
    @User_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Bank_account IS NULL OR LEN(LTRIM(RTRIM(@Bank_account))) = 0
            THROW 54800, 'Bank_account is required', 1;
        IF @User_ID IS NULL
            THROW 54801, 'User_ID is required', 1;
        IF OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID)
            THROW 54802, 'User_ID does not reference existing USER', 1;
        IF EXISTS(SELECT 1 FROM dbo.BANK_ACCOUNT WHERE Bank_account = @Bank_account)
            THROW 54803, 'Bank account already exists', 1;
        INSERT INTO dbo.BANK_ACCOUNT (Bank_account, User_ID)
        VALUES (@Bank_account, @User_ID);
        COMMIT TRANSACTION;
        SELECT @Bank_account AS InsertedBankAccount;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_BankAccount_Update
    @Bank_account VARCHAR(100),
    @User_ID INT 
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Bank_account IS NULL OR LEN(LTRIM(RTRIM(@Bank_account))) = 0
            THROW 54810, 'Bank_account is required', 1;
        IF OBJECT_ID(N'dbo.BANK_ACCOUNT') IS NULL
            THROW 54811, 'Target table dbo.BANK_ACCOUNT does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.BANK_ACCOUNT WHERE Bank_account = @Bank_account)
            THROW 54812, 'Bank account not found', 1;
        IF @User_ID IS NOT NULL AND (OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID))
            THROW 54813, 'User_ID does not reference existing USER', 1;
        UPDATE dbo.BANK_ACCOUNT
        SET User_ID = COALESCE(@User_ID, User_ID)
        WHERE Bank_account = @Bank_account;
        COMMIT TRANSACTION;
        SELECT @Bank_account AS UpdatedBankAccount;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_BankAccount_Delete
    @Bank_account VARCHAR(100),
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Bank_account IS NULL
            THROW 54820, 'Bank_account is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.BANK_ACCOUNT WHERE Bank_account = @Bank_account)
            THROW 54821, 'Bank account not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.BANK_ACCOUNT')
            )
                THROW 54822, 'Dependent foreign keys reference dbo.BANK_ACCOUNT -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.BANK_ACCOUNT WHERE Bank_account = @Bank_account;
        COMMIT TRANSACTION;
        SELECT @Bank_account AS DeletedBankAccount;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
/*
XIX.Category.
*/
CREATE OR ALTER PROCEDURE dbo.usp_Category_Insert
    @Category_name VARCHAR(255),
    @Category_Image VARBINARY(MAX) = NULL,
    @Level INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Category_name IS NULL OR LEN(LTRIM(RTRIM(@Category_name))) = 0
            THROW 54900, 'Category_name is required', 1;
        INSERT INTO dbo.CATEGORY (Category_name, Category_Image, Level)
        VALUES (@Category_name, @Category_Image, @Level);
        DECLARE @InsertedCategoryID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedCategoryID AS InsertedCategoryID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_Category_Update
    @Category_ID INT,
    @Category_name VARCHAR(255) ,
    @Category_Image VARBINARY(MAX) = NULL,
    @Level INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Category_ID IS NULL
            THROW 54910, 'Category_ID is required', 1;
        IF @Category_name IS NULL OR LEN(LTRIM(RTRIM(@Category_name))) = 0
            THROW 54911, 'Category_name is required', 1;
        IF OBJECT_ID(N'dbo.CATEGORY') IS NULL
            THROW 54912, 'Target table dbo.CATEGORY does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.CATEGORY WHERE Category_ID = @Category_ID)
            THROW 54913, 'Category not found', 1;
        UPDATE dbo.CATEGORY
        SET Category_name = COALESCE(@Category_name, Category_name),
            Category_Image = CASE WHEN @Category_Image IS NULL THEN Category_Image ELSE @Category_Image END,
            Level = COALESCE(@Level, Level)
        WHERE Category_ID = @Category_ID;
        COMMIT TRANSACTION;
        SELECT @Category_ID AS UpdatedCategoryID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_Category_Delete
    @Category_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Category_ID IS NULL
            THROW 54920, 'Category_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.CATEGORY WHERE Category_ID = @Category_ID)
            THROW 54921, 'Category not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.CATEGORY')
            )
                THROW 54922, 'Dependent foreign keys reference dbo.CATEGORY -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.CATEGORY WHERE Category_ID = @Category_ID;
        COMMIT TRANSACTION;
        SELECT @Category_ID AS DeletedCategoryID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
/*
XX.Management Entity.
*/
CREATE OR ALTER PROCEDURE dbo.usp_ManagementEntity_Insert
    @Address VARCHAR(max) = NULL,
    @Hotline VARCHAR(20) = NULL,
    @Email VARCHAR(255) = NULL,
    @Entity_Name VARCHAR(255) = NULL,
    @Director VARCHAR(100) = NULL,
    @Nation VARCHAR(100) = NULL,
    @Established_Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.MANAGEMENT_ENTITY (Address, Hotline, Email, Entity_Name, Director, Nation, Established_Date)
        VALUES (@Address, @Hotline, @Email, @Entity_Name, @Director, @Nation, @Established_Date);
        DECLARE @InsertedEntityID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedEntityID AS InsertedEntityID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_ManagementEntity_Update
    @Entity_ID INT,
    @Address VARCHAR(max) = NULL,
    @Hotline VARCHAR(20) = NULL,
    @Email VARCHAR(255) = NULL,
    @Entity_Name VARCHAR(255) = NULL,
    @Director VARCHAR(100) = NULL,
    @Nation VARCHAR(100) = NULL,
    @Established_Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Entity_ID IS NULL
            THROW 60010, 'Entity_ID is required', 1;
        IF OBJECT_ID(N'dbo.MANAGEMENT_ENTITY') IS NULL
            THROW 60011, 'Target table dbo.MANAGEMENT_ENTITY does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.MANAGEMENT_ENTITY WHERE Entity_ID = @Entity_ID)
            THROW 60012, 'Management entity not found', 1;
        UPDATE dbo.MANAGEMENT_ENTITY
        SET Address = COALESCE(@Address, Address),
            Hotline = COALESCE(@Hotline, Hotline),
            Email = COALESCE(@Email, Email),
            Entity_Name = COALESCE(@Entity_Name, Entity_Name),
            Director = COALESCE(@Director, Director),
            Nation = COALESCE(@Nation, Nation),
            Established_Date = COALESCE(@Established_Date, Established_Date)
        WHERE Entity_ID = @Entity_ID;
        COMMIT TRANSACTION;
        SELECT @Entity_ID AS UpdatedEntityID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_ManagementEntity_Delete
    @Entity_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Entity_ID IS NULL
            THROW 60020, 'Entity_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.MANAGEMENT_ENTITY WHERE Entity_ID = @Entity_ID)
            THROW 60021, 'Management entity not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.MANAGEMENT_ENTITY')
            )
                THROW 60022, 'Dependent foreign keys reference dbo.MANAGEMENT_ENTITY -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.MANAGEMENT_ENTITY WHERE Entity_ID = @Entity_ID;
        COMMIT TRANSACTION;
        SELECT @Entity_ID AS DeletedEntityID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
/*
XX.Membership Tier.
*/
CREATE OR ALTER PROCEDURE dbo.usp_MembershipTier_Insert
    @Tier VARCHAR(100) = NULL,
    @Min_orders_Per_half_year INT = NULL,
    @Min_spend_Per_half_year DECIMAL(12,2) = NULL,
    @Discount_Rate DECIMAL(5,2) = NULL,
    @Benefit DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.MEMBERSHIP_TIER (Tier, Min_orders_Per_half_year, Min_spend_Per_half_year, Discount_Rate, Benefit)
        VALUES (@Tier, @Min_orders_Per_half_year, @Min_spend_Per_half_year, @Discount_Rate, @Benefit);
        DECLARE @InsertedTierID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedTierID AS InsertedTierID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_MembershipTier_Update
    @Tier_ID INT ,
    @Tier VARCHAR(100) = NULL,
    @Min_orders_Per_half_year INT = NULL,
    @Min_spend_Per_half_year DECIMAL(12,2) = NULL,
    @Discount_Rate DECIMAL(5,2) = NULL,
    @Benefit DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Tier_ID IS NULL
            THROW 60110, 'Tier_ID is required', 1;
        IF OBJECT_ID(N'dbo.MEMBERSHIP_TIER') IS NULL
            THROW 60111, 'Target table dbo.MEMBERSHIP_TIER does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.MEMBERSHIP_TIER WHERE Tier_ID = @Tier_ID)
            THROW 60112, 'Membership tier not found', 1;
        UPDATE dbo.MEMBERSHIP_TIER
        SET Tier = COALESCE(@Tier, Tier),
            Min_orders_Per_half_year = COALESCE(@Min_orders_Per_half_year, Min_orders_Per_half_year),
            Min_spend_Per_half_year = COALESCE(@Min_spend_Per_half_year, Min_spend_Per_half_year),
            Discount_Rate = COALESCE(@Discount_Rate, Discount_Rate),
            Benefit = COALESCE(@Benefit, Benefit)
        WHERE Tier_ID = @Tier_ID;
        COMMIT TRANSACTION;
        SELECT @Tier_ID AS UpdatedTierID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_MembershipTier_Delete
    @Tier_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Tier_ID IS NULL
            THROW 60120, 'Tier_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.MEMBERSHIP_TIER WHERE Tier_ID = @Tier_ID)
            THROW 60121, 'Membership tier not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.MEMBERSHIP_TIER')
            )
                THROW 60122, 'Dependent foreign keys reference dbo.MEMBERSHIP_TIER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.MEMBERSHIP_TIER WHERE Tier_ID = @Tier_ID;
        COMMIT TRANSACTION;
        SELECT @Tier_ID AS DeletedTierID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
/* 
XXI.Post
*/
CREATE OR ALTER PROCEDURE dbo.usp_Post_Insert
    @Post_Code VARCHAR(20),
    @Region VARCHAR(100) = NULL,
    @Address VARCHAR(MAX) = NULL,
    @Hotline VARCHAR(20) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Post_Code IS NULL OR LEN(LTRIM(RTRIM(@Post_Code))) = 0
            THROW 60200, 'Post_Code is required', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 60201, 'Provider_ID does not reference existing SERVICE_PROVIDER', 1;
        INSERT INTO dbo.POST (Post_Code, Region, Address, Hotline, Provider_ID)
        VALUES (@Post_Code, @Region, @Address, @Hotline, @Provider_ID);
        COMMIT TRANSACTION;
        SELECT @Post_Code AS InsertedPostCode;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_Post_Update
    @Post_Code VARCHAR(20),
    @Region VARCHAR(100) = NULL,
    @Address VARCHAR(MAX) = NULL,
    @Hotline VARCHAR(20) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Post_Code IS NULL
            THROW 60210, 'Post_Code is required', 1;
        IF OBJECT_ID(N'dbo.POST') IS NULL
            THROW 60211, 'Target table dbo.POST does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.POST WHERE Post_Code = @Post_Code)
            THROW 60212, 'Post not found', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 60213, 'Provider_ID does not reference existing SERVICE_PROVIDER', 1;
        UPDATE dbo.POST
        SET Region = COALESCE(@Region, Region),
            Address = COALESCE(@Address, Address),
            Hotline = COALESCE(@Hotline, Hotline),
            Provider_ID = COALESCE(@Provider_ID, Provider_ID)
        WHERE Post_Code = @Post_Code;
        COMMIT TRANSACTION;
        SELECT @Post_Code AS UpdatedPostCode;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
CREATE OR ALTER PROCEDURE dbo.usp_Post_Delete
    @Post_Code VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Post_Code IS NULL
            THROW 60220, 'Post_Code is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.POST WHERE Post_Code = @Post_Code)
            THROW 60221, 'Post not found', 1;
        DELETE FROM dbo.POST WHERE Post_Code = @Post_Code;
        COMMIT TRANSACTION;
        SELECT @Post_Code AS DeletedPostCode;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
/*
XXII.Product_Review
*/
CREATE OR ALTER PROCEDURE dbo.usp_ProductReview_Insert
    @P_ID INT=null,
    @User_ID INT=null,
    @Rating_Star INT=null,
    @Comment VARCHAR(MAX) = NULL,
    @Image_Video VARBINARY(MAX) = NULL,
    @Review_Date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Rating_Star IS NULL OR @Rating_Star < 0 OR @Rating_Star > 5
            THROW 60300, 'Rating_Star is required and must be between 0 and 5', 1;
        IF OBJECT_ID(N'dbo.PRODUCT') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.PRODUCT WHERE Product_ID = @P_ID)
            THROW 60301, 'P_ID does not reference existing PRODUCT', 1;
        IF OBJECT_ID(N'dbo.[USER]') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.[USER] WHERE User_ID = @User_ID)
            THROW 60302, 'User_ID does not reference existing USER', 1;
        INSERT INTO dbo.PRODUCT_REVIEW (Review_Date, Image_Video, Comment, Rating_Star, P_ID, User_ID)
        VALUES (COALESCE(@Review_Date, GETDATE()), @Image_Video, @Comment, @Rating_Star, @P_ID, @User_ID);
        DECLARE @InsertedReviewID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedReviewID  AS InsertedReviewID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ProductReview_Update
    @Review_ID INT,
    @Rating_Star INT = NULL,
    @Comment VARCHAR(MAX) = NULL,
    @Image_Video VARBINARY(MAX) = NULL,
    @Review_Date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Review_ID IS NULL
            THROW 60310, 'Review_ID is required', 1;
        IF OBJECT_ID(N'dbo.PRODUCT_REVIEW') IS NULL
            THROW 60311, 'Target table dbo.PRODUCT_REVIEW does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.PRODUCT_REVIEW WHERE Review_ID = @Review_ID)
            THROW 60312, 'Review not found', 1;
        IF @Rating_Star IS NOT NULL AND (@Rating_Star < 0 OR @Rating_Star > 5)
            THROW 60313, 'Rating_Star must be between 0 and 5', 1;
        UPDATE dbo.PRODUCT_REVIEW
        SET
            Rating_Star = COALESCE(@Rating_Star, Rating_Star),
            Comment = COALESCE(@Comment, Comment),
            Image_Video = CASE WHEN @Image_Video IS NULL THEN Image_Video ELSE @Image_Video END,
            Review_Date = COALESCE(@Review_Date, Review_Date)
        WHERE Review_ID = @Review_ID;
        COMMIT TRANSACTION;
        SELECT @Review_ID AS UpdatedReviewID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ProductReview_Delete
    @Review_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Review_ID IS NULL
            THROW 60320, 'Review_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.PRODUCT_REVIEW WHERE Review_ID = @Review_ID)
            THROW 60321, 'Review not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.PRODUCT_REVIEW')
            )
                THROW 60322, 'Dependent foreign keys reference dbo.PRODUCT_REVIEW -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.PRODUCT_REVIEW WHERE Review_ID = @Review_ID;
        COMMIT TRANSACTION;
        SELECT @Review_ID AS DeletedReviewID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
/*
XXIII.Service Provider
*/
CREATE OR ALTER PROCEDURE dbo.usp_ServiceProvider_Insert
    @Provider_Name VARCHAR(255)= null,
    @Service_Type VARCHAR(100) = NULL,
    @Contact_Info VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Provider_Name IS NULL OR LEN(LTRIM(RTRIM(@Provider_Name))) = 0
            THROW 60400, 'Provider_Name is required', 1;
        IF OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL
            THROW 60401, 'Target table dbo.SERVICE_PROVIDER does not exist', 1;
        INSERT INTO dbo.SERVICE_PROVIDER (Provider_Name, Service_Type, Contact_Info)
        VALUES (@Provider_Name, @Service_Type, @Contact_Info);
        DECLARE @InsertedProviderID INT = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
        SELECT @InsertedProviderID AS InsertedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ServiceProvider_Update
    @Provider_ID INT,
    @Provider_Name VARCHAR(255) = NULL,
    @Service_Type VARCHAR(100) = NULL,
    @Contact_Info VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Provider_ID IS NULL
            THROW 60410, 'Provider_ID is required', 1;
        IF OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL
            THROW 60411, 'Target table dbo.SERVICE_PROVIDER does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID)
            THROW 60412, 'Service provider not found', 1;
        UPDATE dbo.SERVICE_PROVIDER
        SET
            Provider_Name = COALESCE(@Provider_Name, Provider_Name),
            Service_Type = COALESCE(@Service_Type, Service_Type),
            Contact_Info = COALESCE(@Contact_Info, Contact_Info)
        WHERE Provider_ID = @Provider_ID;
        COMMIT TRANSACTION;
        SELECT @Provider_ID AS UpdatedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ServiceProvider_Delete
    @Provider_ID INT,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Provider_ID IS NULL
            THROW 60420, 'Provider_ID is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID)
            THROW 60421, 'Service provider not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.SERVICE_PROVIDER')
            )
                THROW 60422, 'Dependent foreign keys reference dbo.SERVICE_PROVIDER -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID;
        COMMIT TRANSACTION;
        SELECT @Provider_ID AS DeletedProviderID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
/*
XXIV.Service Package
*/
CREATE OR ALTER PROCEDURE dbo.usp_ServicePackage_Insert
    @Package_Name VARCHAR(255),
    @Service_Cost DECIMAL(10,2) = 0.00,
    @Duration VARCHAR(100) = NULL,
    @Benefit DECIMAL(10,2) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Package_Name IS NULL OR LEN(LTRIM(RTRIM(@Package_Name))) = 0
            THROW 60500, 'Package_Name is required', 1;
        IF @Service_Cost IS NULL OR @Service_Cost < 0
            THROW 60501, 'Service_Cost is required and must be non-negative', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 60502, 'Provider_ID does not reference existing SERVICE_PROVIDER', 1;
        IF EXISTS(SELECT 1 FROM dbo.SERVICE_PACKAGE WHERE Package_Name = @Package_Name)
            THROW 60503, 'Service package already exists', 1;
        INSERT INTO dbo.SERVICE_PACKAGE (Package_Name, Service_Cost, Duration, Benefit, Provider_ID)
        VALUES (@Package_Name, @Service_Cost, @Duration, @Benefit, @Provider_ID);
        COMMIT TRANSACTION;
        SELECT @Package_Name AS InsertedPackageName;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ServicePackage_Update
    @Package_Name VARCHAR(255),
    @Service_Cost DECIMAL(10,2) = NULL,
    @Duration VARCHAR(100) = NULL,
    @Benefit DECIMAL(10,2) = NULL,
    @Provider_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Package_Name IS NULL
            THROW 60510, 'Package_Name is required', 1;
        IF OBJECT_ID(N'dbo.SERVICE_PACKAGE') IS NULL
            THROW 60511, 'Target table dbo.SERVICE_PACKAGE does not exist', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PACKAGE WHERE Package_Name = @Package_Name)
            THROW 60512, 'Service package not found', 1;
        IF @Service_Cost IS NOT NULL AND @Service_Cost < 0
            THROW 60513, 'Service_Cost must be non-negative', 1;
        IF @Provider_ID IS NOT NULL AND (OBJECT_ID(N'dbo.SERVICE_PROVIDER') IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PROVIDER WHERE Provider_ID = @Provider_ID))
            THROW 60514, 'Provider_ID does not reference existing SERVICE_PROVIDER', 1;
        UPDATE dbo.SERVICE_PACKAGE
        SET
            Service_Cost = COALESCE(@Service_Cost, Service_Cost),
            Duration = COALESCE(@Duration, Duration),
            Benefit = COALESCE(@Benefit, Benefit),
            Provider_ID = COALESCE(@Provider_ID, Provider_ID)
        WHERE Package_Name = @Package_Name;
        COMMIT TRANSACTION;
        SELECT @Package_Name AS UpdatedPackageName;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ServicePackage_Delete
    @Package_Name VARCHAR(255),
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Package_Name IS NULL
            THROW 60520, 'Package_Name is required', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.SERVICE_PACKAGE WHERE Package_Name = @Package_Name)
            THROW 60521, 'Service package not found', 1;
        IF @Force = 0
        BEGIN
            IF EXISTS(
                SELECT 1 FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.referenced_object_id = OBJECT_ID(N'dbo.SERVICE_PACKAGE')
            )
                THROW 60522, 'Dependent foreign keys reference dbo.SERVICE_PACKAGE -- use Force=1 to override', 1;
        END
        DELETE FROM dbo.SERVICE_PACKAGE WHERE Package_Name = @Package_Name;
        COMMIT TRANSACTION;
        SELECT @Package_Name AS DeletedPackageName;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO