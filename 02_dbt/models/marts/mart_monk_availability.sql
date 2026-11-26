with shades as (

    select * from {{ ref('int_shades') }}

),

brands as (

    select distinct brand_name from shades

),

tones as (

    select generate_series(1, 10) as monk_tone

),

counts as (

    select
        brand_name,
        monk_tone,
        count(*)                        as shade_count,
        count(distinct product_key)     as product_count
    from shades
    group by brand_name, monk_tone

)

select
    brands.brand_name,
    tones.monk_tone,
    coalesce(counts.shade_count, 0)     as shade_count,
    coalesce(counts.product_count, 0)   as product_count

from brands
cross join tones
left join counts
    on  counts.brand_name = brands.brand_name
    and counts.monk_tone  = tones.monk_tone