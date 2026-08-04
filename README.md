# PORTFOLIO              

Welcome to my projects.I am Emmanuel Agyemang,an Msc International Economics student at the universite de Orleans,France.The below projects hightlight some of my skills and experiences.

# I.Customer Retention Analysis — SQL and Power BI

Reducing bank customer churn by turning two messy spreadsheet exports into a clean data model and two focused Power BI dashboards.

## The Problem

A retail bank was losing roughly 1 in 5 customers a year, and nobody could say exactly why. The raw data lived in two linked spreadsheets full of the usual real-world mess that consists of inconsistent country spellings, currency symbols stored as text, a duplicate record. So, before anyone could ask "why are people leaving," the data had to be trustworthy first. This project cleans that data with SQL, then surfaces the patterns that actually predict churn.

## Dataset

10,000 bank customers with demographics (age, gender, geography), account details (balance, tenure, products held, credit card status) and a churn flag. Sourced from two linked tables:

- Customer_Info — 10,001 rows, mixed geography spellings (France / FRA/ French)
- Account_Info — 10,002 rows, balances stored as text (€159660.8), one duplicate CustomerId

## Tools Used

| Tool | Role |
|---|---|
| **SQL** | Cleaning, standardising, and joining the raw tables into one analysis-ready table |
| **Power BI** | Data modelling, DAX measures, and the two dashboard pages |
| **Excel** | Quick sense-checks on the raw exports before writing the cleaning logic |

## Process

1. **Clean** — strip currency symbols, standardise geography spellings, convert `Yes/No` flags to `1/0`, drop the duplicate record → [`SQL/01_data_cleaning.sql`](SQL/01_data_cleaning.sql)
2. **Join** — merge the two source tables into a single `Churn_Master` table (10,001 + 10,002 messy rows → exactly 10,000 clean, unique customers)
3. **Analyse** — KPI, segment, and risk-list queries that power both dashboards → [`SQL/02_churn_analysis_queries.sql`](SQL/02_churn_analysis_queries.sql)
4. **Visualise** — load [`Data/Churn_Master_Cleaned.csv`](Data/Churn_Master_Cleaned.csv) into Power BI, build DAX measures ([`PowerBI/DAX_Measures.txt`](PowerBI/DAX_Measures.txt)), and design two report pages

## Dashboards

**Executive Overview** — headline KPIs, churn by geography, activity status, gender, and number of products held

