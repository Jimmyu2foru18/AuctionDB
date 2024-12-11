USE auctionDB;

CREATE VIEW ActiveAuctions AS
SELECT 
    ItemID,
    Title,
    CurrentPrice,
    EndTime
FROM Items
WHERE Status = 'ACTIVE';

CREATE VIEW BidHistory AS
SELECT 
    ItemID,
    COUNT(*) as BidCount,
    MAX(Amount) as HighestBid
FROM Bids
GROUP BY ItemID;

CREATE VIEW UserBids AS
SELECT 
    u.Username,
    i.Title,
    b.Amount
FROM Bids b
JOIN Items i ON b.ItemID = i.ItemID
JOIN Users u ON b.BidderID = u.UserID;

CREATE VIEW SellerPerformance AS
SELECT 
    s.SellerID,
    u.Username,
    COUNT(r.ReviewID) as TotalReviews,
    AVG(r.Rating) as AverageRating,
    COUNT(DISTINCT i.ItemID) as ItemsSold
FROM Users u
LEFT JOIN Items i ON u.UserID = i.SellerID
LEFT JOIN Reviews r ON u.UserID = r.SellerID
WHERE u.UserType IN ('SELLER', 'BOTH')
GROUP BY s.SellerID, u.Username;