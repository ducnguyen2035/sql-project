CREATE DATABASE [QL_SHOPEE_BTL];
GO

USE [QL_SHOPEE_BTL];
GO

-- 1. KHỐI QUẢN LÝ & USER
----------------------------------------------------

CREATE TABLE MANAGEMENT_ENTITY (
    Entity_ID INT PRIMARY KEY,
    Address VARCHAR(MAX),
    Hotline VARCHAR(20),
    Email VARCHAR(255),
    Entity_Name VARCHAR(255),
    Director VARCHAR(100),
    Nation VARCHAR(100),
    Established_Date DATE
);
GO

CREATE TABLE [USER] (
    User_ID INT PRIMARY KEY,
    ID_number VARCHAR(50) UNIQUE NULL,
    Phone_number VARCHAR(50) UNIQUE NULL,
    Email VARCHAR(255) UNIQUE NULL,
    Full_name VARCHAR(100) NULL,
    Gender VARCHAR(10),
    Birthday DATE,
    Account_status VARCHAR(50),
    -- SET DEFAULT
    Entity_ID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT CK_USER_Account_status CHECK (Account_status IN ('active', 'warning', 'restricted')),
    CONSTRAINT CK_USER_Gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    -- SET DEFAULT khi đơn vị quản lý bị xóa
    CONSTRAINT fk_user_entity FOREIGN KEY (Entity_ID) REFERENCES MANAGEMENT_ENTITY(Entity_ID)
        ON DELETE SET DEFAULT 
        ON UPDATE CASCADE
);
GO

CREATE TABLE MEMBERSHIP_TIER (
    Tier_ID INT PRIMARY KEY,
    Tier VARCHAR(100),
    Min_orders_Per_half_year INT,
    Min_spend_Per_half_year DECIMAL(12, 2),
    Discount_Rate DECIMAL(5, 2),
    Benefit DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT CK_TIER_Tier CHECK (Tier IN ('Standard', 'Silver', 'Gold', 'Diamond'))
);
GO

CREATE TABLE CUSTOMER (
    User_ID INT PRIMARY KEY,
    Total_Order INT DEFAULT 0,
    Total_Spending DECIMAL(12, 2) DEFAULT 0,
    -- DEFAULT 1 (Standard) 
    Tier_ID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT CK_CUSTOMER_Total_Order CHECK (Total_Order >= 0),
    CONSTRAINT CK_CUSTOMER_Total_Spending CHECK (Total_Spending >= 0),
    -- Chặn xóa User
    CONSTRAINT fk_customer_user FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
        ON DELETE NO ACTION,
    -- Tự động về hạng Standard nếu hạng hiện tại bị xóa 
    CONSTRAINT fk_customer_tier FOREIGN KEY (Tier_ID) REFERENCES MEMBERSHIP_TIER(Tier_ID)
        ON DELETE SET DEFAULT 
        ON UPDATE CASCADE
);
GO

