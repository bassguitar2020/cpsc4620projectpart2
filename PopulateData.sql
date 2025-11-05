USE PizzaDB;

-- PopulateData.sql
-- Author: Kolby Turner and Benjamin McDonnough

-- Base Prices
INSERT INTO baseprice (baseprice_Size, baseprice_CrustType, baseprice_CustPrice, baseprice_BusPrice) VALUES
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
  (topping_TopName, topping_SmallAMT, topping_MedAMT, topping_LgAMT, topping_XLAMT,
   topping_CustPrice, topping_BusPrice, topping_MinINVT, topping_CurINVT)
VALUES
('Pepperoni',         2.00, 2.75, 3.50, 4.50, 1.25, 0.20, 50, 100),
('Sausage',           2.50, 3.00, 3.50, 4.25, 1.25, 0.15, 50, 100),
('Ham',               2.00, 2.50, 3.25, 4.00, 1.50, 0.15, 25,  78),
('Chicken',           1.50, 2.00, 2.25, 3.00, 1.75, 0.25, 25,  56),
('Green Pepper',      1.00, 1.50, 2.00, 2.50, 0.50, 0.02, 25,  79),
('Onion',             1.00, 1.50, 2.00, 2.75, 0.50, 0.02, 25,  85),
('Roma Tomato',       2.00, 3.00, 3.50, 4.50, 0.75, 0.03, 10,  86),
('Mushrooms',         1.50, 2.00, 2.50, 3.00, 0.75, 0.10, 50,  52),
('Black Olives',      0.75, 1.00, 1.50, 2.00, 0.60, 0.10, 25,  39),
('Pineapple',         1.00, 1.25, 1.75, 2.00, 1.00, 0.25,  0,  15),
('Jalapenos',         0.50, 0.75, 1.25, 1.75, 0.50, 0.05,  0,  64),
('Banana Peppers',    0.60, 1.00, 1.30, 1.75, 0.50, 0.05,  0,  36),
('Regular Cheese',    2.00, 3.50, 5.00, 7.00, 0.50, 0.12, 50, 250),
('Four Cheese Blend', 2.00, 3.50, 5.00, 7.00, 1.00, 0.15, 25, 150),
('Feta Cheese',       1.75, 3.00, 4.00, 5.50, 1.50, 0.18,  0,  75),
('Goat Cheese',       1.60, 2.75, 4.00, 5.50, 1.50, 0.20,  0,  54),
('Bacon',             1.00, 1.50, 2.00, 3.00, 1.50, 0.25,  0,  89);

--Discounts
INSERT INTO discount (discount_DiscountName, discount_Amount, discount_IsPercent) VALUES
('Employee',             15.00, 1),
('Lunch Special Medium',  1.00, 0),
('Lunch Special Large',   2.00, 0),
('Specialty Pizza',       1.50, 0),
('Happy Hour',           10.00, 1),
('Gameday Special',      20.00, 1);

--Customers
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum) VALUES
('Andrew','Wilkes-Krier','8642545861'),
('Matt','Engers','8644749953'),
('Frank','Turner','8642328944'),
('Milo','Auckerman','8648785679');

--ORDERS

-- ORDER #1
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
VALUES (NULL, 'dinein', CONCAT(YEAR(CURDATE()),'-01-05 12:03:00'), 0.00, 0.00, 1);
SET @o1 := LAST_INSERT_ID();

INSERT INTO dinein (ordertable_OrderID, dinein_TableNum) VALUES
(@o1, 21);

INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Large','Thin', @o1, 'completed', CONCAT(YEAR(CURDATE()),'-01-05 12:03:00'), 19.75, 3.68);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 1
FROM pizza p JOIN topping t ON t.topping_TopName='Regular Cheese'
WHERE p.ordertable_OrderID=@o1;

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p JOIN topping t ON t.topping_TopName IN ('Pepperoni','Sausage')
WHERE p.ordertable_OrderID=@o1;

INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.ordertable_OrderID=@o1 AND d.discount_DiscountName='Lunch Special Large';

-- Recompute totals for order #1
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = (
      SELECT SUM(p.pizza_CustPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  ),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID = @o1;


-- ORDER #2
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
VALUES (NULL, 'dinein', CONCAT(YEAR(CURDATE()),'-02-03 12:05:00'), 0.00, 0.00, 1);
SET @o2 := LAST_INSERT_ID();

INSERT INTO dinein (ordertable_OrderID, dinein_TableNum) VALUES
(@o2, 4);

-- A
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Medium','Pan', @o2, 'completed', CONCAT(YEAR(CURDATE()),'-02-03 12:05:00'), 12.85, 3.23);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Feta Cheese','Black Olives','Roma Tomato','Mushrooms','Banana Peppers')
WHERE p.ordertable_OrderID=@o2 AND p.pizza_Size='Medium' AND p.pizza_CrustType='Pan';

INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.ordertable_OrderID=@o2 AND p.pizza_Size='Medium' AND p.pizza_CrustType='Pan'
  AND d.discount_DiscountName='Specialty Pizza';

-- B
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Small','Original', @o2, 'completed', CONCAT(YEAR(CURDATE()),'-02-03 12:05:00'), 6.93, 1.40);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Regular Cheese','Chicken','Banana Peppers')
WHERE p.ordertable_OrderID=@o2 AND p.pizza_Size='Small' AND p.pizza_CrustType='Original';

-- Order-level $1 off
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
SELECT @o2, d.discount_DiscountID
FROM discount d WHERE d.discount_DiscountName='Lunch Special Medium';

-- Recompute totals for order #2
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = ROUND((
      (SELECT SUM(p.pizza_CustPrice) FROM pizza p WHERE p.ordertable_OrderID=o.ordertable_OrderID)
      - (SELECT COALESCE(SUM(d.discount_Amount),0)
           FROM order_discount od JOIN discount d USING(discount_DiscountID)
          WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=0)
    ) *
    EXP(COALESCE((
      SELECT SUM(LN(1 - (d.discount_Amount/100)))
      FROM order_discount od JOIN discount d USING(discount_DiscountID)
      WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=1
    ),0)), 2),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID=@o2;


-- ORDER #3
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
SELECT c.customer_CustID, 'pickup', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 0.00, 0.00, 1
FROM customer c WHERE c.customer_FName='Andrew' AND c.customer_LName='Wilkes-Krier';
SET @o3 := LAST_INSERT_ID();

INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp) VALUES
(@o3, 1);

INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES 
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30),
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30),
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30),
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30),
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30),
('Large','Original', @o3, 'completed', CONCAT(YEAR(CURDATE()),'-01-03 21:30:00'), 14.88, 3.30);

-- Toppings for all pizzas in order #3
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName='Regular Cheese'
WHERE p.ordertable_OrderID=@o3;

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName='Pepperoni'
WHERE p.ordertable_OrderID=@o3;

-- Recompute totals for order #3
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = (
      SELECT SUM(p.pizza_CustPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  ),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID = @o3;


-- ORDER #4
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
SELECT c.customer_CustID, 'delivery', CONCAT(YEAR(CURDATE()),'-02-20 19:11:00'), 0.00, 0.00, 1
FROM customer c WHERE c.customer_FName='Andrew' AND c.customer_LName='Wilkes-Krier';
SET @o4 := LAST_INSERT_ID();

INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_City, delivery_State, delivery_Zip, delivery_IsDelivered) VALUES
(@o4, 115, 'Party Blvd', 'Anderson', 'SC', 29621, 1);

-- A
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('XLarge','Original', @o4, 'completed', CONCAT(YEAR(CURDATE()),'-02-20 19:11:00'), 27.94, 5.59);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Pepperoni','Sausage')
WHERE p.ordertable_OrderID=@o4 AND p.pizza_CustPrice=27.94;

-- B
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('XLarge','Original', @o4, 'completed', CONCAT(YEAR(CURDATE()),'-02-20 19:11:00'), 31.50, 6.25);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID,
       CASE WHEN t.topping_TopName IN ('Ham','Pineapple') THEN 1 ELSE 0 END
FROM pizza p JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Ham','Pineapple')
WHERE p.ordertable_OrderID=@o4 AND p.pizza_CustPrice=31.50;

INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.ordertable_OrderID=@o4 AND p.pizza_CustPrice=31.50
  AND d.discount_DiscountName='Specialty Pizza';

-- C
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('XLarge','Original', @o4, 'completed', CONCAT(YEAR(CURDATE()),'-02-20 19:11:00'), 26.75, 5.55);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p JOIN topping t ON t.topping_TopName IN ('Four Cheese Blend','Chicken','Bacon')
WHERE p.ordertable_OrderID=@o4 AND p.pizza_CustPrice=26.75;

-- Order-level % discount
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
SELECT @o4, d.discount_DiscountID FROM discount d WHERE d.discount_DiscountName='Gameday Special';

-- Recompute totals for order #4
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = ROUND((
      (SELECT SUM(p.pizza_CustPrice) FROM pizza p WHERE p.ordertable_OrderID=o.ordertable_OrderID)
      - (SELECT COALESCE(SUM(d.discount_Amount),0)
           FROM order_discount od JOIN discount d USING(discount_DiscountID)
          WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=0)
    ) *
    EXP(COALESCE((
      SELECT SUM(LN(1 - (d.discount_Amount/100)))
      FROM order_discount od JOIN discount d USING(discount_DiscountID)
      WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=1
    ),0)), 2),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID=@o4;


