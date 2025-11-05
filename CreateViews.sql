USE PizzaDB;

-- CreateViews.sql
-- Author: Kolby Turner

-- VIEW 1: ToppingPopularity
DROP VIEW IF EXISTS ToppingPopularity;
CREATE VIEW ToppingPopularity AS
SELECT
  t.topping_TopName AS Topping,
  COALESCE(SUM(CASE WHEN pt.pizza_topping_IsDouble = 1 THEN 2 ELSE 1 END), 0) AS ToppingCount
FROM topping t
LEFT JOIN pizza_topping pt ON pt.topping_TopID = t.topping_TopID
GROUP BY t.topping_TopName;
  COALESCE(SUM(CASE WHEN pt.pizza_topping_IsDouble = 1 THEN 2 ELSE 1 END), 0) AS ToppingCount
FROM topping t
LEFT JOIN pizza_topping pt ON t.topping_TopID = pt.topping_TopID
GROUP BY t.topping_TopName
ORDER BY ToppingCount DESC, Topping ASC;

-- VIEW 2: ProfitByPizza
DROP VIEW IF EXISTS ProfitByPizza;
CREATE VIEW ProfitByPizza AS
SELECT
  p.pizza_Size AS Size,
  p.pizza_CrustType AS Crust,
  ROUND(SUM(p.pizza_CustPrice - p.pizza_BusPrice), 2) AS Profit,
  DATE_FORMAT(p.pizza_PizzaDate, '%c/%Y') AS OrderMonth
FROM pizza p
GROUP BY DATE_FORMAT(p.pizza_PizzaDate, '%Y-%m'), p.pizza_Size, p.pizza_CrustType
ORDER BY Profit ASC;

-- VIEW 3: ProfitByOrderType
DROP VIEW IF EXISTS ProfitByOrderType;
CREATE VIEW ProfitByOrderType AS
SELECT
  o.ordertable_OrderType AS `OrderType`,
  DATE_FORMAT(o.ordertable_OrderDateTime, '%Y-%m') AS `OrderMonth`,
  ROUND(SUM(o.ordertable_CustPrice - o.ordertable_BusPrice), 2) AS `Profit`,
  ROUND(SUM(o.ordertable_BusPrice), 2) AS `TotalOrderCost`,
  ROUND(SUM(o.ordertable_CustPrice), 2) AS `TotalOrderPrice`
SELECT 
  LOWER(o.ordertable_OrderType) AS CustomerType,
  CASE 
    WHEN GROUPING(DATE_FORMAT(o.ordertable_OrderDateTime, '%c/%Y')) = 1 THEN 'Grand Total'
    ELSE DATE_FORMAT(o.ordertable_OrderDateTime, '%c/%Y')
  END AS OrderMonth,
  ROUND(SUM(o.ordertable_CustPrice), 2) AS TotalOrderPrice,
  ROUND(SUM(o.ordertable_BusPrice), 2) AS TotalOrderCost,
  ROUND(SUM(o.ordertable_CustPrice - o.ordertable_BusPrice), 2) AS Profit
FROM ordertable o
GROUP BY o.ordertable_OrderType, DATE_FORMAT(o.ordertable_OrderDateTime, '%Y-%m');

GROUP BY o.ordertable_OrderType, DATE_FORMAT(o.ordertable_OrderDateTime, '%c/%Y')
WITH ROLLUP;