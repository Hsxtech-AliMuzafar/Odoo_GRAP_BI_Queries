SELECT
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM') AS x_month_name,
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Mon') AS x_month_short,
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Day') AS x_weekday,
    EXTRACT(ISODOW FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'))::int AS x_weekday_number,
    CEIL(EXTRACT(DAY FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')) / 7.0)::int AS x_week_in_month_number,
    CONCAT('W', CEIL(EXTRACT(DAY FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')) / 7.0)::int) AS x_week_label,
    rc.id AS x_company_id,
    rc.name AS x_company_name,
    pc.id AS x_category_id,
    pc.name AS x_category_name,
    pp.id AS x_product_id,
    pt.name->>'en_US' AS x_product_name,
    SUM(pol.price_subtotal_incl) AS x_total_sales
FROM 
    pos_order po
JOIN 
    pos_order_line pol ON po.id = pol.order_id
JOIN 
    product_product pp ON pol.product_id = pp.id
JOIN 
    product_template pt ON pp.product_tmpl_id = pt.id
LEFT JOIN 
    product_category pc ON pt.categ_id = pc.id
JOIN 
    res_company rc ON po.company_id = rc.id
WHERE 
    po.state IN ('paid', 'done', 'invoiced')
    AND po.date_order IS NOT NULL
GROUP BY 
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM'),
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Mon'),
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Day'),
    EXTRACT(ISODOW FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')),
    CEIL(EXTRACT(DAY FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')) / 7.0),
    rc.id,
    rc.name,
    pc.id,
    pc.name,
    pp.id,
    pt.name->>'en_US'
HAVING 
    SUM(pol.qty) > 0
ORDER BY 
    x_month_name DESC,
    x_week_in_month_number ASC,
    x_weekday_number ASC,
    x_total_sales DESC;