-- ORDER #5
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
SELECT c.customer_CustID, 'pickup', CONCAT(YEAR(CURDATE()),'-01-02 17:30:00'), 0.00, 0.00, 1
FROM customer c WHERE c.customer_FName='Matt' AND c.customer_LName='Engers';
SET @o5 := LAST_INSERT_ID();

INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp) VALUES
(@o5, 1);

INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('XLarge','Gluten-Free', @o5, 'completed', CONCAT(YEAR(CURDATE()),'-01-02 17:30:00'), 28.70, 7.84);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 0
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Goat Cheese','Green Pepper','Onion','Roma Tomato','Mushrooms','Black Olives')
WHERE p.ordertable_OrderID=@o5;

INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
SELECT p.pizza_PizzaID, d.discount_DiscountID
FROM pizza p, discount d
WHERE p.ordertable_OrderID=@o5 AND d.discount_DiscountName='Specialty Pizza';

-- Recompute totals for order #5
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = (
      SELECT SUM(p.pizza_CustPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  ),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID = @o5;


-- ORDER #6
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
SELECT c.customer_CustID, 'delivery', CONCAT(YEAR(CURDATE()),'-01-02 18:17:00'), 0.00, 0.00, 1
FROM customer c WHERE c.customer_FName='Frank' AND c.customer_LName='Turner';
SET @o6 := LAST_INSERT_ID();

INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_City, delivery_State, delivery_Zip, delivery_IsDelivered) VALUES
(@o6, 6745, 'Wessex St', 'Anderson', 'SC', 29621, 1);

INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Large','Thin', @o6, 'completed', CONCAT(YEAR(CURDATE()),'-01-02 18:17:00'), 25.81, 3.64);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID,
       CASE WHEN t.topping_TopName='Four Cheese Blend' THEN 1 ELSE 0 END
FROM pizza p
JOIN topping t ON t.topping_TopName IN ('Chicken','Green Pepper','Onion','Mushrooms','Four Cheese Blend')
WHERE p.ordertable_OrderID=@o6;

-- Recompute totals for order #6
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = (
      SELECT SUM(p.pizza_CustPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  ),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID = @o6;


-- ORDER #7
INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime,
                        ordertable_CustPrice, ordertable_BusPrice, ordertable_IsComplete)
SELECT c.customer_CustID, 'delivery', CONCAT(YEAR(CURDATE()),'-02-13 20:32:00'), 0.00, 0.00, 1
FROM customer c WHERE c.customer_FName='Milo' AND c.customer_LName='Auckerman';
SET @o7 := LAST_INSERT_ID();

INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_City, delivery_State, delivery_Zip, delivery_IsDelivered) VALUES
(@o7, 8879, 'Suburban Lane', 'Anderson', 'SC', 29621, 1);

-- A
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Large','Thin', @o7, 'completed', CONCAT(YEAR(CURDATE()),'-02-13 20:32:00'), 18.00, 2.75);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID, 1
FROM pizza p JOIN topping t ON t.topping_TopName='Four Cheese Blend'
WHERE p.ordertable_OrderID=@o7 AND p.pizza_CustPrice=18.00;

-- B
INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
VALUES ('Large','Thin', @o7, 'completed', CONCAT(YEAR(CURDATE()),'-02-13 20:32:00'), 19.25, 3.25);

INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
SELECT p.pizza_PizzaID, t.topping_TopID,
       CASE WHEN t.topping_TopName='Pepperoni' THEN 1 ELSE 0 END
FROM pizza p JOIN topping t ON t.topping_TopName IN ('Regular Cheese','Pepperoni')
WHERE p.ordertable_OrderID=@o7 AND p.pizza_CustPrice=19.25;

-- Order-level % discount (Employee 15%)
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
SELECT @o7, d.discount_DiscountID FROM discount d WHERE d.discount_DiscountName='Employee';

-- Recompute totals for order #7
UPDATE ordertable o
SET 
  o.ordertable_CustPrice = ROUND((
      (SELECT SUM(p.pizza_CustPrice) FROM pizza p WHERE p.ordertable_OrderID=o.ordertable_OrderID)
      - (SELECT COALESCE(SUM(d.discount_Amount),0)
           FROM order_discount od JOIN discount d USING(discount_DiscountID)
          WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=0)
    ) *
    EXP(COALESCE((
      SELECT SUM(LN(1 - (d.discount_Amount/100)))
      FROM order_discount od JOIN discount d USING(discount_DiscountID)
      WHERE od.ordertable_OrderID=o.ordertable_OrderID AND d.discount_IsPercent=1
    ),0)), 2),
  o.ordertable_BusPrice = (
      SELECT SUM(p.pizza_BusPrice)
      FROM pizza p
      WHERE p.ordertable_OrderID = o.ordertable_OrderID
  )
WHERE o.ordertable_OrderID=@o7;
