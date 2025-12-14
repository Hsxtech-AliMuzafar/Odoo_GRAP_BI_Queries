WITH base AS (
  SELECT
    sol.id AS line_id,
    so.id AS order_id,
    so.name AS order_reference,
    so.date_order,
    DATE(so.date_order) AS order_date_only,
    so.state AS order_state,

    -- Product
    pp.id AS product_id,
    pt.name AS product_name,
    pc.name AS category_name,

    -- SO Line
    sol.product_uom_qty AS quantity,
    sol.price_unit,
    sol.discount,
    sol.price_subtotal AS amount,

    -- MRP from product
    COALESCE(pt.mrp, pp.mrp, 0) AS product_mrp,

    -- Purchase price from SO line
    COALESCE(sol.purchase_price, 0) AS purchase_price,

    -- Margin
    (COALESCE(pt.mrp, pp.mrp, 0) - COALESCE(sol.purchase_price, 0)) AS margin_per_unit,

    -- Customer
    so.partner_id,
    rp.name AS customer_name,

    -- Salesperson
    so.user_id,
    rp_user.name AS salesperson_name,
    so.team_id,
    crm_team.name AS team_name
  FROM sale_order_line sol
    JOIN sale_order so ON sol.order_id = so.id
    LEFT JOIN product_product pp ON sol.product_id = pp.id
    LEFT JOIN product_template pt ON pp.product_tmpl_id = pt.id
    LEFT JOIN product_category pc ON pt.categ_id = pc.id
    LEFT JOIN res_partner rp ON so.partner_id = rp.id
    LEFT JOIN res_users ru ON so.user_id = ru.id
    LEFT JOIN res_partner rp_user ON ru.partner_id = rp_user.id
    LEFT JOIN crm_team ON so.team_id = crm_team.id
  WHERE sol.product_id IS NOT NULL
    AND so.state IN ('sale', 'done')
),

order_cnt AS (
  SELECT
    partner_id,
    COUNT(*) AS total_orders
  FROM sale_order
  WHERE state IN ('sale', 'done')
  GROUP BY partner_id
)

SELECT
  -- Order
  b.order_id AS x_order_id,
  b.order_reference AS x_order_reference,
  b.date_order AS x_order_date,
  b.order_date_only AS x_date,
  b.order_state AS x_order_state,

  -- Order Count (Correct)
  COALESCE(oc.total_orders, 0) AS x_order_count,

  -- Counters
  CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.order_id ORDER BY b.line_id) = 1 THEN 1 ELSE 0 END AS x_order_reference_count,

  -- Product
  b.product_id AS x_product_id,
  b.product_name AS x_product_name,
  b.category_name AS x_category_name,

  -- Customer
  b.partner_id AS x_customer_id,
  b.customer_name AS x_customer_name,

  -- Salesperson
  b.user_id AS x_salesperson_id,
  b.salesperson_name AS x_salesperson_name,
  b.team_id AS x_team_id,
  b.team_name AS x_team_name,

  -- Qty & Sales
  b.quantity AS x_quantity,
  b.price_unit AS x_price_unit,
  b.discount AS x_trade_discount_percent,
  b.amount AS x_amount,

  -- Cost/MRP & Margins
  b.product_mrp AS x_mrp,
  b.purchase_price AS x_purchase_price,
  b.margin_per_unit AS x_margin_per_unit,
  (b.margin_per_unit * b.quantity) AS x_total_margin,

  CASE WHEN b.purchase_price > 0 THEN
      ROUND((b.margin_per_unit / b.purchase_price)::numeric, 4)
  ELSE 0 END AS x_margin_percentage,

  CASE
    WHEN b.margin_per_unit >= 500 THEN 'High'
    WHEN b.margin_per_unit >= 100 THEN 'Medium'
    ELSE 'Low'
  END AS x_margin_category

FROM base b
LEFT JOIN order_cnt oc ON b.partner_id = oc.partner_id

WHERE 1=1 -- b.quantity > 0
  -- AND b.product_mrp > 0
  -- AND b.purchase_price > 0

ORDER BY b.date_order DESC, x_total_margin DESC;
