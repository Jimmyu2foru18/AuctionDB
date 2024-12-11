USE auctionDB;

INSERT INTO Time VALUES (NOW());

INSERT INTO Users (UserID, Username, Email, Name, UserType, HasPaymentInfo) VALUES
(1, 'john', 'john@email.com', 'John Doe', 'SELLER', TRUE),
(2, 'mary', 'mary@email.com', 'Mary Manson', 'BUYER', TRUE),
(3, 'sam', 'sam@email.com', 'Sam Wilson', 'BOTH', TRUE);

INSERT INTO Items (ItemID, Title, SellerID, StartTime, EndTime, StartingPrice, CurrentPrice, Status) VALUES
(1, 'Laptop', 1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 500.00, 500.00, 'ACTIVE'),
(2, 'Book', 3, NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), 50.00, 50.00, 'ACTIVE'); 