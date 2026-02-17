with tripdata as(
    select * 
    from {{source('raw_data','ext_fhv')}}
    where dispatching_base_num IS NOT NULL
),
renamed as (
  select
      -- identifiers

      cast(PUlocationID as integer) as pickup_locationid,
      cast(DOlocationID as integer) as dropoff_locationid,
      
      -- timestamp
      cast(pickup_datetime as timestamp) as pickup_datetime,
      cast(dropOff_datetime as timestamp) as dropoff_datetime,
      
      -- trip info
      SR_Flag AS sr_flag,
      cast(Affiliated_base_number as string) as Affiliated_base_number,
      cast(dispatching_base_num as numeric) as dispatching_base_num,

  from tripdata
)

select * from renamed