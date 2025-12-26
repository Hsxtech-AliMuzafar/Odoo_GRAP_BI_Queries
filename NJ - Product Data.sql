SELECT
    pt.id AS x_product_id,
    pt.name->>'en_US' AS x_product_name,
    pt.default_code AS x_internal_reference,
    pt.categ_id AS x_category_id,
    pc.name AS x_category_name,
    pt.jewelry_type AS x_jewelry_type,
    qq.name AS x_quality_name,
    pt.net_weight_gm AS x_net_weight_gm,
    pt.weight_tola AS x_weight_tola,
    pt.polish_gram AS x_polish_gram,
    pt.pieces AS x_pieces,
    pt.list_price AS x_sales_price,
    (SELECT (pp.standard_price->>'1')::numeric FROM product_product pp WHERE pp.product_tmpl_id = pt.id LIMIT 1) AS x_cost,
    
    -- Creation Info
    TO_CHAR(pt.create_date, 'YYYY-MM-DD HH12:MI:SS AM') AS x_created_on,
    TO_CHAR(pt.create_date, 'YYYY-MM-DD') AS x_creation_date,
    TO_CHAR(pt.create_date, 'YYYY-MM') AS x_month_year,
    TO_CHAR(pt.create_date, 'Day') AS x_day_of_week,
    rp.name AS x_created_by

FROM product_template pt
LEFT JOIN product_category pc ON pt.categ_id = pc.id
LEFT JOIN quality_quality qq ON pt.quality_id = qq.id
LEFT JOIN res_users ru ON pt.create_uid = ru.id
LEFT JOIN res_partner rp ON ru.partner_id = rp.id

WHERE 
    pt.is_jewelry_product = true

ORDER BY
    pt.create_date DESC;
