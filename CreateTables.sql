CREATE DATABASE PizzaDB;
USE PizzaDB;


CREATE TABLE basesprice (
    basesprice_Size VARCHAR(30),
    basesprice_Crust VARCHAR(30),
    basesprice_CustPrice DECIMAL(5,2),
    basesprice_BusPrice DECIMAL(5,2),
    PRIMARY KEY (basesprice_Size, basesprice_Crust)
);


CREATE TABLE customer (
    customer_CustID INT AUTO_INCREMENT PRIMARY KEY,
    customer_FName VARCHAR(30),
    customer_LName VARCHAR(30),
    customer_PhoneNum VARCHAR(30),
);


CREATE TABLE ordertable (
    ordertable_OrderID INT AUTO_INCREMENT PRIMARY KEY,
    customer_CustID INT,
    ordertable_OrderType VARCHAR(30),
    ordertable_OrderDateTime DATETIME,
    ordertable_CustPrice DECIMAL(5,2),
    ordertable_BusPrice DECIMAL(5,2),
    ordertable_isComplete BOOLEAN,
    FOREIGN KEY (customer_CustID) REFERENCES Customer(customer_CustID)
);


CREATE TABLE pizza (
    pizza_PizzaID INT AUTO_INCREMENT PRIMARY KEY,
    pizza_Size VARCHAR(30),
    pizza_Crust VARCHAR(30),
    pizza_OrderID INT,
    pizza_PizzaDate DATETIME,
    pizza_CustPrice DECIMAL(5,2),
    pizza_BusPrice DECIMAL(5,2),
    FOREIGN KEY (pizza_OrderID) REFERENCES ordertable(ordertable_OrderID),
    FOREIGN KEY (pizza_Size, pizza_Crust) REFERENCES basesprice(basesprice_Size, basesprice_Crust)
);


CREATE TABLE topping (
    topping_TopID INT AUTO_INCREMENT PRIMARY KEY,
    topping_TopName VARCHAR(30),
    topping_SmallAMT DECIMAL(5,2),
    topping_MedAMT DECIMAL(5,2),
    topping_LargeAMT DECIMAL(5,2),
    topping_SmallPrice DECIMAL(5,2),
    topping_MedPrice DECIMAL(5,2),
    topping_LargePrice DECIMAL(5,2),
    topping_MinInv INT,
    topping_CurInv INT
);


CREATE TABLE pizza_topping (
    pizza_PizzaID INT,
    topping_TopID INT,
    pizza_topping_isDouble BOOLEAN,
    PRIMARY KEY (pizza_PizzaID, topping_TopID),
    FOREIGN KEY (pizza_PizzaID) REFERENCES pizza(pizza_PizzaID),
    FOREIGN KEY (topping_TopID) REFERENCES topping(topping_TopID)
);


CREATE TABLE discount (
    discount_DiscountID INT AUTO_INCREMENT PRIMARY KEY,
    discount_DiscountName VARCHAR(30),
    discount_Amount DECIMAL(5,2),
    discount_IsPercent BOOLEAN
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
    pickup_IsPickedUp BOOLEAN,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);


CREATE TABLE delivery (
    ordertable_OrderID INT PRIMARY KEY,
    delivery_HouseNum INT,
    delivery_Street VARCHAR(40),
    delivery_Zip VARCHAR(10),
    delivery_IsDelivered BOOLEAN,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);


CREATE TABLE dinein (
    ordertable_OrderID INT PRIMARY KEY,
    dinein_TableNum INT,
    FOREIGN KEY (ordertable_OrderID) REFERENCES ordertable(ordertable_OrderID)
);