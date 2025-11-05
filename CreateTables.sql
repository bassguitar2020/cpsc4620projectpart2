-- Created by Benjamin McDonnough
CREATE DATABASE PizzaDB;
USE PizzaDB;

CREATE TABLE baseprice (
    baseprice_Size VARCHAR(30),
    baseprice_CrustType VARCHAR(30),
    baseprice_CustPrice DECIMAL(5,2),
    baseprice_BusPrice DECIMAL(5,2),
    PRIMARY KEY (baseprice_Size, baseprice_CrustType)
);

CREATE TABLE customer (
    customer_CustID INT AUTO_INCREMENT PRIMARY KEY,
    customer_FName VARCHAR(30) NOT NULL,
    customer_LName VARCHAR(30) NOT NULL,
    customer_PhoneNum VARCHAR(30) NOT NULL
);

CREATE TABLE ordertable (
    ordertable_OrderID INT AUTO_INCREMENT PRIMARY KEY,
    customer_CustID INT,
    ordertable_OrderType VARCHAR(30) NOT NULL,
    ordertable_OrderDateTime DATETIME NOT NULL,
    ordertable_CustPrice DECIMAL(5,2) NOT NULL,
    ordertable_BusPrice DECIMAL(5,2) NOT NULL,
    ordertable_IsComplete BOOLEAN DEFAULT 0,
    FOREIGN KEY (customer_CustID) REFERENCES customer(customer_CustID)
);

CREATE TABLE pizza (
    pizza_PizzaID INT AUTO_INCREMENT PRIMARY KEY,
    pizza_Size VARCHAR(30),
    pizza_CrustType VARCHAR(30),
    ordertable_OrderID INT,
    pizza_PizzaDate DATETIME,
    pizza_CustPrice DECIMAL(5,2),
    pizza_BusPrice DECIMAL(5,2),
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID),
    FOREIGN KEY (pizza_Size, pizza_CrustType) REFERENCES baseprice(baseprice_Size, baseprice_CrustType)
);

CREATE TABLE topping (
    topping_TopID INT AUTO_INCREMENT PRIMARY KEY,
    topping_TopName VARCHAR(30) NOT NULL,
    topping_SmallAMT DECIMAL(5,2) NOT NULL,
    topping_MedAMT DECIMAL(5,2) NOT NULL,
    topping_LgAMT DECIMAL(5,2) NOT NULL,
    topping_XLAMT DECIMAL(5,2) NOT NULL,
    topping_CustPrice DECIMAL(5,2) NOT NULL,
    topping_BusPrice DECIMAL(5,2) NOT NULL,
    topping_MinINVT INT NOT NULL,
    topping_CurINVT INT NOT NULL
);

CREATE TABLE pizza_topping (
    pizza_PizzaID INT NOT NULL,
    topping_TopID INT NOT NULL,
    pizza_topping_IsDouble INT NOT NULL,
    PRIMARY KEY (pizza_PizzaID, topping_TopID),
    FOREIGN KEY (pizza_PizzaID) REFERENCES pizza(pizza_PizzaID),
    FOREIGN KEY (topping_TopID) REFERENCES topping(topping_TopID)
);

CREATE TABLE discount (
    discount_DiscountID INT AUTO_INCREMENT PRIMARY KEY,
    discount_DiscountName VARCHAR(30) NOT NULL,
    discount_Amount DECIMAL(5,2) NOT NULL,
    discount_IsPercent BOOLEAN NOT NULL
);

CREATE TABLE pizza_discount (
    pizza_PizzaID INT,
    discount_DiscountID INT,
    PRIMARY KEY (pizza_PizzaID, discount_DiscountID),
    FOREIGN KEY (pizza_PizzaID) REFERENCES pizza(pizza_PizzaID),
    FOREIGN KEY (discount_DiscountID) REFERENCES discount(discount_DiscountID)
);

CREATE TABLE order_discount (
    ordertable_OrderID INT,
    discount_DiscountID INT,
    PRIMARY KEY (ordertable_OrderID, discount_DiscountID),
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID),
    FOREIGN KEY (discount_DiscountID) REFERENCES discount(discount_DiscountID)
);

CREATE TABLE pickup (
    ordertable_OrderID INT PRIMARY KEY,
    pickup_IsPickedUp BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);

CREATE TABLE delivery (
    ordertable_OrderID INT PRIMARY KEY,
    delivery_HouseNum INT NOT NULL,
    delivery_Street VARCHAR(30) NOT NULL,
    delivery_City VARCHAR(30) NOT NULL,
    delivery_State VARCHAR(2) NOT NULL,
    delivery_Zip INT NOT NULL,
    delivery_IsDelivered BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);

CREATE TABLE dinein (
    ordertable_OrderID INT PRIMARY KEY,
    dinein_TableNum INT NOT NULL,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);

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

DELIMITER //
CREATE TRIGGER ReduceToppingInventory_AfterInsert
AFTER INSERT ON pizza_topping
FOR EACH ROW
BEGIN
    UPDATE topping
    SET topping_CurINVT = topping_CurINVT - 1
    WHERE topping_TopID = NEW.topping_TopID;
END //
DELIMITER ;