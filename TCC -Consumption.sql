WITH pos_stock_moves AS (
    SELECT
        sp.pos_order_id,
        sm.product_id,
        SUM(sm.product_uom_qty) AS qty_done
    FROM
        stock_picking sp
    JOIN
        stock_move sm ON sp.id = sm.picking_id
    WHERE
        sp.pos_order_id IS NOT NULL
        AND sm.state = 'done'
    GROUP BY
        sp.pos_order_id,
        sm.product_id
)
SELECT
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM') AS x_month_name,
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM-DD') AS x_order_date,
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Mon') AS x_month_short,
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Day') AS x_weekday,
    EXTRACT(ISODOW FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'))::int AS x_weekday_number,
    rc.id AS x_company_id,
    rc.name AS x_company_name,
    po.id AS x_order_id,
    po.pos_reference AS x_order_reference,
    COUNT(DISTINCT pol.product_id) AS x_products_in_order,
    pc.id AS x_category_id,
    pc.name AS x_category_name,
    pp.id AS x_product_id,
    pt.name->>'en_US' AS x_product_name,
    uom.id AS x_uom_id,
    uom.name->>'en_US' AS x_uom_name,
    SUM(pol.qty) AS x_product_quantity,
    COALESCE(MAX(psm.qty_done), 0) AS x_stock_quantity,
    SUM(pol.price_subtotal_incl) AS x_product_sales
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
LEFT JOIN
    uom_uom uom ON pt.uom_id = uom.id
JOIN
    res_company rc ON po.company_id = rc.id
LEFT JOIN
    pos_stock_moves psm ON po.id = psm.pos_order_id AND pp.id = psm.product_id
WHERE
    po.state IN ('paid', 'done', 'invoiced')
    AND po.date_order IS NOT NULL
GROUP BY
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM'),
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM-DD'),
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Mon'),
    TO_CHAR((po.date_order::timestamp AT TIME ZONE 'Asia/Karachi'), 'Day'),
    EXTRACT(ISODOW FROM (po.date_order::timestamp AT TIME ZONE 'Asia/Karachi')),
    rc.id,
    rc.name,
    po.id,
    po.pos_reference,
    pc.id,
    pc.name,
    pp.id,
    pt.name->>'en_US',
    uom.id,
    uom.name->>'en_US'
HAVING
    SUM(pol.qty) > 0
ORDER BY
    x_month_name DESC,
    x_order_date DESC,
    x_order_id DESC,
    x_product_sales DESC;