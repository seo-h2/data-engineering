# Homework
## Module 1. Docker 
### Question 1. Understanding Docker images
Run docker with the python:3.13 image. Use an entrypoint bash to interact with the container.

What's the version of pip in the image?

```
# -it 터미널 세션 유지 / --rm 종료 시 컨테이너 자동 삭제
docker run -it --rm --entrypoint bash python:3.13
pip --version
```



### Question 2.Understanding Docker networking and docker-compose
Given the following docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the postgres database?

```
services:
  db: # hostname
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432' # localhost port : container port
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```



### Question 3.Counting short trips
For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a trip_distance of less than or equal to 1 mile?

```sql
select count(1)
from public."green_tripdata_2025-11"
where CAST(lpep_pickup_datetime AS date) between '2025-11-01' and '2025-11-30'
	AND trip_distance <= 1;
```




### Question 4.  Longest trip for each day
Which was the pick up day with the longest trip distance? Only consider trips with trip_distance less than 100 miles (to exclude data errors).

```sql
select lpep_pickup_datetime, trip_distance
from public."green_tripdata_2025-11"
where trip_distance = (
	select max(trip_distance) as max_trip_distance
	from public."green_tripdata_2025-11"
	where trip_distance < 100
);
```




### Question 5.Biggest pickup zone
Which was the pickup zone with the largest total_amount (sum of all trips) on November 18th, 2025?

```sql
select "Zone", sum(total_amount) AS sum_total_amount
from public."green_tripdata_2025-11" as pu left join public.zones as zo on  pu."PULocationID" = zo."LocationID"
where CAST(lpep_pickup_datetime AS date) = '2025-11-18'
group by "Zone"
order by sum_total_amount desc
limit 1;

```




### Question 6. Largest tip
For the passengers picked up in the zone named "East Harlem North" in November 2025, which was the drop off zone that had the largest tip?

```sql
select zd."Zone" as do_zone, max(tip_amount) as max_tip_amount
from public."green_tripdata_2025-11" as pu 
	left join public.zones as zp on  pu."PULocationID" = zp."LocationID"
	left join public.zones as zd on  pu."DOLocationID" = zd."LocationID"
where zp."Zone" = 'East Harlem North' AND CAST(lpep_pickup_datetime AS date) between '2025-11-01' and '2025-11-30'
group by zd."Zone"
order by max_tip_amount desc
limit 1;
```


-----
## Module 2. Workflow orchestration (Kestra)

### Question 2. What is the rendered value of the variable file when the inputs taxi is set to green, year is set to 2020, and month is set to 04 during execution?

> Through 'render', I can access total value string.

### Question 3.
How many rows are there for the Yellow Taxi data for all CSV files in the year 2020? 

> In Biquery, I executed code below.
```sql
SELECT count(1) FROM `my-project123-486104.zoomcamp.yellow_tripdata` 
WHERE CONTAINS_SUBSTR(filename, '2020')
```

### Question 4. How many rows are there for the Green Taxi data for all CSV files in the year 2020?

> In Biquery, I executed code below.
```sql
SELECT count(1) FROM `my-project123-486104.zoomcamp.green_tripdata`
WHERE CONTAINS_SUBSTR(filename, '2020')
```

### Question 5. How many rows are there for the Yellow Taxi data for the March 2021 CSV file?

> In Biquery, I executed code below.
```sql
SELECT count(1) FROM `my-project123-486104.zoomcamp.yellow_tripdata` 
WHERE CONTAINS_SUBSTR(filename, '2021-03')
```



-----
## Module 3.DATA WAREHOUSING
Data Loading (External Table & Table)
```sql
CREATE EXTERNAL TABLE `my-project123-486104.zoomcamp.ext`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dezoomcamp_hw3_2026_sh/*.parquet']
);

CREATE OR REPLACE TABLE `my-project123-486104.zoomcamp.int_table` AS
SELECT *
FROM `my-project123-486104.zoomcamp.ext`;
```

### Question 1. What is count of records for the 2024 Yellow Taxi Data? 
```sql
select count(1)
from `my-project123-486104.zoomcamp.ext`
```

### Question 2. What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?
```sql
select distinct PULocationID
from `my-project123-486104.zoomcamp.ext`;

select distinct PULocationID
from `my-project123-486104.zoomcamp.int_table`;
```

### Question 3. Why are the estimated number of Bytes different? 
```sql
select PULocationID
from `my-project123-486104.zoomcamp.int_table`;

select PULocationID,DOLocationID
from `my-project123-486104.zoomcamp.int_table`;
```

### Question 4. How many records have a fare_amount of 0?
```sql
select count(1)
from `my-project123-486104.zoomcamp.ext`
where fare_amount = 0;
```

### Question 6. Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive). Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

Create partitioned & clustered table 
```sql
CREATE OR REPLACE TABLE `my-project123-486104.zoomcamp.int_part_table`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT *
FROM `my-project123-486104.zoomcamp.ext`;
```

Check the estimated bytes for each table.
```sql
select distinct VendorID
from `my-project123-486104.zoomcamp.int_table`
where tpep_dropoff_datetime between '2024-03-01' and '2024-03-15';

select distinct VendorID
from `my-project123-486104.zoomcamp.int_part_table`
where tpep_dropoff_datetime between '2024-03-01' and '2024-03-15'
```
