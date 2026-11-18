# E-Commerce Sales, Cohort Retention & RFM Analytics Dashboard

An end-to-end Business Intelligence and Data Analytics portfolio project built using **SQL Server (T-SQL)** and **Microsoft Power BI (DAX)**. This solution models multi-year e-commerce transactions in a Star Schema data warehouse and delivers executive-level KPIs, Cohort Retention tracking, and automated RFM customer segmentation.

---

## Dashboard Preview

### 1. Executive Overview
Tracks core business KPIs (**$1.08M+ Total Revenue**, **$627.05K Net Profit**, **58.29% Profit Margin**, and **AOV**), chronological monthly revenue & profit margin trends, and revenue breakdown by product category.
![Executive Overview](Screenshot%202026-11-18%20013352.png)

### 2. Customer Segments & RFM Analysis
Visualizes customer retention decay through a color-coded **Cohort Retention Heatmap**, automated **RFM Customer Segmentation** (*Champions*, *Loyal Customers*, *Regular*, *At Risk*), and an interactive customer revenue table.
![Customer Segments & RFM](Screenshot%202026-11-18%20013536.png)

---

## Architecture & Tech Stack
* **Database & Data Engineering (`SQLQuery4.sql`):** Designed a Star Schema data warehouse in **SQL Server** (`Fact_Sales`, `Dim_Customer`, `Dim_Date`, `Dim_Product`) populated with **24,771 transactions** across **500 customers**.
* **BI & Data Modeling (`project.pbix`):** Built dynamic **DAX** measures and calculated columns for:
  * **Cohort Retention %:** `DATEDIFF` & `REMOVEFILTERS` logic tracking repeat purchase behavior by signup month.
  * **RFM Segmentation:** `SWITCH`, `MAXX`, and `RELATEDTABLE` logic classifying customers dynamically by Recency, Frequency, and Monetary value.
