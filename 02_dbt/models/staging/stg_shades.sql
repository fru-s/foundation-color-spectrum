with source as (

    select * from {{ source('raw', 'shades') }}

),

renamed as (

    select
        -- text
        brand                 as brand_name,
        product               as product_name,
        url                   as product_url,
        description           as shade_description,
        "imgSrc"              as image_url,
        "imgAlt"              as image_alt_text,
        name                  as shade_name,
        specific              as shade_number,
        colorspace,
        hex                   as hex_original,
        hex_final,

        -- numbers
        hue::numeric          as hue,
        sat::numeric          as sat,
        lightness::numeric    as lightness,
        "L_star"::numeric     as l_star,
        a_star::numeric       as a_star,
        b_star::numeric       as b_star,
        chroma::numeric       as chroma,
        monk_tone::integer    as monk_tone

    from source

)

select * from renamed