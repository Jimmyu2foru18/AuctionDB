USE auctionDB;

CREATE TABLE Time (
    CurrentTime DATETIME NOT NULL
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    UserType VARCHAR(10) DEFAULT 'BUYER',
    HasPaymentInfo BOOLEAN DEFAULT FALSE
);

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Description TEXT
);

CREATE TABLE Items (
    ItemID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    SellerID INT NOT NULL,
    Description TEXT,
    Location VARCHAR(255),
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    StartingPrice DECIMAL(10,2) NOT NULL,
    CurrentPrice DECIMAL(10,2) NOT NULL,
    NumberOfBids INT DEFAULT 0,
    Status VARCHAR(10) DEFAULT 'ACTIVE',
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);

CREATE TABLE ItemCategories (
    ItemID INT,
    CategoryID INT,
    PRIMARY KEY (ItemID, CategoryID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE ShippingOptions (
    OptionID INT PRIMARY KEY,
    SellerID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    EstimatedTime INT NOT NULL,
    Type VARCHAR(20) NOT NULL,
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);

CREATE TABLE BankInformation (
    BankID INT PRIMARY KEY,
    SellerID INT NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    RoutingNumber VARCHAR(20) NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL,
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);

CREATE TABLE Bids (
    BidID INT PRIMARY KEY,
    ItemID INT NOT NULL,
    BidderID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    BidTime DATETIME NOT NULL,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (BidderID) REFERENCES Users(UserID)
);

CREATE TABLE Sales (
    ItemID INT PRIMARY KEY,
    BuyerID INT NOT NULL,
    FinalPrice DECIMAL(10,2) NOT NULL,
    ShippingOptionID INT NOT NULL,
    Status VARCHAR(20) DEFAULT 'PENDING',
    DeliveryConfirmed BOOLEAN DEFAULT FALSE,
    TrackingNumber VARCHAR(50),
    ShipByDate DATETIME,
    ShippedDate DATETIME,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID),
    FOREIGN KEY (ShippingOptionID) REFERENCES ShippingOptions(OptionID)
);

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY,
    BuyerID INT NOT NULL,
    SellerID INT NOT NULL,
    ItemID INT NOT NULL,
    Rating INT NOT NULL,
    Feedback TEXT,
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);

CREATE TABLE PaymentInformation (
    PaymentID INT PRIMARY KEY,
    BuyerID INT NOT NULL,
    CardNumber VARCHAR(255) NOT NULL,
    ExpirationDate DATE NOT NULL,
    CCV VARCHAR(10) NOT NULL,
    NameOnCard VARCHAR(100) NOT NULL,
    BillingAddress VARCHAR(255) NOT NULL,
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID)
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    BuyerID INT NOT NULL,
    ItemID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'PENDING',
    PaymentDate DATETIME,
    PaymentMethod VARCHAR(20) DEFAULT 'CREDIT_CARD',
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);

CREATE TABLE Shipment (
    ShipmentID INT PRIMARY KEY,
    ItemID INT NOT NULL,
    TrackingNumber VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'PENDING',
    ShippedDate DATETIME,
    EstimatedDeliveryDate DATETIME,
    ActualDeliveryDate DATETIME,
    Confirmation BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);