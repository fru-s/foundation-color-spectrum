with source as (

    select * from {{ source('raw', 'ulta') }}

),

renamed as (

    select
        -- ids and text
        product_link_id,
        product_link                                  as product_url,
        category,
        item_id,
        product_name,
        brand                                         as brand_name,
        description                                   as product_description,
        pros,
        cons,
        best_uses,
        describe_yourself,
        faceoff_negative,
        faceoff_positive,

        -- price and shades
        price::numeric                                as price_usd,
        num_shades::integer                           as num_shades,

        -- ratings
        rating::numeric                               as rating,
        average_rating::numeric                       as average_rating,
        recommended_ratio::numeric                    as recommended_ratio,

        -- review counts
        num_reviews::integer                          as num_reviews,
        rating_count::integer                         as rating_count,
        review_count::integer                         as review_count,
        native_review_count::integer                  as native_review_count,
        native_sampling_review_count::integer         as native_sampling_review_count,
        native_community_content_review_count::integer as native_community_content_review_count,
        syndicated_review_count::integer              as syndicated_review_count,

        -- star breakdowns
        review_star_1::integer                        as review_star_1,
        review_star_2::integer                        as review_star_2,
        review_star_3::integer                        as review_star_3,
        review_star_4::integer                        as review_star_4,
        review_star_5::integer                        as review_star_5,
        rating_star_1::integer                        as rating_star_1,
        rating_star_2::integer                        as rating_star_2,
        rating_star_3::integer                        as rating_star_3,
        rating_star_4::integer                        as rating_star_4,
        rating_star_5::integer                        as rating_star_5

    from source

)

select * from renamed