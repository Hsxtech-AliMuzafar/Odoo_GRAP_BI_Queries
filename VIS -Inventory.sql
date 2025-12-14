WITH current_stock AS (
    SELECT 
        product_id, 
        SUM(quantity) as qty_on_hand 
    FROM stock_quant sq
    JOIN stock_location sl ON sq.location_id = sl.id
    WHERE sl.usage = 'internal'
    GROUP BY product_id
),
stock_moves AS (
    SELECT
        sm.id AS line_id,
        sm.product_id,
        pt.name AS product_name,
        pc.id AS category_id,
        pc.name AS category_name,
        sm.date AS move_date,
        sm.product_uom_qty,
        
        -- Location Usages
        sl_src.usage AS src_usage,
        sl_dest.usage AS dest_usage
        
    FROM stock_move sm
    JOIN product_product pp ON sm.product_id = pp.id
    JOIN product_template pt ON pp.product_tmpl_id = pt.id
    LEFT JOIN product_category pc ON pt.categ_id = pc.id
    JOIN stock_location sl_src ON sm.location_id = sl_src.id
    JOIN stock_location sl_dest ON sm.location_dest_id = sl_dest.id
    WHERE sm.state = 'done'
)
SELECT
    sm.line_id AS x_line_id,
    sm.product_id AS x_product_id,
    sm.product_name AS x_product_name,
    sm.category_id AS x_category_id,
    sm.category_name AS x_category_name,
    sm.move_date AS x_move_date,
    
    -- Incoming (Any -> Internal)
    CASE WHEN sm.dest_usage = 'internal' AND sm.src_usage != 'internal' THEN sm.product_uom_qty ELSE 0 END AS x_incoming_qty,
    
    -- Outgoing (Internal -> Any)
    CASE WHEN sm.src_usage = 'internal' AND sm.dest_usage != 'internal' THEN sm.product_uom_qty ELSE 0 END AS x_outgoing_qty,
    
    -- Produced (Production -> Internal) - This is a subset of Incoming
    CASE WHEN sm.src_usage = 'production' AND sm.dest_usage = 'internal' THEN sm.product_uom_qty ELSE 0 END AS x_produced_qty,

    -- Net Change
    (CASE WHEN sm.dest_usage = 'internal' AND sm.src_usage != 'internal' THEN sm.product_uom_qty ELSE 0 END - 
     CASE WHEN sm.src_usage = 'internal' AND sm.dest_usage != 'internal' THEN sm.product_uom_qty ELSE 0 END) AS x_stock_change,

    -- Current On Hand (Static per product)
    COALESCE(cs.qty_on_hand, 0) AS x_current_on_hand

FROM stock_moves sm
LEFT JOIN current_stock cs ON sm.product_id = cs.product_id
ORDER BY sm.move_date DESC, sm.product_name