![Executive Overview]((Dashboard_1_Executive_Overview.png)

**Churn Deep-Dive** — churn by age band, balance comparison, zero-balance vs funded accounts, credit card ownership, and tenure trend

![Churn Deep-Dive](Dashboard_2_Churn_DeepDive.png)

## Key Insights

- Overall churn sits at **20.4%** — high enough to matter, but concentrated in a few clear pockets rather than spread evenly
- **Product count is the strongest signal in the data**: churn is just 7.6% at 2 products, but jumps to 82.7% at 3 and 100% at 4 — over-selling without matching service is actively pushing people out
- **Germany churns at 32.4%**, roughly double France and Spain.This points to a market-specific issue, not a random blip
- **Inactive members churn almost twice as often** as active ones (26.9% vs 14.3%), and churned customers carry *higher* average balances (€91K vs €73K). The bank is often losing its more valuable, disengaged customers
- **Risk climbs sharply with age**, peaking at 56.2% in the 51-60 band, while tenure alone barely moves the needle

## Recommendations

- Cap or review any push toward 3+ products per customer. That's where churn goes from manageable to near-certain
- Run a targeted engagement campaign for inactive, mid-to-high-balance members before they leave
- Investigate the German market specifically. Pricing, service quality, or local competition are the likely drivers
- Route the SQL-generated high-risk customer list (still-active, single product, inactive, or 51-60 with a healthy balance) to the retention team monthly.


# 2.Coffee Shop Sales Performance Analysis.

Understanding revenue growth, peak hours and top sellers for a 3-store NYC coffee chain by moving from a raw POS export to a clean data model and two focused Power BI dashboards.

## The Problem

A small coffee shop chain with three New York locations had six months of point-of-sale data and no easy way to read it. The owners could see the register totals each day, but they couldn't answer the questions that actually drive decisions: which store is pulling its weight, when is the shop busiest, which products are worth the counter space, and is the business actually growing. The raw export was a single 149,000-row transaction log — accurate, but unusable without structure.

## Dataset

149,116 individual transactions across three stores (Lower Manhattan, Hell's Kitchen, Astoria) from January to June 2023 — each row a single item sold, with quantity, unit price, product category/type/detail, store, date and time. The data was already well-formed (no missing values, no duplicate transactions), so the work was reshaping it — calculating revenue, extracting hour/weekday/month — rather than heavy repair.

## Tools Used

| Tool | Role |
|---|---|
| **Excel** | First-pass data quality checks and a formula-driven pivot summary on a working sample, before scaling up |
| **SQL (T-SQL)** | The repeatable, full-scale clean and every aggregate query behind the dashboards |
| **Power BI** | Data modelling, DAX measures, and the two dashboard pages |

## Process

1. **Check (Excel)** — a 5%, month-stratified sample of the raw export (~7,500 rows — representative, but small enough for formulas to stay fast) run through `COUNTIF`/`COUNTA` checks for nulls, duplicates, and inconsistent store or category names → [`Excel/Coffee_Sales_Excel_Analysis.xlsx`](Excel/Coffee_Sales_Excel_Analysis.xlsx)
2. **Summarise (Excel)** — a pivot-style summary built entirely from `SUMIF` formulas: revenue by store, category, month, weekday, and hour — confirming the sample told the same story the full dataset later would
3. **Clean & scale (SQL)** — the raw `Transactions` table rebuilt as `Sales_Master` across the complete 149,116 rows: revenue calculated as `quantity × unit price`, timestamps split into hour/weekday/month → [`SQL/01_data_cleaning.sql`](SQL/01_data_cleaning.sql)
4. **Analyse (SQL)** — KPI, trend, and product-ranking queries that power both dashboards → [`SQL/02_sales_analysis_queries.sql`](SQL/02_sales_analysis_queries.sql)
5. **Visualise (Power BI)** — [`Data/Coffee_Sales_Cleaned.csv`](Data/Coffee_Sales_Cleaned.csv) loaded into Power BI, DAX measures built ([`PowerBI/DAX_Measures.txt`](PowerBI/DAX_Measures.txt)), two report pages designed

## Dashboards

**Executive Overview** — headline KPIs, monthly revenue trend, revenue by store, revenue by category, revenue by weekday

![Sales Overview](Dashboard Sales Overview.png).

**Sales Deep-Dive** — revenue by hour of day, top products by revenue, units sold by category, average order value by store

![Sales Deep-Dive](Dashboard_1_Executive_Overview.png)

## Key Insights

- Revenue more than **doubled over the period** — from $82K in January to $166K in June, a **104% increase**
- The three stores are **remarkably balanced**: each brings in roughly a third of total revenue, within $7K of each other — growth isn't being carried by one location
- **Coffee and tea make up ~67% of all revenue**, with Barista Espresso and Brewed Chai tea the two single biggest product types
- Sales are heavily concentrated in the morning: the **7-10am window drives ~40% of daily revenue**, with a sharp drop-off after 11am
- Weekends trail weekdays slightly in revenue, and **Lower Manhattan has the highest average order value** ($4.81) of the three stores

## Recommendations

- Staff and stock more heavily for the 7-10am rush specifically — this window has an outsized revenue impact
- Lean into the growth trend with a mid-year push (loyalty offers, extended hours) before the typical summer plateau
- Test a weekend-specific promotion to close the gap with weekday revenue
- Use Lower Manhattan's higher average order value as a model for the other two stores

