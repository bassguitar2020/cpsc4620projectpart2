USE PizzaDB;

-- CreateViews.sql
-- Author: Kolby Turner


-- VIEW 1: ToppingPopularity
DROP VIEW IF EXISTS ToppingPopularity;
CREATE VIEW ToppingPopularity AS
SELECT
  t.topping_TopName AS Topping,
  SUM(CASE WHEN pt.pizza_topping_isDouble = 1 THEN 2 ELSE 1 END) AS ToppingCount
FROM pizza_topping pt
JOIN topping t ON t.topping_TopID = pt.topping_TopID
GROUP BY t.topping_TopName
ORDER BY ToppingCount DESC, Topping ASC;

-- VIEW 2: ProfitByPizza
DROP VIEW IF EXISTS ProfitByPizza;
CREATE VIEW ProfitByPizza AS
SELECT
  DATE_FORMAT(p.pizza_PizzaDate, '%Y-%m') AS `Month`,
  p.pizza_Size AS `Size`,
  p.pizza_Crust AS `Crust`,
  ROUND(SUM(p.pizza_CustPrice - p.pizza_BusPrice), 2) AS Profit
FROM pizza p
GROUP BY DATE_FORMAT(p.pizza_PizzaDate, '%Y-%m'), p.pizza_Size, p.pizza_Crust
ORDER BY Profit DESC;

-- VIEW 3: ProfitByOrderType
DROP VIEW IF EXISTS ProfitByOrderType;
CREATE VIEW ProfitByOrderType AS
WITH OrderProfits AS (
  SELECT
    DATE_FORMAT(o.ordertable_OrderDateTime, '%Y-%m') AS `Month`,
    o.ordertable_OrderType AS OrderType,
    ROUND(o.ordertable_CustPrice - o.ordertable_BusPrice, 2) AS Profit
  FROM ordertable o
)
SELECT `Month`, OrderType, ROUND(SUM(Profit), 2) AS Profit
FROM OrderProfits
GROUP BY `Month`, OrderType

UNION ALL

SELECT 'ALL' AS `Month`, 'Grand Total' AS OrderType, ROUND(SUM(Profit), 2) AS Profit
FROM OrderProfits
ORDER BY Profit DESC;