select
    shade_key,
    product_key,
    shade_name,
    shade_number,
    hex_final,
    l_star,
    a_star,
    b_star,
    chroma,
    hue_angle,
    monk_tone,
    undertone_label,
    undertone_brand_term,
    undertone_source,
    olive_flag
from {{ ref('int_shades') }}