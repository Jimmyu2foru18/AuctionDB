USE auctionDB;

DELIMITER //

CREATE TRIGGER before_bid_insert
BEFORE INSERT ON Bids
FOR EACH ROW
BEGIN
    IF NEW.Amount <= (SELECT CurrentPrice FROM Items WHERE ItemID = NEW.ItemID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bid too low';
    END IF;
    
    IF NEW.BidderID = (SELECT SellerID FROM Items WHERE ItemID = NEW.ItemID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot bid on own item';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Users 
                  WHERE UserID = NEW.BidderID 
                  AND HasPaymentInfo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment info required';
    END IF;
END//

CREATE TRIGGER after_bid_insert
AFTER INSERT ON Bids
FOR EACH ROW
BEGIN
    UPDATE Items 
    SET CurrentPrice = NEW.Amount,
        NumberOfBids = NumberOfBids + 1
    WHERE ItemID = NEW.ItemID;
END//

CREATE TRIGGER after_sale_insert
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    UPDATE Sales
    SET ShipByDate = DATE_ADD(NOW(), INTERVAL 2 DAY)
    WHERE ItemID = NEW.ItemID;
    
    UPDATE Items
    SET Status = 'SOLD'
    WHERE ItemID = NEW.ItemID;
END//

CREATE TRIGGER before_payment_insert
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    DECLARE card_expiry DATE;
    
    SELECT ExpirationDate INTO card_expiry
    FROM PaymentInformation
    WHERE BuyerID = NEW.BuyerID;

    IF card_expiry <= CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Credit card is expired';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Bids b
        JOIN Items i ON b.ItemID = i.ItemID
        WHERE b.BidderID = NEW.BuyerID 
        AND b.Amount = i.CurrentPrice
        AND i.Status = 'ACTIVE'
        AND i.ItemID = NEW.ItemID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User is not the winning bidder';
    END IF;
END//

CREATE TRIGGER after_payment_success
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Status = 'PAID' AND OLD.Status = 'PENDING' THEN
        UPDATE Sales 
        SET Status = 'PAID',
            ShipByDate = DATE_ADD(NOW(), INTERVAL 2 DAY)
        WHERE ItemID = NEW.ItemID;

        UPDATE Items
        SET Status = 'SOLD'
        WHERE ItemID = NEW.ItemID;
    END IF;
END//

CREATE TRIGGER before_shipment_insert
BEFORE INSERT ON Shipment
FOR EACH ROW
BEGIN
    DECLARE payment_status VARCHAR(20);

    SELECT Status INTO payment_status
    FROM Payment
    WHERE ItemID = NEW.ItemID;
    
    IF payment_status != 'PAID' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create shipment before payment';
    END IF;
END//

CREATE TRIGGER after_shipment_update
AFTER UPDATE ON Shipment
FOR EACH ROW
BEGIN
    IF NEW.TrackingNumber IS NOT NULL AND OLD.TrackingNumber IS NULL THEN
        UPDATE Sales
        SET ShippedDate = NOW(),
            Status = 'SHIPPED',
            TrackingNumber = NEW.TrackingNumber
        WHERE ItemID = NEW.ItemID;
    END IF;
    
    IF NEW.Confirmation = TRUE AND OLD.Confirmation = FALSE THEN
        UPDATE Sales
        SET Status = 'COMPLETED',
            DeliveryConfirmed = TRUE
        WHERE ItemID = NEW.ItemID;
        
        UPDATE Shipment
        SET ActualDeliveryDate = NOW()
        WHERE ShipmentID = NEW.ShipmentID;
    END IF;
END//

DELIMITER ; 