with source as (

    select * from {{ source('raw', 'sephora') }}

),

renamed as (

    select
        -- ids and text
        product_id,
        product_name,
        brand_id,
        brand_name,
        size,
        variation_type,
        variation_value,
        variation_desc,
        ingredients,
        highlights,
        primary_category,
        secondary_category,
        tertiary_category,

        -- prices
        price_usd::numeric            as price_usd,
        value_price_usd::numeric      as value_price_usd,
        sale_price_usd::numeric       as sale_price_usd,
        child_max_price::numeric      as child_max_price,
        child_min_price::numeric      as child_min_price,

        -- ratings and counts
        rating::numeric               as rating,
        reviews::integer              as reviews,
        loves_count::integer          as loves_count,
        child_count::integer          as child_count,

        -- yes/no flags (0/1 in the source)
        limited_edition::boolean      as limited_edition,
        new::boolean                  as new,
        online_only::boolean          as online_only,
        out_of_stock::boolean         as out_of_stock,
        sephora_exclusive::boolean    as sephora_exclusive

    from source

)

select * from renamed