-- Четыре варианта Bronze. На каждом Q10 выполняется два раза.


-- PARQUET, GZIP
CREATE SCHEMA IF NOT EXISTS bronze.bench_parquet_gzip;

SET SESSION bronze.compression_codec = 'GZIP';

CREATE TABLE bronze.bench_parquet_gzip.customer WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.customer;

CREATE TABLE bronze.bench_parquet_gzip.orders WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.orders;

CREATE TABLE bronze.bench_parquet_gzip.lineitem WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.lineitem;

CREATE TABLE bronze.bench_parquet_gzip.nation WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.nation;

-- Первый прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_parquet_gzip.customer c
JOIN bronze.bench_parquet_gzip.orders o ON c.custkey=o.custkey
JOIN bronze.bench_parquet_gzip.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_parquet_gzip.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- Повторный прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_parquet_gzip.customer c
JOIN bronze.bench_parquet_gzip.orders o ON c.custkey=o.custkey
JOIN bronze.bench_parquet_gzip.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_parquet_gzip.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- PARQUET, ZSTD
CREATE SCHEMA IF NOT EXISTS bronze.bench_parquet_zstd;

SET SESSION bronze.compression_codec = 'ZSTD';

CREATE TABLE bronze.bench_parquet_zstd.customer WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.customer;

CREATE TABLE bronze.bench_parquet_zstd.orders WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.orders;

CREATE TABLE bronze.bench_parquet_zstd.lineitem WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.lineitem;

CREATE TABLE bronze.bench_parquet_zstd.nation WITH (format='PARQUET')
AS SELECT * FROM tpch.sf1.nation;

-- Первый прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_parquet_zstd.customer c
JOIN bronze.bench_parquet_zstd.orders o ON c.custkey=o.custkey
JOIN bronze.bench_parquet_zstd.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_parquet_zstd.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- Повторный прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_parquet_zstd.customer c
JOIN bronze.bench_parquet_zstd.orders o ON c.custkey=o.custkey
JOIN bronze.bench_parquet_zstd.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_parquet_zstd.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- ORC, GZIP
CREATE SCHEMA IF NOT EXISTS bronze.bench_orc_gzip;

SET SESSION bronze.compression_codec = 'GZIP';

CREATE TABLE bronze.bench_orc_gzip.customer WITH (format='ORC')
AS SELECT * FROM tpch.sf1.customer;

CREATE TABLE bronze.bench_orc_gzip.orders WITH (format='ORC')
AS SELECT * FROM tpch.sf1.orders;

CREATE TABLE bronze.bench_orc_gzip.lineitem WITH (format='ORC')
AS SELECT * FROM tpch.sf1.lineitem;

CREATE TABLE bronze.bench_orc_gzip.nation WITH (format='ORC')
AS SELECT * FROM tpch.sf1.nation;

-- Первый прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_orc_gzip.customer c
JOIN bronze.bench_orc_gzip.orders o ON c.custkey=o.custkey
JOIN bronze.bench_orc_gzip.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_orc_gzip.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- Повторный прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_orc_gzip.customer c
JOIN bronze.bench_orc_gzip.orders o ON c.custkey=o.custkey
JOIN bronze.bench_orc_gzip.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_orc_gzip.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- ORC, ZSTD
CREATE SCHEMA IF NOT EXISTS bronze.bench_orc_zstd;

SET SESSION bronze.compression_codec = 'ZSTD';

CREATE TABLE bronze.bench_orc_zstd.customer WITH (format='ORC')
AS SELECT * FROM tpch.sf1.customer;

CREATE TABLE bronze.bench_orc_zstd.orders WITH (format='ORC')
AS SELECT * FROM tpch.sf1.orders;

CREATE TABLE bronze.bench_orc_zstd.lineitem WITH (format='ORC')
AS SELECT * FROM tpch.sf1.lineitem;

CREATE TABLE bronze.bench_orc_zstd.nation WITH (format='ORC')
AS SELECT * FROM tpch.sf1.nation;

-- Первый прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_orc_zstd.customer c
JOIN bronze.bench_orc_zstd.orders o ON c.custkey=o.custkey
JOIN bronze.bench_orc_zstd.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_orc_zstd.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- Повторный прогон

SELECT c.custkey, c.name,
       SUM(l.extendedprice*(1-l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM bronze.bench_orc_zstd.customer c
JOIN bronze.bench_orc_zstd.orders o ON c.custkey=o.custkey
JOIN bronze.bench_orc_zstd.lineitem l ON l.orderkey=o.orderkey
JOIN bronze.bench_orc_zstd.nation n ON c.nationkey=n.nationkey
WHERE o.orderdate >= DATE '1993-10-01'
  AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag='R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC, c.custkey
LIMIT 20;


-- Время выполнения в миллисекундах. CREATE TABLE показывает время записи.
SELECT query_id, query, date_diff('millisecond', started, "end") AS time_ms
FROM system.runtime.queries
WHERE state='FINISHED'
  AND (query LIKE 'CREATE TABLE bronze.bench_%'
       OR (query LIKE '%SUM(l.extendedprice*(1-l.discount)) AS revenue%'
           AND query LIKE '%FROM bronze.bench_%'))
ORDER BY created;

-- Размер файлов данных по таблицам. Для размера Bronze сложить четыре таблицы варианта.
SELECT 'bench_parquet_gzip' AS variant, 'customer' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_gzip."customer$files"
UNION ALL
SELECT 'bench_parquet_gzip' AS variant, 'orders' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_gzip."orders$files"
UNION ALL
SELECT 'bench_parquet_gzip' AS variant, 'lineitem' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_gzip."lineitem$files"
UNION ALL
SELECT 'bench_parquet_gzip' AS variant, 'nation' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_gzip."nation$files"
UNION ALL
SELECT 'bench_parquet_zstd' AS variant, 'customer' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_zstd."customer$files"
UNION ALL
SELECT 'bench_parquet_zstd' AS variant, 'orders' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_zstd."orders$files"
UNION ALL
SELECT 'bench_parquet_zstd' AS variant, 'lineitem' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_zstd."lineitem$files"
UNION ALL
SELECT 'bench_parquet_zstd' AS variant, 'nation' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_parquet_zstd."nation$files"
UNION ALL
SELECT 'bench_orc_gzip' AS variant, 'customer' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_gzip."customer$files"
UNION ALL
SELECT 'bench_orc_gzip' AS variant, 'orders' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_gzip."orders$files"
UNION ALL
SELECT 'bench_orc_gzip' AS variant, 'lineitem' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_gzip."lineitem$files"
UNION ALL
SELECT 'bench_orc_gzip' AS variant, 'nation' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_gzip."nation$files"
UNION ALL
SELECT 'bench_orc_zstd' AS variant, 'customer' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_zstd."customer$files"
UNION ALL
SELECT 'bench_orc_zstd' AS variant, 'orders' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_zstd."orders$files"
UNION ALL
SELECT 'bench_orc_zstd' AS variant, 'lineitem' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_zstd."lineitem$files"
UNION ALL
SELECT 'bench_orc_zstd' AS variant, 'nation' AS table_name, sum(file_size_in_bytes) AS bytes FROM bronze.bench_orc_zstd."nation$files";
