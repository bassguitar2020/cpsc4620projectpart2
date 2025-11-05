USE PizzaDB;
 
--PopulateData.sql
--Author: Kolby Turner

-- Base Prices
INSERT INTO basesprice (basesprice_Size, basesprice_Crust, basesprice_CustPrice, basesprice_BusPrice) VALUES
('Small','Thin',         3.00, 0.50),
('Small','Original',     3.00, 0.75),
('Small','Pan',          3.50, 1.00),
('Small','Gluten-Free',  4.00, 2.00),
('Medium','Thin',        5.00, 1.00),
('Medium','Original',    5.00, 1.50),
('Medium','Pan',         6.00, 2.25),
('Medium','Gluten-Free', 6.25, 3.00),
('Large','Thin',         8.00, 1.25),
('Large','Original',     8.00, 2.00),
('Large','Pan',          9.00, 3.00),
('Large','Gluten-Free',  9.50, 4.00),
('XLarge','Thin',       10.00, 2.00),
('XLarge','Original',   10.00, 3.00),
('XLarge','Pan',        11.50, 4.50),
('XLarge','Gluten-Free',12.50, 6.00);

-- Toppings
INSERT INTO topping
  (topping_TopName, topping_SmallAMT, topping_MedAMT, topping_LargeAMT,
   topping_SmallPrice, topping_MedPrice, topping_LargePrice,
   topping_MinInv, topping_CurInv)
VALUES
('Pepperoni',         2.00, 2.75, 3.50, 1.25, 1.25, 1.25, 50, 100),
('Sausage',           2.50, 3.00, 3.50, 1.25, 1.25, 1.25, 50, 100),
('Ham',               2.00, 2.50, 3.25, 1.50, 1.50, 1.50, 25,  78),
('Chicken',           1.50, 2.00, 2.25, 1.75, 1.75, 1.75, 25,  56),
('Green Pepper',      1.00, 1.50, 2.00, 0.50, 0.50, 0.50, 25,  79),
('Onion',             1.00, 1.50, 2.00, 0.50, 0.50, 0.50, 25,  85),
('Roma Tomato',       2.00, 3.00, 3.50, 0.75, 0.75, 0.75, 10,  86),
('Mushrooms',         1.50, 2.00, 2.50, 0.75, 0.75, 0.75, 50,  52),
('Black Olives',      0.75, 1.00, 1.50, 0.60, 0.60, 0.60, 25,  39),
('Pineapple',         1.00, 1.25, 1.75, 1.00, 1.00, 1.00,  0,  15),
('Jalapenos',         0.50, 0.75, 1.25, 0.50, 0.50, 0.50,  0,  64),
('Banana Peppers',    0.60, 1.00, 1.30, 0.50, 0.50, 0.50,  0,  36),
('Regular Cheese',    2.00, 3.50, 5.00, 0.50, 0.50, 0.50, 50, 250),
('Four Cheese Blend', 2.00, 3.50, 5.00, 1.00, 1.00, 1.00, 25, 150),
('Feta Cheese',       1.75, 3.00, 4.00, 1.50, 1.50, 1.50,  0,  75),
('Goat Cheese',       1.60, 2.75, 4.00, 1.50, 1.50, 1.50,  0,  54),
('Bacon',             1.00, 1.50, 2.00, 1.50, 1.50, 1.50,  0,  89);

-- Discounts
INSERT INTO discount (discount_DiscountName, discount_Amount, discount_IsPercent) VALUES
('Employee',             15.00, 1),
('Lunch Special Medium',  1.00, 0),
('Lunch Special Large',   2.00, 0),
('Specialty Pizza',       1.50, 0),
('Happy Hour',           10.00, 1),
('Gameday Special',      20.00, 1);
 
-- Customers
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum) VALUES
('Andrew','Wilkes-Krier','864-254-5861'),
('Matt','Engers','864-474-9953'),
('Frank','Turner','864-232-8944'),
('Milo','Auckerman','864-878-5679');

-- ORDERS + PIZZAS + TOPPINGS + DISCOUNTS

-- ORDER #1
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
VALUES (NULL, 'Dine-in', CONCAT(YEAR(CURDATE()),'-01-05 12:03:00'), NULL, NULL, 1);
 
INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
SELECT o.ordertable_OrderID, 21
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-05 12:03:00');
 
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'Large','Thin', o.ordertable_OrderID, o.ordertable_OrderDateTime, 19.75, 3.68
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-05 12:03:00');
 
-- toppings
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_isDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 1
FROM pizza p, topping t
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-01-05 12:03:00')
  AND t.topping_TopName = 'Regular Cheese';
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p, topping t
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-01-05 12:03:00')
  AND t.topping_TopName IN ('Pepperoni','Sausage');
 
-- pizza discount
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-01-05 12:03:00')
  AND d.discount_DiscountName = 'Lunch Special Large';
 
 
-- ORDER #2
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
VALUES (NULL, 'Dine-in', CONCAT(YEAR(CURDATE()),'-02-03 12:05:00'), NULL, NULL, 1);
 
INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
SELECT o.ordertable_OrderID, 4
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00');
 
-- A
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'Medium','Pan', o.ordertable_OrderID, o.ordertable_OrderDateTime, 12.85, 3.23
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00');
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Feta Cheese','Black Olives','Roma Tomato','Mushrooms','Banana Peppers')
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00')
  AND p.pizza_Size='Medium' AND p.pizza_Crust='Pan';
 
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00')
  AND p.pizza_Size='Medium' AND p.pizza_Crust='Pan'
  AND d.discount_DiscountName='Specialty Pizza';
 
