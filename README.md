# Практическая работа №1

Иван Константинов. Вариант 2, TPC-H Q10, масштаб sf1.

- [Отчёт](отчет.md)
- [Результаты](results.md)
- [Загрузка Bronze, Silver, Gold](lakehouse.sql)
- [Исходный Q10](query.sql)
- [Сравнение сжатия](benchmark.sql)

Запуск выполнен командами Docker из гайдов. На компьютере 8 ГБ памяти, поэтому настройки Trino в `catalog/settings` ограничивают память. Порт 5432 занят Postgres.app, для PostgreSQL практической используется 5433.

## 1. MinIO и PostgreSQL

Запустить Docker Desktop. Команды выполняются из папки проекта:

```sh
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

docker run -d --name lakehouse-minio \
  -p 127.0.0.1:9000:9000 -p 127.0.0.1:9001:9001 \
  -e MINIO_ROOT_USER=minioadmin -e MINIO_ROOT_PASSWORD=minioadmin \
  -v minio-data:/data \
  pgsty/silo:RELEASE.2026-09-03T13-18-01Z server /data --console-address :9001

docker run -d --name lakehouse-pg \
  -e POSTGRES_PASSWORD=postgres -p 127.0.0.1:5433:5432 \
  -v pg-data:/var/lib/postgresql/data postgres:17.6-alpine

docker exec lakehouse-pg pg_isready -U postgres
```

После ответа `accepting connections` перейти к Lakekeeper.

## 2. Lakekeeper

```sh
docker run --rm \
  -e 'LAKEKEEPER__PG_ENCRYPTION_KEY=This-is-NOT-Secure!' \
  -e 'LAKEKEEPER__PG_DATABASE_URL_READ=postgresql://postgres:postgres@host.docker.internal:5433/postgres' \
  -e 'LAKEKEEPER__PG_DATABASE_URL_WRITE=postgresql://postgres:postgres@host.docker.internal:5433/postgres' \
  quay.io/lakekeeper/catalog:v0.14.0 migrate

docker run -d --name lakekeeper \
  -e 'LAKEKEEPER__PG_ENCRYPTION_KEY=This-is-NOT-Secure!' \
  -e 'LAKEKEEPER__PG_DATABASE_URL_READ=postgresql://postgres:postgres@host.docker.internal:5433/postgres' \
  -e 'LAKEKEEPER__PG_DATABASE_URL_WRITE=postgresql://postgres:postgres@host.docker.internal:5433/postgres' \
  -p 127.0.0.1:8181:8181 quay.io/lakekeeper/catalog:v0.14.0 serve

curl http://localhost:8181/health
```

## 3. Бакеты и warehouse

По гайду медальона создаются три бакета и три warehouse. Это выполняется один раз:

```sh
docker exec lakehouse-minio mc alias set pr1 http://localhost:9000 minioadmin minioadmin
docker exec lakehouse-minio mc mb --ignore-existing pr1/bronze
docker exec lakehouse-minio mc mb --ignore-existing pr1/silver
docker exec lakehouse-minio mc mb --ignore-existing pr1/gold

curl -X POST http://localhost:8181/management/v1/bootstrap \
  -H 'Content-Type: application/json' -d '{"accept-terms-of-use":true}'

curl -X POST http://localhost:8181/management/v1/warehouse \
  -H 'Content-Type: application/json' -d @create-warehouse.json
```

Для Silver и Gold выполнить последний запрос с копией JSON, заменив оба значения `bronze` на `silver` или `gold`.
В `catalog/` лежат соответствующие файлы `bronze.properties`, `silver.properties`, `gold.properties` и `tpch.properties`.

## 4. Trino и SQL

```sh
docker run -d --name trino -p 127.0.0.1:8080:8080 \
  -v "$PWD/catalog:/etc/trino/catalog:ro" \
  -v "$PWD/catalog/settings/jvm.config:/etc/trino/jvm.config:ro" \
  -v "$PWD/catalog/settings/config.properties:/etc/trino/config.properties:ro" \
  trinodb/trino:476

curl http://localhost:8080/v1/info
```

После `"starting":false` выполнить SQL:

```sh
docker exec -i trino trino --file /dev/stdin < lakehouse.sql
docker exec -i trino trino --file /dev/stdin < query.sql
docker exec -i trino trino --file /dev/stdin < benchmark.sql
```

`lakehouse.sql` создаёт слои и выводит Gold. `query.sql` выполняет Q10 на TPC-H.
`benchmark.sql` создаёт копии Bronze с другим сжатием и выполняет Q10 дважды на каждой копии, как в гайде бенчмарка.

## 5. Spark SQL

Пример подключения из раздела 11.4 гайда бенчмарка. Скачать библиотеки Iceberg один раз:

```sh
mkdir -p spark/jars
curl -fL -o spark/jars/iceberg-spark-runtime-3.5_2.12-1.7.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.7.1/iceberg-spark-runtime-3.5_2.12-1.7.1.jar
curl -fL -o spark/jars/iceberg-aws-bundle-1.7.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.7.1/iceberg-aws-bundle-1.7.1.jar

docker stop trino
docker run --rm -e AWS_REGION=us-east-1 \
  -v "$PWD/spark:/opt/pr1:ro" \
  apache/spark:3.5.3 /opt/spark/bin/spark-sql \
  --master 'local[2]' --driver-memory 768m \
  --properties-file /opt/pr1/spark-defaults.conf \
  --jars /opt/pr1/jars/iceberg-spark-runtime-3.5_2.12-1.7.1.jar,/opt/pr1/jars/iceberg-aws-bundle-1.7.1.jar \
  -f /opt/pr1/read_bronze.sql
docker start trino
```

Spark выводит таблицы Bronze, количество строк и результат Q10.

## Интерфейсы и остановка

| Сервис | Адрес | Вход |
|---|---|---|
| MinIO | http://localhost:9001 | minioadmin / minioadmin |
| Lakekeeper | http://localhost:8181/ui/ | без пароля |
| Trino | http://localhost:8080 | пользователь pr1 |

Остановить: `docker stop trino lakekeeper lakehouse-pg lakehouse-minio`.
Продолжить: `docker start lakehouse-minio lakehouse-pg lakekeeper trino`.
Тома сохраняют данные после остановки контейнеров.

JDBC-драйвер нужен для DBeaver или другого внешнего клиента. Для команд Trino CLI выше отдельный драйвер не требуется.
