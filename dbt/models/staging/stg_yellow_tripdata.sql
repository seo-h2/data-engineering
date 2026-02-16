-- 목적 : 컬럼명 변경, 타입 캐스팅 등의 전처리 수행
with tripdata as (
  select *
  from {{ source('raw_data','ext_yellow_tripdata') }}
  where vendorid is not null 
),

renamed as (
  select
      -- identifiers
      cast(vendorid as integer) as vendorid,
      cast(ratecodeid as integer) as ratecodeid,
      cast(pulocationid as integer) as pickup_locationid,
      cast(dolocationid as integer) as dropoff_locationid,
      
      -- timestamp
      cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
      cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
      
      -- trip info
      store_and_fwd_flag,
      cast(passenger_count as integer) as passenger_count,
      cast(trip_distance as numeric) as trip_distance,
      1 as trip_type,
      
      -- payment info
      cast(fare_amount as numeric) as fare_amount,
      cast(extra as numeric) as extra,
      cast(mta_tax as numeric) as mta_tax,
      cast(tip_amount as numeric) as tip_amount,
      cast(tolls_amount as numeric) as tolls_amount,
      cast(improvement_surcharge as numeric) as improvement_surcharge,
      cast(total_amount as numeric) as total_amount,
      0 as ehail_fee,
      cast(payment_type as integer) as payment_type
  from tripdata
)

select * from renamed