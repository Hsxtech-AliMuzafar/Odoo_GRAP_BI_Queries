WITH aml_data AS (
    SELECT
        aml.id AS line_id,
        aml.partner_id,
        rp.name AS partner_name,
        rp.customer_rank,
        rp.supplier_rank,
        aml.move_id,
        am.name AS move_name,
        am.move_type,
        am.invoice_date,
        am.amount_total_signed,
        aml.date AS entry_date,
        COALESCE(aml.date_maturity, aml.date) AS due_date,
        aml.debit,
        aml.credit,
        aml.amount_currency,
        aml.amount_residual_currency,
        COALESCE(aml.amount_residual, 0) AS balance,
        (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) AS days_until_due,
        
        -- Buckets based on Days Until Due (Positive = Future, Negative = Past)
        CASE
            WHEN (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) <= 0 THEN COALESCE(aml.amount_residual, 0)
            ELSE 0
        END AS past_due_or_today,
        
        CASE
            WHEN (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) BETWEEN 1 AND 30 THEN COALESCE(aml.amount_residual, 0)
            ELSE 0
        END AS due_in_1_to_30_days,
        
        CASE
            WHEN (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) BETWEEN 31 AND 60 THEN COALESCE(aml.amount_residual, 0)
            ELSE 0
        END AS due_in_31_to_60_days,
        
        CASE
            WHEN (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) BETWEEN 61 AND 90 THEN COALESCE(aml.amount_residual, 0)
            ELSE 0
        END AS due_in_61_to_90_days,
        
        CASE
            WHEN (COALESCE(aml.date_maturity, aml.date) - CURRENT_DATE) > 90 THEN COALESCE(aml.amount_residual, 0)
            ELSE 0
        END AS due_after_90_days

    FROM account_move_line aml
    JOIN account_move am ON aml.move_id = am.id
    JOIN res_partner rp ON aml.partner_id = rp.id
    WHERE am.state = 'posted'
      AND COALESCE(aml.amount_residual, 0) != 0
)
SELECT
    line_id AS x_line_id,
    partner_id AS x_partner_id,
    partner_name AS x_partner_name,
    customer_rank AS x_is_customer,
    supplier_rank AS x_is_supplier,
    move_id AS x_move_id,
    move_name AS x_move_name,
    move_type AS x_move_type,
    invoice_date AS x_invoice_date,
    amount_total_signed AS x_move_total_signed,
    entry_date AS x_entry_date,
    due_date AS x_due_date,
    days_until_due AS x_days_until_due,
    amount_currency AS x_amount_currency,
    amount_residual_currency AS x_amount_residual_currency,
    balance AS x_balance,
    past_due_or_today AS x_past_due_or_today,
    due_in_1_to_30_days AS x_due_in_1_to_30_days,
    due_in_31_to_60_days AS x_due_in_31_to_60_days,
    due_in_61_to_90_days AS x_due_in_61_to_90_days,
    due_after_90_days AS x_due_after_90_days
FROM aml_data
ORDER BY partner_name, entry_date