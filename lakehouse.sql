-- Bronze: сохраняем все колонки и строки исходных таблиц TPC-H sf1.
CREATE SCHEMA IF NOT EXISTS bronze.lakehouse;
CREATE TABLE IF NOT EXISTS bronze.lakehouse.customer WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.customer;
CREATE TABLE IF NOT EXISTS bronze.lakehouse.orders WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.orders;
CREATE TABLE IF NOT EXISTS bronze.lakehouse.lineitem WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.lineitem;
CREATE TABLE IF NOT EXISTS bronze.lakehouse.nation WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.nation;

CREATE SCHEMA IF NOT EXISTS silver.lakehouse;

-- Добавляем к клиенту название страны.
CREATE TABLE IF NOT EXISTS silver.lakehouse.customer_nation
WITH (format='PARQUET') AS
SELECT c.custkey, c.name, CAST(c.acctbal AS DECIMAL(15,2)) AS acctbal,
       n.name AS nation, c.address, c.phone, c.comment
FROM bronze.lakehouse.customer c
JOIN bronze.lakehouse.nation n ON c.nationkey=n.nationkey;

-- Оставляем возвращённые позиции заказов за IV квартал 1993 года.
-- DECIMAL хранит денежные значения точно; discount = 0.10 означает скидку 10%.
CREATE TABLE IF NOT EXISTS silver.lakehouse.returned_items_q4
WITH (format='PARQUET') AS
SELECT o.custkey, o.orderkey, o.orderdate, l.linenumber,
       CAST(l.extendedprice AS DECIMAL(15,2)) AS extendedprice,
       CAST(l.discount AS DECIMAL(4,2)) AS discount,
       CAST(l.extendedprice AS DECIMAL(15,2)) *
         (DECIMAL '1.00'-CAST(l.discount AS DECIMAL(4,2))) AS net_revenue
FROM bronze.lakehouse.orders o
JOIN bronze.lakehouse.lineitem l ON o.orderkey=l.orderkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R';

CREATE SCHEMA IF NOT EXISTS gold.lakehouse;
-- Складываем выручку по клиентам и оставляем первые 20 строк.
CREATE TABLE IF NOT EXISTS gold.lakehouse.returned_item_top20
WITH (format='PARQUET') AS
SELECT c.custkey, c.name, SUM(f.net_revenue) AS revenue, c.acctbal,
       c.nation, c.address, c.phone, c.comment
FROM silver.lakehouse.customer_nation c
JOIN silver.lakehouse.returned_items_q4 f ON c.custkey=f.custkey
GROUP BY c.custkey, c.name, c.acctbal, c.nation, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;

-- При чтении таблицы снова задаём сортировку: сама таблица не хранит порядок строк.
SELECT * FROM gold.lakehouse.returned_item_top20 ORDER BY revenue DESC, custkey;

-- Примеры Silver. Эти команды выполняются отдельно на учебных таблицах.
-- Изменение схемы:
-- CREATE SCHEMA IF NOT EXISTS silver.demo;
-- CREATE TABLE silver.demo.customer_evolution AS
-- SELECT custkey, name FROM silver.lakehouse.customer_nation ORDER BY custkey LIMIT 3;
-- ALTER TABLE silver.demo.customer_evolution ADD COLUMN source_system VARCHAR;
-- ALTER TABLE silver.demo.customer_evolution RENAME COLUMN source_system TO origin_system;
-- SELECT * FROM silver.demo.customer_evolution;

-- Восстановление:
-- CREATE TABLE silver.demo.recovery_orders AS
-- SELECT orderkey, custkey, orderdate, totalprice
-- FROM bronze.lakehouse.orders ORDER BY orderkey LIMIT 20;
-- SELECT snapshot_id FROM silver.demo."recovery_orders$snapshots"
-- ORDER BY committed_at DESC LIMIT 1;
-- Сохранить полученный snapshot_id перед удалением.
-- DELETE FROM silver.demo.recovery_orders;
-- SELECT count(*) FROM silver.demo.recovery_orders;
-- Подставить сохранённый номер вместо НОМЕР_СНАПШОТА:
-- SELECT * FROM silver.demo.recovery_orders FOR VERSION AS OF НОМЕР_СНАПШОТА;
-- ALTER TABLE silver.demo.recovery_orders EXECUTE rollback_to_snapshot(НОМЕР_СНАПШОТА);
