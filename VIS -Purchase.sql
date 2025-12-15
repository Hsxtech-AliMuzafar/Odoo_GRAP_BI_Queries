WITH po_lines AS (
    SELECT
        pol.id AS line_id,
        po.id AS order_id,
        po.name AS order_reference,
        po.date_order,
        po.partner_id AS vendor_id,
        rp.name AS vendor_name,
        pol.product_id,
        pt.name AS product_name,
        pc.name AS category_name,
        pol.product_qty AS qty_ordered,
        pol.price_unit,
        pol.price_subtotal AS amount_total,
        po.currency_id,
        po.state
    FROM purchase_order_line pol
    JOIN purchase_order po ON pol.order_id = po.id
    JOIN product_product pp ON pol.product_id = pp.id
    JOIN product_template pt ON pp.product_tmpl_id = pt.id
    LEFT JOIN product_category pc ON pt.categ_id = pc.id
    JOIN res_partner rp ON po.partner_id = rp.id
    WHERE po.state IN ('purchase', 'done')
),
moves_agg AS (
    SELECT
        sm.purchase_line_id,
        SUM(sm.product_uom_qty) AS qty_received,
        MAX(sm.date) AS last_receipt_date
    FROM stock_move sm
    WHERE sm.purchase_line_id IS NOT NULL
      AND sm.state = 'done'
    GROUP BY sm.purchase_line_id
)
SELECT
    pl.line_id AS x_line_id,
    pl.order_id AS x_order_id,
    pl.order_reference AS x_order_reference,
    pl.date_order AS x_date_order,
    
    -- Vendor Info
    pl.vendor_id AS x_vendor_id,
    pl.vendor_name AS x_vendor_name,
    
    -- Product Info
    pl.product_id AS x_product_id,
    pl.product_name AS x_product_name,
    pl.category_name AS x_category_name,
    
    -- Metrics
    pl.qty_ordered AS x_qty_ordered,
    pl.price_unit AS x_price_unit,
    pl.amount_total AS x_amount_total,
    
    -- Stock Info
    COALESCE(ma.qty_received, 0) AS x_qty_received,
    ma.last_receipt_date AS x_last_receipt_date,
    
    -- Comparisons
    pl.product_name || ' - ' || pl.vendor_name AS x_product_vendor_key,

    -- Calculated Status
    CASE 
        WHEN COALESCE(ma.qty_received, 0) >= pl.qty_ordered THEN 'Fully Received'
        WHEN COALESCE(ma.qty_received, 0) > 0 THEN 'Partially Received'
        ELSE 'Pending'
    END AS x_delivery_status

FROM po_lines pl
LEFT JOIN moves_agg ma ON pl.line_id = ma.purchase_line_id
ORDER BY pl.date_order DESC;
