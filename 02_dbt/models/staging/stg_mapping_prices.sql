with source as (

    select * from {{ source('raw', 'mapping_prices') }}

),

renamed as (

    select
        url                       as product_url,
        shop_key,
        source                    as price_retailer,
        method                    as match_method,
        successor,
        retailer                  as product_retailer,
        same_retailer::boolean    as same_retailer

    from source

)

select * from renamed