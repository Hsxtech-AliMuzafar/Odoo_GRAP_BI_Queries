# Odoo Dashboard Queries

Welcome to the Dashboards query repository. This directory contains a collection of optimized SQL scripts designed for data extraction and reporting within the Odoo ecosystem.

## Overview

High-quality business intelligence requires precise data retrieval. These scripts are crafted to work seamlessly with the **Odoo BI SQL Helper** module by **GRAP**, allowing users to define direct SQL queries for building robust dashboards and visual reports.

## Technical Scope

*   **Target Database**: PostgreSQL
*   **Operation Type**: Read-Only (Data Retrieval)
*   **Integration**: Odoo BI SQL Helper (GRAP)

## File Registry & Available Queries

The queries are grouped by project/domain prefixes found in the repository.

### NJ - Jewelry & Product Data
*   **`NJ - Product Data.sql`**: Extracts detailed product information including creation metadata (who created it and when), jewelry specific attributes (net weight, polish, pieces), and cost/sales pricing.

### TCC - POS & Raw Materials
*   **`TCC - Sales Daywise.sql`**: detailed Point of Sale (POS) analysis aggregated by Day and Hour slots, calculating total orders and average order value.
*   **`TCC - Sales Daywise 2.sql`**: Alternative POS sales view aggregated by Week number and Day of the week.
*   **`TCC - Consumption.sql`**: Analyzes POS orders against stock moves to track product consumption and current stock levels relative to sales.
*   **`TCC - Raw Material Analysis.sql`**: Financial analysis of raw material accounts, providing daily debit/credit/balance summaries for specific partners.

### VIS - Core Business Operations
*   **`VIS -Sales.sql`**: Comprehensive Sales Order analysis including margins per unit, salesperson performance, and customer order counts.
*   **`VIS -Purchase.sql`**: Purchase Order tracking, comparing ordered quantities vs received quantities to determine delivery status (Fully/Partially Received).
*   **`VIS -Manufacturing.sql`**: Manufacturing analysis comparing BOM costs vs Actual production costs to calculate margins per unit produced.
*   **`VIS -Inventory.sql`**: Stock movement analysis tracking incoming, outgoing, and produced quantities to calculate net stock changes over time.
*   **`Vis -Accounts.sql`**: Receivable/Payable aging analysis, categorizing move lines into due buckets (1-30, 31-60, 60-90, >90 days).

## Usage Instructions

These queries are intended for use within the SQL Views configuration in Odoo.
1.  **Install**: Ensure the *Odoo BI SQL Helper* module is installed in your instance.
2.  **Deploy**: Copy the relevant SQL script content.
3.  **Configure**: Paste into a new SQL View definition to generate the necessary data tables/views for your dashboarding tool.

> **Note**: These queries are strictly for data gathering. They are optimized for performance and do not modify any existing records. Ensure your Odoo schema matches the query expectations.

> **Link to the Module's Repo:**  https://github.com/OCA/reporting-engine/tree/18.0/bi_sql_editor


## By HSxTech - Collaborate, Lead, Innovate