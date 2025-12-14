SELECT
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'YYYY-MM') AS x_month_name,
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'YYYY-MM-DD') AS x_order_date,
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'HH24:00') AS x_hour_slot,
    EXTRACT(HOUR FROM po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')::int AS x_hour_number,
    rc.id AS x_company_id,
    rc.name AS x_company_name,
    pp.id AS x_product_id,
    pt.name->>'en_US' AS x_product_name,
    pc.name AS x_category_name,
    SUM(pol.price_subtotal_incl) AS x_sale_value,
    COUNT(DISTINCT po.id) AS x_total_orders,
    CASE 
        WHEN COUNT(DISTINCT po.id) > 0 
        THEN ROUND(SUM(pol.price_subtotal_incl) / COUNT(DISTINCT po.id), 2)
        ELSE 0 
    END AS x_avg_order_value
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
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'YYYY-MM'),
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'YYYY-MM-DD'),
    TO_CHAR(po.date_order::timestamp AT TIME ZONE 'Asia/Karachi', 'HH24:00'),
    EXTRACT(HOUR FROM po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'),
    rc.id,
    rc.name,
    pp.id,
    pt.name->>'en_US',
    pc.name
HAVING 
    SUM(pol.qty) > 0
ORDER BY 
    x_month_name DESC,
    x_order_date DESC,
    x_hour_number ASC,
    x_sale_value DESC;