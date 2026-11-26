with shades as (

    select * from {{ ref('int_shades') }}

),

prices as (

    select * from {{ ref('int_prices') }}

),

products as (

    select
        product_key,
        brand_name,
        product_name,
        product_url,
        product_retailer,
        count(*)                                                     as shade_count,
        max(l_star)                                                  as lightest_l_star,
        min(l_star)                                                  as deepest_l_star,
        max(l_star) - min(l_star)                                    as l_star_range,
        count(distinct monk_tone)                                    as monk_tones_available,
        min(monk_tone)                                               as lightest_monk_tone,
        max(monk_tone)                                               as deepest_monk_tone,
        count(*) filter (where undertone_label <> 'unlabelled')      as shades_with_undertone_claim
    from shades
    group by product_key, brand_name, product_name, product_url, product_retailer

),

joined as (

    select
        products.*,
        prices.product_key is not null                               as has_price,
        prices.price_retailer,
        prices.price_usd,
        prices.size_oz,
        prices.size_type,
        prices.size_ml_or_g,
        prices.price_per_oz,
        prices.price_per_ml_or_g
    from products
    left join prices
        on products.product_key = prices.product_key

),

brand_bands as (

    select
        brand_name,
        percentile_cont(0.5) within group (order by price_usd)       as brand_median_price
    from joined
    where price_usd is not null
    group by brand_name

)

select
    joined.*,
    round(brand_bands.brand_median_price::numeric, 2)                as brand_median_price,
    case
        when brand_bands.brand_median_price is null then 'unknown'
        when brand_bands.brand_median_price < 15    then 'budget'
        when brand_bands.brand_median_price <= 35   then 'mid-range'
        else 'premium'
    end                                                              as price_band

from joined
left join brand_bands
    on joined.brand_name = brand_bands.brand_name