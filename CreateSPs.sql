-- Created by Benjamin McDonnough
USE PizzaDB;

DELIMITER //
CREATE PROCEDURE AddCustomerIfNotExists (
    IN fName VARCHAR(30),
    IN lName VARCHAR(30),
    IN phone VARCHAR(30)
)
BEGIN
    DECLARE custID INT;
    SELECT customer_CustID INTO custID
    FROM customer
    WHERE customer_FName = fName AND customer_LName = lName AND customer_PhoneNum = phone;

    IF custID IS NULL THEN
        INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
        VALUES (fName, lName, phone);
        SET custID = LAST_INSERT_ID();
    END IF;

    SELECT custID AS NewCustomerID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CreateOrder (
    IN custID INT,
    IN orderType VARCHAR(30),
    IN orderDateTime DATETIME,
    IN custPrice DECIMAL(6,2),
    IN busPrice DECIMAL(6,2),
    IN isComplete BOOLEAN,
    IN tableNum INT,
    IN houseNum INT,
    IN street VARCHAR(40),
    IN zip VARCHAR(10),
    IN isDelivered BOOLEAN,
    IN isPickedUp BOOLEAN
)
BEGIN
    DECLARE orderID INT;

    INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                            ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
    VALUES (custID, orderType, orderDateTime, custPrice, busPrice, isComplete);
    SET orderID = LAST_INSERT_ID();

    IF orderType = 'Dine-in' THEN
        INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
        VALUES (orderID, tableNum);
    END IF;

    IF orderType = 'Pickup' THEN
        INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp)
        VALUES (orderID, isPickedUp);
    END IF;

    IF orderType = 'Delivery' THEN
        INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_Zip, delivery_IsDelivered)
        VALUES (orderID, houseNum, street, zip, isDelivered);
    END IF;

    SELECT orderID AS NewOrderID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddPizza (
    IN orderID INT,
    IN size VARCHAR(30),
    IN crust VARCHAR(30),
    IN pizzaDate DATETIME,
    IN custPrice DECIMAL(6,2),
    IN busPrice DECIMAL(6,2)
)
BEGIN
    INSERT INTO pizza (ordertable_OrderID, pizza_Size, pizza_CrustType, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
    VALUES (orderID, size, crust, pizzaDate, custPrice, busPrice);
    SELECT LAST_INSERT_ID() AS NewPizzaID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddPizzaTopping (
    IN pizzaID INT,
    IN toppingID INT,
    IN isDouble BOOLEAN
)
BEGIN
    INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_isDouble)
    VALUES (pizzaID, toppingID, isDouble);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddDiscountToOrder (
    IN orderID INT,
    IN discountID INT
)
BEGIN
    INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
    VALUES (orderID, discountID);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddDiscountToPizza (
    IN pizzaID INT,
    IN discountID INT
)
BEGIN
    INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
    VALUES (pizzaID, discountID);
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
    WHERE ordertable_OrderID = NEW.ordertable_OrderID;
END //
DELIMITER ;

