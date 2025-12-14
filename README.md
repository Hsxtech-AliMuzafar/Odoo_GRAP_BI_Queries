# Odoo Dashboard Queries

Welcome to the Dashboards query repository. This directory contains a collection of optimized SQL scripts designed for data extraction and reporting within the Odoo ecosystem.

## Overview

High-quality business intelligence requires precise data retrieval. These scripts are crafted to work seamlessly with the **Odoo BI SQL Helper** module by **GRAP**, allowing users to define direct SQL queries for building robust dashboards and visual reports.

## Technical Scope

*   **Target Database**: PostgreSQL
*   **Operation Type**: Read-Only (Data Retrieval)
*   **Integration**: Odoo BI SQL Helper (GRAP)

## Usage Instructions

These queries are intended for use within the SQL Views configuration in Odoo.
1.  **Install**: Ensure the *Odoo BI SQL Helper* module is installed in your instance.
2.  **Deploy**: Copy the relevant SQL script content.
3.  **configure**: Paste into a new SQL View definition to generate the necessary data tables/views for your dashboarding tool.

## Available domains

The queries in this folder cover various operational areas including:
*   Sales Performance (Daywise analysis)
*   Inventory & Stock Management
*   Manufacturing Orders
*   Financial/Accounting Reports

> **Note**: These queries are strictly for data gathering. They are optimized for performance and do not modify any existing records. Ensure your Odoo schema matches the query expectations.

> **link to the Module's Repo :**  https://github.com/OCA/reporting-engine/tree/18.0/bi_sql_editor


## By HSxTech - Collaborate, Lead, Innovate