CREATE TABLE BANK_ACCOUNT (
    Bank_account VARCHAR(100) NOT NULL,
    User_ID INT NOT NULL,
    PRIMARY KEY (Bank_account, User_ID),
    -- Xóa User -> xoá Bank Account
    CONSTRAINT fk_bank_user FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

-- 2. KHỐI CỬA HÀNG & SẢN PHẨM
----------------------------------------------------

CREATE TABLE SHOP_SELL (
    Shop_ID INT PRIMARY KEY,
    Shop_name VARCHAR(255) NOT NULL,
    Shop_type VARCHAR(100),
    Description VARCHAR(MAX),
    Operation_Status VARCHAR(50),
    Logo VARBINARY(MAX), 
    Follower INT DEFAULT 0,
    Chat_response_rate DECIMAL(5, 2),
    Address VARCHAR(MAX), 
    Bank_Account VARCHAR(100),
    Email_for_Online_Bills VARCHAR(255),
    Stock_address VARCHAR(MAX), 
    Tax_code VARCHAR(50),
    Type_of_Business VARCHAR(100),
    User_ID INT NOT NULL,
    
    CONSTRAINT CK_SHOP_Shop_Type CHECK (Shop_Type IN ('Shopee Mall', 'preferred', 'normal')),
    CONSTRAINT CK_SHOP_Operation_Status CHECK (Operation_Status IN ('active', 'paused', 'closed')),
    CONSTRAINT CK_SHOP_Follower CHECK (Follower >= 0),
    CONSTRAINT CK_SHOP_Chat_Rate CHECK (Chat_response_rate >= 0 AND Chat_response_rate <= 100),
    -- Chặn xóa User nếu đang là chủ Shop
    CONSTRAINT fk_shop_user FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
        ON DELETE NO ACTION
);
GO

CREATE TABLE SHOP_STAFF (
    User_ID INT PRIMARY KEY,
    [Role] VARCHAR(100),
    Shop_ID INT NOT NULL,
    CONSTRAINT CK_STAFF_Role CHECK ([Role] IN ('super_admin', 'manager', 'staff')),
    -- Xóa User hoặc Shop thì xóa luôn Staff 
    CONSTRAINT fk_staff_user FOREIGN KEY (User_ID) REFERENCES [USER](User_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_staff_shop FOREIGN KEY (Shop_ID) REFERENCES SHOP_SELL(Shop_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

CREATE TABLE CATEGORY (
    Category_ID INT PRIMARY KEY,
    Category_name VARCHAR(255) NOT NULL,
    Category_Image VARBINARY(MAX), 
    [Level] INT
);
GO

CREATE TABLE CATEGORY_HIERARCHY (
    Parent_Category_ID INT NOT NULL,
    Sub_Category_ID INT NOT NULL,
    PRIMARY KEY (Parent_Category_ID, Sub_Category_ID),
    
    CONSTRAINT CK_CATEGORY_Hierarchy CHECK (Parent_Category_ID != Sub_Category_ID),
    -- Xóa Category cha/con thì xóa luôn quan hệ này
    CONSTRAINT fk_parent_category FOREIGN KEY (Parent_Category_ID) REFERENCES CATEGORY(Category_ID), 
        
    CONSTRAINT fk_sub_category FOREIGN KEY (Sub_Category_ID) REFERENCES CATEGORY(Category_ID) 
        
);
GO

CREATE TABLE PRODUCT (
    Product_ID INT PRIMARY KEY,
    Product_name VARCHAR(255) NOT NULL,
    Description VARCHAR(MAX), 
    Base_Price DECIMAL(10, 2) NOT NULL,
    Total_Sales INT DEFAULT 0,
    Average_Rating DECIMAL(3, 2),
    Base_Image NVARCHAR(MAX), 
    Product_Status VARCHAR(50),
    C_ID INT NOT NULL, 
    Shop_ID INT NOT NULL,
    
    CONSTRAINT CK_PRODUCT_Base_Price CHECK (Base_Price >= 0),
    CONSTRAINT CK_PRODUCT_Total_Sales CHECK (Total_Sales >= 0),
    CONSTRAINT CK_PRODUCT_Average_Rating CHECK (Average_Rating >= 0 AND Average_Rating <= 5),
    CONSTRAINT CK_PRODUCT_Status CHECK (Product_Status IN ('for_sale', 'paused', 'discontinued')),
    -- Chặn xóa Category hoặc Shop nếu đang có sản phẩm 
    CONSTRAINT fk_product_category FOREIGN KEY (C_ID) REFERENCES CATEGORY(Category_ID) 
        ON DELETE NO ACTION,
    CONSTRAINT fk_product_shop FOREIGN KEY (Shop_ID) REFERENCES SHOP_SELL(Shop_ID) ON DELETE NO ACTION
);
GO

CREATE TABLE PRODUCT_REVIEW (
    Review_ID INT PRIMARY KEY,
    Review_Date DATETIME,
    Image_Video VARBINARY(MAX), 
    Comment VARCHAR(MAX), 
    Rating_Star INT,
    P_ID INT NOT NULL,
    User_ID INT NOT NULL, 
    
    CONSTRAINT CK_REVIEW_Rating_Star CHECK (Rating_Star >= 1 AND Rating_Star <= 5),
    -- Xóa Sản phẩm thì xóa Review 
    -- Xóa Customer thì chặn 
    CONSTRAINT fk_review_product FOREIGN KEY (P_ID) REFERENCES PRODUCT(Product_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (User_ID) REFERENCES CUSTOMER(User_ID) 
        ON DELETE NO ACTION
);
GO

-- 3. KHỐI ĐƠN HÀNG & THANH TOÁN
----------------------------------------------------

CREATE TABLE ORDER_PAYMENT (
    Order_ID INT PRIMARY KEY,
    Order_date DATETIME NOT NULL,
    Voucher_code VARCHAR(50),
    Address VARCHAR(MAX), 
    Order_Status VARCHAR(50),
    Payment_ID INT NOT NULL, 
    Payment_Method VARCHAR(50),
    Payment_Status VARCHAR(50),
    Payed_value DECIMAL(10, 2),
    Product_value DECIMAL(10, 2),
    Shipment_value DECIMAL(10, 2),
    Voucher_value DECIMAL(10, 2),
    User_ID INT NOT NULL,
    
    CONSTRAINT CK_ORDER_Status CHECK (Order_Status IN ('processing', 'confirmed', 'shipping', 'delivered', 'cancelled', 'completed')),
    CONSTRAINT CK_ORDER_Payment_Method CHECK (Payment_Method IN ('Shopee Pay', 'COD', 'Bank Transfer', 'Credit Card')),
    CONSTRAINT CK_ORDER_Payment_Status CHECK (Payment_Status IN ('processing', 'success', 'failed')),
    
    CONSTRAINT CK_ORDER_COD_Status CHECK (NOT (Payment_Method = 'COD' AND Payment_Status = 'failed')),
    
    CONSTRAINT CK_ORDER_Product_Value CHECK (Product_value >= 0),
    CONSTRAINT CK_ORDER_Shipment_Value CHECK (Shipment_value >= 0),
    CONSTRAINT CK_ORDER_Voucher_Value CHECK (Voucher_value >= 0),
    CONSTRAINT CK_ORDER_Payed_Value CHECK (Payed_value >= 0),
    CONSTRAINT CK_ORDER_Total_Value CHECK (Payed_value = (Product_value + Shipment_value - Voucher_value)),
    
    -- Chặn xóa User đã có đơn hàng 
    CONSTRAINT fk_order_user FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
        ON DELETE NO ACTION
);
GO

CREATE TABLE SHIPPING_PROVIDER (
    Provider_ID INT PRIMARY KEY,
    Provider_Name VARCHAR(255) NOT NULL,
    Coverage_Area VARCHAR(MAX), 
    Weight_Limit DECIMAL(10, 2),
    Size_Limit VARCHAR(50),
    Delivery_Method VARCHAR(100),
    
    CONSTRAINT CK_SHIP_PROV_Weight_Limit CHECK (Weight_Limit > 0),
    CONSTRAINT CK_SHIP_PROV_Method CHECK (Delivery_Method IN ('standard', 'fast', 'instant', 'economy'))
);
GO

CREATE TABLE SHIPMENT_PACKAGE (
    Shipment_ID INT PRIMARY KEY,
    Tracking_Number VARCHAR(100),
    Delivery_Date DATETIME,
    Estimated_Delivery_Date DATETIME,
    Group_ID INT, 
    Shipping_Fee DECIMAL(10, 2),
    Shipment_type VARCHAR(50) NOT NULL,
    Reason VARCHAR(MAX),
    Order_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    
    CONSTRAINT CK_SHIPMENT_Type CHECK (Shipment_type IN ('successful delivery', 'return order')),
    CONSTRAINT CK_SHIPMENT_Shipping_Fee CHECK (Shipping_Fee >= 0),
    CONSTRAINT CK_SHIPMENT_Return_Reason CHECK (NOT (Shipment_type = 'return order' AND Reason IS NULL)),
    CONSTRAINT CK_SHIPMENT_Return_Date CHECK (NOT (Shipment_type = 'return order' AND Delivery_Date IS NOT NULL)),
    
    -- Chặn xóa Đơn hàng nếu đã có Vận đơn
    CONSTRAINT fk_shipment_order FOREIGN KEY (Order_ID) REFERENCES ORDER_PAYMENT(Order_ID) 
        ON DELETE NO ACTION,
    CONSTRAINT fk_shipment_customer FOREIGN KEY (Customer_ID) REFERENCES [USER](User_ID) 
        ON DELETE NO ACTION
);
GO

CREATE TABLE VARIANT (
    Variant_ID INT PRIMARY KEY,
    Option_Value_1 VARCHAR(100),
    Option_Value_2 VARCHAR(100),
    Variant_Name VARCHAR(255),
    Price DECIMAL(10, 2),
    SKU INT, 
    Variant_Status VARCHAR(50),
    Variant_Image VARBINARY(MAX), 
    P_ID INT NOT NULL,
    
    CONSTRAINT CK_VARIANT_Price CHECK (Price > 0),
    CONSTRAINT CK_VARIANT_SKU CHECK (SKU >= 0),
    CONSTRAINT CK_VARIANT_Status CHECK (Variant_Status IN ('for_sale', 'paused', 'discontinued')),
    
    -- Xóa Product thì xóa luôn Variant 
    CONSTRAINT fk_variant_product FOREIGN KEY (P_ID) REFERENCES PRODUCT(Product_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

CREATE TABLE ORDER_ITEM (
    Order_Item_ID INT PRIMARY KEY,
    Price_at_Purchase DECIMAL(10, 2),
    Quantity INT,
    Final_Item_Price DECIMAL(10, 2),
    Shipment_ID INT NOT NULL,
    Variant_ID INT NOT NULL UNIQUE, 
    
    CONSTRAINT CK_ITEM_Price CHECK (Price_at_Purchase >= 0),
    CONSTRAINT CK_ITEM_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_ITEM_Final_Price CHECK (Final_Item_Price >= 0),
    
    -- Xóa Shipment thì xóa Item
    -- Chặn xóa Variant đã bán 
    CONSTRAINT fk_orderitem_shipment FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT_PACKAGE(Shipment_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_orderitem_variant FOREIGN KEY (Variant_ID) REFERENCES VARIANT(Variant_ID) 
        ON DELETE NO ACTION
);
GO

-- 4. VẬN CHUYỂN (GỘP DRIVER)
----------------------------------------------------

CREATE TABLE [POST] (
    Post_Code VARCHAR(20) PRIMARY KEY,
    Region VARCHAR(100),
    Address VARCHAR(MAX),
    Hotline VARCHAR(20),
    Provider_ID INT NOT NULL,
    -- Chặn xóa Provider đang có Bưu cục
    CONSTRAINT fk_post_provider FOREIGN KEY (Provider_ID) REFERENCES SHIPPING_PROVIDER(Provider_ID) 
        ON DELETE NO ACTION
);
GO

CREATE TABLE DRIVER (
    Staff_ID INT PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    ID_Number VARCHAR(12) UNIQUE NOT NULL,
    Driver_License VARCHAR(50),
    -- Bỏ NOT NULL để cho phép SET NULL
    Provider_ID INT,
    
    Driver_Type VARCHAR(20) NOT NULL, 
    Truck_ID INT,
    Route_Assigned VARCHAR(MAX),
    Max_weight DECIMAL(10, 2),

    CONSTRAINT CK_DRIVER_Type CHECK (Driver_Type IN ('Truck', 'Shipper')),
    -- Nếu Provider bị xóa, Driver trở thành tự do
    CONSTRAINT fk_driver_provider FOREIGN KEY (Provider_ID) REFERENCES SHIPPING_PROVIDER(Provider_ID)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);
GO

CREATE TABLE [TRIP] (
    Trip_ID INT NOT NULL,
    Staff_ID INT NOT NULL, 
    Arrival_Time DATETIME NOT NULL,
    Departure_Time DATETIME NOT NULL,
    Arrival_post_code VARCHAR(20) NOT NULL,
    Departure_post_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (Staff_ID, Trip_ID), 
    
    CONSTRAINT CK_TRIP_Time CHECK (Arrival_Time > Departure_Time),
    -- Chặn xóa Driver hoặc Post đang có Trip 
    CONSTRAINT fk_trip_driver FOREIGN KEY (Staff_ID) REFERENCES DRIVER(Staff_ID) 
        ON DELETE NO ACTION,
    CONSTRAINT fk_trip_arr_post FOREIGN KEY (Arrival_post_code) REFERENCES [POST](Post_Code) 
        ON DELETE NO ACTION,
    CONSTRAINT fk_trip_dep_post FOREIGN KEY (Departure_post_code) REFERENCES [POST](Post_Code) 
        ON DELETE NO ACTION
);
GO

CREATE TABLE ORDER_PACKAGE_TRIP (
    Shipment_ID INT NOT NULL,
    Staff_ID INT NOT NULL, 
    Trip_ID INT NOT NULL,
    PRIMARY KEY (Shipment_ID, Staff_ID, Trip_ID), 
    -- Xóa Shipment hoặc Trip thì xóa liên kết này 
    CONSTRAINT fk_op_shipment FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT_PACKAGE(Shipment_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_op_trip FOREIGN KEY (Staff_ID, Trip_ID) REFERENCES [TRIP](Staff_ID, Trip_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

-- 5. KHUYẾN MÃI & DỊCH VỤ
----------------------------------------------------

CREATE TABLE PROMOTION_PROGRAM (
    Program_ID INT PRIMARY KEY,
    Categories_Apply VARCHAR(MAX), 
    Promotion_tier VARCHAR(100),
    Start_Date DATETIME,
    End_Date DATETIME,
    CONSTRAINT CK_PROMO_Date CHECK (End_Date >= Start_Date)
);
GO

CREATE TABLE VOUCHER (
    Voucher_ID INT PRIMARY KEY,
    Quantity INT,
    Voucher_Code VARCHAR(50) UNIQUE,
    Voucher_Type VARCHAR(50),
    Discount_Type VARCHAR(50),
    Minimum_Order_Value DECIMAL(10, 2),
    Maximum_Order_Value DECIMAL(10, 2),
    Start_Date DATETIME,
    Expiration_Date DATETIME,
    Program_ID INT,
    
    CONSTRAINT CK_VOUCHER_Quantity CHECK (Quantity >= 0),
    CONSTRAINT CK_VOUCHER_Type CHECK (Voucher_Type IN ('Platform', 'Shop', 'Shipping')),
    CONSTRAINT CK_VOUCHER_Discount_Type CHECK (Discount_Type IN ('fixed', 'percent')),
    CONSTRAINT CK_VOUCHER_Min_Value CHECK (Minimum_Order_Value >= 0),
    CONSTRAINT CK_VOUCHER_Date CHECK (Expiration_Date >= Start_Date),
    
    -- Xóa Chương trình thì xóa Voucher
    CONSTRAINT fk_voucher_program FOREIGN KEY (Program_ID) REFERENCES PROMOTION_PROGRAM(Program_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

CREATE TABLE PAYMENT_VOUCHER (
    Order_ID INT NOT NULL,
    Voucher_ID INT NOT NULL,
    PRIMARY KEY (Order_ID, Voucher_ID),
    -- Xóa Đơn hoặc Voucher thì xóa liên kết 
    CONSTRAINT fk_pv_order FOREIGN KEY (Order_ID) REFERENCES ORDER_PAYMENT(Order_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_pv_voucher FOREIGN KEY (Voucher_ID) REFERENCES VOUCHER(Voucher_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

CREATE TABLE SERVICE_PROVIDER (
    Provider_ID INT PRIMARY KEY,
    Provider_Name VARCHAR(255),
    Service_Type VARCHAR(100),
    Contact_Info VARCHAR(MAX) 
);
GO

CREATE TABLE SERVICE_PACKAGE (
    Package_Name VARCHAR(255) PRIMARY KEY,
    Service_Cost DECIMAL(10, 2),
    Duration VARCHAR(100),
    Benefit DECIMAL(10, 2),
    Provider_ID INT NOT NULL,
    
    CONSTRAINT CK_PACKAGE_Cost CHECK (Service_Cost >= 0),
    -- Xóa Provider thì xóa Package 
    CONSTRAINT fk_package_provider FOREIGN KEY (Provider_ID) REFERENCES SERVICE_PROVIDER(Provider_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

-- 6. KHỐI LIÊN KẾT (ALL CASCADE)
----------------------------------------------------
CREATE TABLE MANAGEMENT_ENTITY_SHIPPING_PROVIDER (
    ShProvider_ID INT, Entity_ID INT, PRIMARY KEY (ShProvider_ID, Entity_ID),
    FOREIGN KEY (ShProvider_ID) REFERENCES SHIPPING_PROVIDER(Provider_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Entity_ID) REFERENCES MANAGEMENT_ENTITY(Entity_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE SERVICE_PROVIDER_MANAGEMENT_ENTITY (
    Provider_ID INT, Entity_ID INT, PRIMARY KEY (Provider_ID, Entity_ID),
    FOREIGN KEY (Provider_ID) REFERENCES SERVICE_PROVIDER(Provider_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Entity_ID) REFERENCES MANAGEMENT_ENTITY(Entity_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE MANAGEMENT_ENTITY_PROMOTION_PROGRAM (
    Entity_ID INT, Program_ID INT, PRIMARY KEY (Entity_ID, Program_ID),
    FOREIGN KEY (Entity_ID) REFERENCES MANAGEMENT_ENTITY(Entity_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Program_ID) REFERENCES PROMOTION_PROGRAM(Program_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE PROMOTION_PROGRAM_SHOP (
    Shop_ID INT, Program_ID INT, PRIMARY KEY (Shop_ID, Program_ID),
    FOREIGN KEY (Shop_ID) REFERENCES SHOP_SELL(Shop_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Program_ID) REFERENCES PROMOTION_PROGRAM(Program_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE PROMOTION_PROGRAM_PRODUCT (
    Product_ID INT, Program_ID INT, PRIMARY KEY (Product_ID, Program_ID),
    FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Program_ID) REFERENCES PROMOTION_PROGRAM(Program_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE VOUCHER_SHOP (
    Voucher_ID INT, Shop_ID INT, PRIMARY KEY (Voucher_ID, Shop_ID),
    FOREIGN KEY (Voucher_ID) REFERENCES VOUCHER(Voucher_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Shop_ID) REFERENCES SHOP_SELL(Shop_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE VOUCHER_CUSTOMER (
    Voucher_ID INT, User_ID INT, PRIMARY KEY (Voucher_ID, User_ID),
    FOREIGN KEY (Voucher_ID) REFERENCES VOUCHER(Voucher_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (User_ID) REFERENCES CUSTOMER(User_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE VOUCHER_MEMBERSHIP_TIER (
    Voucher_ID INT, Tier_ID INT, PRIMARY KEY (Voucher_ID, Tier_ID),
    FOREIGN KEY (Voucher_ID) REFERENCES VOUCHER(Voucher_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Tier_ID) REFERENCES MEMBERSHIP_TIER(Tier_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE PRODUCT_CUSTOMER (
    Product_ID INT, User_ID INT, PRIMARY KEY (Product_ID, User_ID),
    FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (User_ID) REFERENCES CUSTOMER(User_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
CREATE TABLE SERVICE_PACKAGE_SHOP (
    Package_Name VARCHAR(255), Shop_ID INT, PRIMARY KEY (Package_Name, Shop_ID),
    FOREIGN KEY (Package_Name) REFERENCES SERVICE_PACKAGE(Package_Name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Shop_ID) REFERENCES SHOP_SELL(Shop_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- 7. BẢNG BỔ SUNG
----------------------------------------------------

CREATE TABLE SHIPMENT_STATUS (
    Shipment_ID INT NOT NULL,
    Status_ID INT NOT NULL,
    Status_Name VARCHAR(100),
    Updated_time DATETIME,
    Current_Location VARCHAR(255),
    PRIMARY KEY (Shipment_ID, Status_ID),
    
    CONSTRAINT CK_STATUS_Name CHECK (Status_Name IN ('preparing', 'shipping', 'delivered', 'returned')),
    -- Xóa Shipment thì xóa luôn Status
    CONSTRAINT fk_status_shipment FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT_PACKAGE(Shipment_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO