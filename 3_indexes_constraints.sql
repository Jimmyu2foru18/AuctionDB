USE auctionDB;

CREATE INDEX idx_seller ON Items(SellerID);
CREATE INDEX idx_item ON Bids(ItemID);
CREATE INDEX idx_bidder ON Bids(BidderID);
CREATE INDEX idx_user_email ON Users(Email);
CREATE INDEX idx_category ON ItemCategories(CategoryID);
CREATE INDEX idx_shipping ON Sales(ShippingOptionID);
CREATE INDEX idx_seller_bank ON BankInformation(SellerID);


ALTER TABLE Users
    ADD CONSTRAINT valid_user_type 
    CHECK (UserType IN ('BUYER', 'SELLER', 'BOTH'));

ALTER TABLE Items
    ADD CONSTRAINT valid_prices 
    CHECK (StartingPrice > 0),
    ADD CONSTRAINT valid_times
    CHECK (EndTime > StartTime);

ALTER TABLE Bids
    ADD CONSTRAINT valid_bid 
    CHECK (Amount > 0),
    ADD CONSTRAINT valid_bid_time 
    CHECK (BidTime BETWEEN (SELECT StartTime FROM Items WHERE ItemID = Bids.ItemID) 
                      AND (SELECT EndTime FROM Items WHERE ItemID = Bids.ItemID)),
    ADD CONSTRAINT no_self_bids
    CHECK (BidderID != (SELECT SellerID FROM Items WHERE ItemID = Bids.ItemID)),
    UNIQUE (ItemID, Amount),
    UNIQUE (ItemID, BidTime);

ALTER TABLE Sales
    ADD CONSTRAINT valid_status 
    CHECK (Status IN ('PENDING', 'PAID', 'COMPLETED'));

ALTER TABLE Reviews
    ADD CONSTRAINT valid_rating 
    CHECK (Rating BETWEEN 1 AND 5),
    ADD CONSTRAINT unique_review
    UNIQUE (BuyerID, SellerID, ItemID);

ALTER TABLE ShippingOptions
    ADD CONSTRAINT valid_shipping_type
    CHECK (Type IN ('PICKUP', 'STANDARD', 'EXPRESS'));

ALTER TABLE PaymentInformation
    ADD CONSTRAINT valid_expiration
    CHECK (ExpirationDate > CURRENT_DATE);

