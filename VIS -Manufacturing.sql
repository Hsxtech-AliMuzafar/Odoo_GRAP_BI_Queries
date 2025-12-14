WITH bom_data AS (
    SELECT
        b.id AS bom_id,
        b.product_tmpl_id,
        SUM(bl.product_qty * COALESCE((cp.standard_price ->> '1')::numeric, 0)) AS x_bom_cost
    FROM mrp_bom b
    JOIN mrp_bom_line bl ON bl.bom_id = b.id
    JOIN product_product cp ON bl.product_id = cp.id
    GROUP BY b.id, b.product_tmpl_id
),
production_data AS (
    SELECT
        mp.product_id,
        MIN(mp.create_date) AS x_mfg_start_date,
        MAX(mp.date_finished) AS x_mfg_end_date,
        COUNT(mp.id) AS x_total_orders,
        SUM(mp.product_qty) AS x_total_qty,
        SUM(mp.product_qty * COALESCE((pp.standard_price ->> '1')::numeric, 0)) AS x_total_cost
    FROM mrp_production mp
    JOIN product_product pp ON mp.product_id = pp.id
    WHERE mp.state IN ('confirmed','done')
    GROUP BY mp.product_id
)
SELECT
    pd.product_id AS x_product_id,
    pd.x_mfg_start_date,
    pd.x_mfg_end_date,
    pd.x_total_orders,
    pd.x_total_qty,
    pd.x_total_cost,
    bd.x_bom_cost,
    CASE
        WHEN pd.x_total_qty > 0 THEN ROUND((pd.x_total_cost - COALESCE(bd.x_bom_cost,0)) / pd.x_total_qty, 2)
        ELSE 0
    END AS x_margin_per_unit,
    CASE
        WHEN pd.x_total_qty > 0 THEN ROUND(((pd.x_total_cost - COALESCE(bd.x_bom_cost,0)) / pd.x_total_cost) * 100, 2)
        ELSE 0
    END AS x_margin_percentage
FROM production_data pd
LEFT JOIN (
    SELECT product_tmpl_id, SUM(x_bom_cost) AS x_bom_cost
    FROM bom_data
    GROUP BY product_tmpl_id
) bd ON pd.product_id = bd.product_tmpl_id
ORDER BY pd.x_total_orders DESC