SHOW TABLES IN bronze.lakehouse;
SELECT count(*) FROM bronze.lakehouse.customer;
SELECT count(*) FROM bronze.lakehouse.orders;
SELECT count(*) FROM bronze.lakehouse.lineitem;
SELECT count(*) FROM bronze.lakehouse.nation;

-- Исходный запрос варианта 2. Данные берутся напрямую из генератора TPC-H.
SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.lakehouse.customer c
JOIN bronze.lakehouse.orders o ON c.custkey=o.custkey
JOIN bronze.lakehouse.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.lakehouse.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;
