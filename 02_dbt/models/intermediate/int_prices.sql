with ulta_ranked as (

    select
        product_url                       as shop_key,
        price_usd,
        product_description,
        row_number() over (
            partition by product_url
            order by product_link_id
        )                                 as copy_number
    from {{ ref('stg_ulta') }}

),

ulta_prices as (

    select
        shop_key,
        'ulta'::text                      as price_retailer,
        price_usd,
        substring(product_description from '(?i)size:\s*([0-9]*\.?[0-9]+)\s*oz')::numeric as size_oz,
        'unknown'::text                   as size_type,
         round(substring(product_description from '(?i)size:\s*([0-9]*\.?[0-9]+)\s*oz')::numeric * 29.57, 1) as size_ml_or_g
    from ulta_ranked
    where copy_number = 1

),

sephora_prices as (

    select
        product_id                        as shop_key,
        'sephora'::text                   as price_retailer,
        price_usd,
        substring(size from '(?i)([0-9]*\.?[0-9]+)\s*(?:fl\.?\s*)?oz')::numeric as size_oz,
        case
            when size ~* '[0-9]\s*ml' then 'volume'
            when size ~* '[0-9]\s*g\M' then 'weight'
            else 'unknown'
        end                               as size_type,
        coalesce(
            substring(size from '(?i)([0-9]*\.?[0-9]+)\s*(?:ml|g)\M')::numeric,
            round(substring(size from '(?i)([0-9]*\.?[0-9]+)\s*(?:fl\.?\s*)?oz')::numeric * 29.57, 1)
        )                                 as size_ml_or_g
    from {{ ref('stg_sephora') }}
    where primary_category is distinct from 'Mini Size'

),

all_prices as (

    select * from ulta_prices
    union all
    select * from sephora_prices

),

mapping as (

    select * from {{ ref('stg_mapping_prices') }}

)

select
    md5(mapping.product_url)              as product_key,
    mapping.product_url,
    mapping.price_retailer,
    mapping.match_method,
    mapping.successor,
    all_prices.price_usd,
    all_prices.size_oz,
    all_prices.size_type,
    round(all_prices.price_usd / nullif(all_prices.size_oz, 0), 2) as price_per_oz,
    all_prices.size_ml_or_g,
    round(all_prices.price_usd / nullif(all_prices.size_ml_or_g, 0), 2) as price_per_ml_or_g

from mapping
inner join all_prices
    on  mapping.shop_key       = all_prices.shop_key
    and mapping.price_retailer = all_prices.price_retailer