-- B
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'Small','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 6.93, 1.40
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00');
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Regular Cheese','Chicken','Banana Peppers')
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00')
  AND p.pizza_Size='Small' AND p.pizza_Crust='Original';
 
-- order-level $1 discount
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
SELECT o.ordertable_OrderID, d.discount_DiscountID
FROM ordertable o, discount d
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00')
  AND d.discount_DiscountName='Lunch Special Medium';
 
-- recompute totals: $ first, then % (none here)
UPDATE ordertable o
SET
  o.ordertable_CustPrice = ROUND((
      (SELECT SUM(p.pizza_CustPrice) FROM pizza p WHERE p.pizza_OrderID=o.ordertable_OrderID)
      - (SELECT COALESCE(SUM(d.discount_Amount),0)
           FROM order_discount od JOIN discount d ON d.discount_DiscountID=od.discount_DiscountID
          WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=0)
    ) *
    EXP(COALESCE((
        SELECT SUM(LN(1 - (d.discount_Amount/100)))
        FROM order_discount od JOIN discount d ON d.discount_DiscountID=od.discount_DiscountID
        WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=1
    ),0)), 2)
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-03 12:05:00');
 
 
-- ORDER #3
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
SELECT c.customer_CustID, 'Pickup', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), NULL, NULL, 1
FROM customer c
WHERE c.customer_FName='Andrew' AND c.customer_LName='Wilkes-Krier';
 
INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp)
SELECT o.ordertable_OrderID, 1
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
 
-- insert the 6 identical pizzas (repeat 6 times)
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
INSERT INTO pizza SELECT 'Large','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 14.88, 3.30 FROM ordertable o WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00');
 
-- toppings for ALL pizzas in this order
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_isDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p, topping t, ordertable o
WHERE p.pizza_OrderID = o.ordertable_OrderID
  AND o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00')
  AND p.pizza_Size='Large' AND p.pizza_Crust='Original' AND p.pizza_CustPrice=14.88
  AND t.topping_TopName = 'Regular Cheese';
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p, topping t, ordertable o
WHERE p.pizza_OrderID = o.ordertable_OrderID
  AND o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-03 21:30:00')
  AND p.pizza_Size='Large' AND p.pizza_Crust='Original' AND p.pizza_CustPrice=14.88
  AND t.topping_TopName = 'Pepperoni';
-- (No order-level discounts; trigger’s totals are final here)
 
 
-- ORDER #4
INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_Zip, delivery_IsDelivered)
SELECT o.ordertable_OrderID, 115, 'Party Blvd', '29621', 1
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00');
 
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
SELECT c.customer_CustID, 'Delivery', CONCAT(YEAR(CURDATE()),'-02-20 19:11:00'), NULL, NULL, 1
FROM customer c
WHERE c.customer_FName='Andrew' AND c.customer_LName='Wilkes-Krier';
 
-- A
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'XLarge','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 27.94, 5.59
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00');
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Pepperoni','Sausage')
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00')
  AND p.pizza_CustPrice = 27.94;
 
-- B
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'XLarge','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 31.50, 6.25
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00');
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID,
       CASE WHEN t.topping_TopName IN ('Ham','Pineapple') THEN 1 ELSE 0 END
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Ham','Pineapple')
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00')
  AND p.pizza_CustPrice = 31.50;
 
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00')
  AND p.pizza_CustPrice = 31.50
  AND d.discount_DiscountName='Specialty Pizza';
 
-- C
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'XLarge','Original', o.ordertable_OrderID, o.ordertable_OrderDateTime, 26.75, 5.55
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00');
 
INSERT INTO pizza_topping
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Chicken','Bacon')
WHERE p.pizza_PizzaDate = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00')
  AND p.pizza_CustPrice = 26.75;
 
-- order-level percent discount
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
SELECT o.ordertable_OrderID, d.discount_DiscountID
FROM ordertable o, discount d
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00')
  AND d.discount_DiscountName='Gameday Special';
 
-- recompute totals: $ first, then %20
UPDATE ordertable o
SET
  o.ordertable_CustPrice = ROUND((
      (SELECT SUM(p.pizza_CustPrice) FROM pizza p WHERE p.pizza_OrderID=o.ordertable_OrderID)
      - (SELECT COALESCE(SUM(d.discount_Amount),0)
           FROM order_discount od JOIN discount d ON d.discount_DiscountID=od.discount_DiscountID
          WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=0)
    ) *
    EXP(COALESCE((
        SELECT SUM(LN(1 - (d.discount_Amount/100)))
        FROM order_discount od JOIN discount d ON d.discount_DiscountID=od.discount_DiscountID
        WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=1
    ),0)), 2)
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-02-20 19:11:00');
 
 
-- ORDER #5
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
SELECT c.customer_CustID, 'Pickup', CONCAT(YEAR(CURDATE()),'-01-02 17:30:00'), NULL, NULL, 1
FROM customer c
WHERE c.customer_FName='Matt' AND c.customer_LName='Engers';
 
INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp)
SELECT o.ordertable_OrderID, 1
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-02 17:30:00');
 
INSERT INTO pizza (pizza_Size, pizza_Crust, pizza_OrderID, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
SELECT 'XLarge','Gluten-Free', o.ordertable_OrderID, o.ordertable_OrderDateTime, 28.70, 7.84
FROM ordertable o
WHERE o.ordertable_OrderDateTime = CONCAT(YEAR(CURDATE()),'-01-02 17:30:00');
