# MODULE 1 HW.
## Question 1. Understanding Docker images
Run docker with the python:3.13 image. Use an entrypoint bash to interact with the container.

What's the version of pip in the image?

```
# -it 터미널 세션 유지 / --rm 종료 시 컨테이너 자동 삭제
docker run -it --rm --entrypoint bash python:3.13
pip --version
```



## Question 2.Understanding Docker networking and docker-compose
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



## Question 3.Counting short trips
For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a trip_distance of less than or equal to 1 mile?

```sql
select count(1)
from public."green_tripdata_2025-11"
where CAST(lpep_pickup_datetime AS date) between '2025-11-01' and '2025-11-30'
	AND trip_distance <= 1;
```




## Question 4.  Longest trip for each day
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




## Question 5.Biggest pickup zone
Which was the pickup zone with the largest total_amount (sum of all trips) on November 18th, 2025?

```sql
select "Zone", sum(total_amount) AS sum_total_amount
from public."green_tripdata_2025-11" as pu left join public.zones as zo on  pu."PULocationID" = zo."LocationID"
where CAST(lpep_pickup_datetime AS date) = '2025-11-18'
group by "Zone"
order by sum_total_amount desc
limit 1;

```




## Question 6. Largest tip
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

