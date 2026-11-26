with shades as (

    select * from {{ ref('stg_shades') }}

),

keyed as (

    select
        *,
        md5(
            coalesce(product_url, '')  || '|' ||
            coalesce(hex_original, '') || '|' ||
            coalesce(shade_name, '')   || '|' ||
            coalesce(shade_number, '')
        )                               as shade_key,
        md5(product_url)                as product_key
    from shades

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by shade_key
            order by shade_description
        )                               as copy_number
    from keyed

),

filtered as (

    select *
    from deduplicated
    where copy_number = 1
      and product_name not ilike '%travel size%'
      and coalesce(shade_description, '') !~* '(mixer|for mixing)'
      and product_name !~* 'mixing pigment'

),

lookup as (

    select * from {{ source('raw', 'undertone_lookup') }}

),

label_map as (

    select * from {{ ref('undertone_label_map') }}

)

select
    filtered.shade_key,
    filtered.product_key,
    filtered.brand_name,
    filtered.product_name,
    filtered.product_url,
    case
        when filtered.product_url ilike '%sephora%' then 'sephora'
        when filtered.product_url ilike '%ulta%'    then 'ulta'
    end                                             as product_retailer,
    filtered.shade_name,
    filtered.shade_number,
    filtered.shade_description,
    filtered.hex_original,
    filtered.hex_final,
    filtered.l_star,
    filtered.a_star,
    filtered.b_star,
    filtered.chroma,
    filtered.monk_tone,
    degrees(atan2(filtered.b_star, filtered.a_star)) as hue_angle,
    lookup.undertone_brand_term,
    lookup.undertone_source,
    coalesce(label_map.undertone_label, 'unlabelled')    as undertone_label,
    coalesce(filtered.shade_description, '') ~* '\m(olive|green|goldenolive)\M' as olive_flag

from filtered
left join lookup
    on filtered.shade_key = lookup.shade_key
left join label_map
    on lookup.undertone_brand_term = label_map.undertone_brand_term