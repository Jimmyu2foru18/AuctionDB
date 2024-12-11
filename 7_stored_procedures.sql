USE auctionDB;

DELIMITER //

CREATE PROCEDURE SetTime(IN new_time DATETIME)
BEGIN
    UPDATE Time SET CurrentTime = new_time;
END//

CREATE PROCEDURE ProcessPayment(
    IN p_item_id INT,
    IN p_buyer_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_shipping_option_id INT
)
BEGIN
    DECLARE v_payment_id INT;
    

    INSERT INTO Payment (
        BuyerID, ItemID, Amount, Status, PaymentDate
    ) VALUES (
        p_buyer_id, p_item_id, p_amount, 'PAID', NOW()
    );
    

    INSERT INTO Sales (
        ItemID, BuyerID, FinalPrice, ShippingOptionID, Status, ShipByDate
    ) VALUES (
        p_item_id, p_buyer_id, p_amount, p_shipping_option_id, 'PAID', 
        DATE_ADD(NOW(), INTERVAL 2 DAY)
    );
    

    UPDATE Items 
    SET Status = 'SOLD'
    WHERE ItemID = p_item_id;
END//

CREATE PROCEDURE ProcessShipment(
    IN p_item_id INT,
    IN p_tracking_number VARCHAR(50)
)
BEGIN
    INSERT INTO Shipment (
        ItemID, TrackingNumber, Status, ShippedDate, EstimatedDeliveryDate
    ) VALUES (
        p_item_id, p_tracking_number, 'SHIPPED', NOW(),
        DATE_ADD(NOW(), INTERVAL 5 DAY)
    );
    
    UPDATE Sales
    SET Status = 'SHIPPED',
        TrackingNumber = p_tracking_number,
        ShippedDate = NOW()
    WHERE ItemID = p_item_id;
END//

CREATE PROCEDURE ConfirmDelivery(
    IN p_item_id INT
)
BEGIN

    UPDATE Shipment 
    SET Status = 'DELIVERED',
        Confirmation = TRUE,
        ActualDeliveryDate = NOW()
    WHERE ItemID = p_item_id;
    

    UPDATE Sales 
    SET Status = 'COMPLETED',
        DeliveryConfirmed = TRUE
    WHERE ItemID = p_item_id;
END//

DELIMITER ; 