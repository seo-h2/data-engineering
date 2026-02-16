with vendors as (
    select distinct vendorid
    from {{ ref('int_trips_unioned') }}
)

select
    distinct vendorid,
    {{ get_vendor_data('vendorid') }} as vendor_name

from vendors