USE PizzaDB;


DELIMITER //
CREATE PROCEDURE AddCustomer (
    IN fName VARCHAR(30),
    IN lName VARCHAR(30),
    IN phone VARCHAR(30)
)
BEGIN
    INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    VALUES (fName, lName, phone);
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE CreateOrder (
    IN custID INT,
    IN orderType VARCHAR(30)
)
BEGIN
    INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime, ordertable_isComplete)
    VALUES (custID, orderType, NOW(), FALSE);
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER UpdateOrderPrice_AfterPizzaInsert
AFTER INSERT ON pizza
FOR EACH ROW
BEGIN
    UPDATE ordertable
    SET ordertable_CustPrice = IFNULL(ordertable_CustPrice, 0) + NEW.pizza_CustPrice,
        ordertable_BusPrice = IFNULL(ordertable_BusPrice, 0) + NEW.pizza_BusPrice
    WHERE ordertable_OrderID = NEW.pizza_OrderID;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER ReduceToppingInventory_AfterInsert
AFTER INSERT ON pizza_topping
FOR EACH ROW
BEGIN
    UPDATE topping
    SET topping_CurInv = topping_CurInv - 1
    WHERE topping_TopID = NEW.topping_TopID;
END //
DELIMITER ;
