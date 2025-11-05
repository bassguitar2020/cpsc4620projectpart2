USE PizzaDB;

-- CreateViews.sql
-- Author: Kolby Turner

-- VIEW 1: ToppingPopularity
DROP VIEW IF EXISTS ToppingPopularity;
CREATE VIEW ToppingPopularity AS
SELECT
    t.topping_TopName AS Topping,
    COALESCE(SUM(
        CASE
            WHEN pt.pizza_topping_IsDouble = 1 THEN 2
            WHEN pt.pizza_topping_IsDouble = 0 THEN 1
            ELSE 0
        END
    ), 0) AS ToppingCount
FROM topping t
LEFT JOIN pizza_topping pt ON pt.topping_TopID = t.topping_TopID
GROUP BY t.topping_TopName
ORDER BY ToppingCount DESC, Topping ASC;

-- VIEW 2: ProfitByPizza
DROP VIEW IF EXISTS ProfitByPizza;
CREATE VIEW ProfitByPizza AS
SELECT
    p.pizza_Size AS Size,
    p.pizza_CrustType AS Crust,
    ROUND(SUM(p.pizza_CustPrice - p.pizza_BusPrice), 2) AS Profit,
    DATE_FORMAT(MIN(p.pizza_PizzaDate), '%c/%Y') AS OrderMonth
FROM pizza p
GROUP BY DATE_FORMAT(p.pizza_PizzaDate, '%Y-%m'), p.pizza_Size, p.pizza_CrustType
ORDER BY Profit ASC;

-- VIEW 3: ProfitByOrderType
DROP VIEW IF EXISTS ProfitByOrderType;
CREATE VIEW ProfitByOrderType AS
SELECT
    CASE WHEN GROUPING(order_type) = 1 THEN ''
         ELSE order_type
    END AS CustomerType,
    CASE WHEN GROUPING(order_month_key) = 1 THEN 'Grand Total'
         ELSE order_month_label
    END AS OrderMonth,
    ROUND(SUM(total_cust_price), 2) AS TotalOrderPrice,
    ROUND(SUM(total_bus_price), 2) AS TotalOrderCost,
    ROUND(SUM(total_cust_price - total_bus_price), 2) AS Profit
FROM (
    SELECT
        LOWER(ordertable_OrderType) AS order_type,
        DATE_FORMAT(ordertable_OrderDateTime, '%Y-%m') AS order_month_key,
        DATE_FORMAT(ordertable_OrderDateTime, '%c/%Y') AS order_month_label,
        ordertable_CustPrice AS total_cust_price,
        ordertable_BusPrice AS total_bus_price
    FROM ordertable
) grouped_orders
GROUP BY order_type, order_month_key
WITH ROLLUP
HAVING NOT (GROUPING(order_month_key) = 1 AND GROUPING(order_type) = 0);
