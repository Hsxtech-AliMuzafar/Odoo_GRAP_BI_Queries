SELECT
    TO_CHAR((am.date::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM-DD') AS x_date,
    aa.id AS x_account_id,
    aa.name->>'en_US' AS x_account_name,
    rp.name AS x_partner_name,
    am.name AS x_move_reference,
    CASE
        WHEN (aa.name->>'en_US') ILIKE '%Supplementary Income%' THEN 'Supplementary Income'
        WHEN (aa.name->>'en_US') ILIKE '%Franchise Income%' THEN 'Franchise Income'
        WHEN (aa.name->>'en_US') ILIKE '%Other Income%' THEN 'Other Income'
        WHEN (aa.name->>'en_US') ILIKE '%Cost%' THEN 'Cost'
        ELSE 'Other'
    END AS x_account_type,
    
    SUM(aml.debit) AS x_debit,
    SUM(aml.credit) AS x_credit,
    SUM(aml.balance) AS x_balance

FROM account_move_line aml
JOIN account_move am ON aml.move_id = am.id
JOIN res_partner rp ON aml.partner_id = rp.id
JOIN account_account aa ON aml.account_id = aa.id

WHERE
    am.state = 'posted'
    AND aml.partner_id = 373

GROUP BY
    TO_CHAR((am.date::timestamp AT TIME ZONE 'Asia/Karachi'), 'YYYY-MM-DD'),
    aa.id,
    aa.name->>'en_US',
    rp.name,
    am.name

ORDER BY
    x_date DESC,
    x_account_name;
