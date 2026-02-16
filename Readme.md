## Data Analytics Project


## Project summary
This project demonstrates a complete analytics workflow end to end. I started with a Kaggle retail transactions dataset, cleaned and standardized it in Excel, exported it to CSV, loaded it into SQL for validation and analysis using queries, and finally connected SQL to Power BI to build an interactive dashboard.

The Power BI report is organized into five pages: `Overview`, `Sales`, `Customer`, `Product`, and `Geographic`. The goal is to answer practical business questions with validated metrics rather than just showing visuals.

---

##  Tools & Technologies Used
- Microsoft Excel (Data Cleaning)
- SQL (Data Analysis & Queries)
- Power BI (Dashboard & Visualization)

---

##  Project Workflow

### 1️⃣ Data Cleaning (Excel)
- Removed duplicate records
- Handled missing values
- Standardized data formats
- Prepared dataset for analysis

---

### 2️⃣ Data Analysis (SQL)
Performed various SQL operations including:

- Data filtering
- Aggregations & calculations
- Business logic queries

Example analysis performed:

- [Example: Top-10 Customers by revenue]
- [Example:]Top-10 products by quantity sold
- [Example: Sales by Country]

---

### 3️⃣ Data Visualization (Power BI)
Created interactive dashboards to visualize:

- Key performance metrics
- Trends & comparisons
- Business insights
- KPI tracking

---

## Key Insights
---
### Overview(2010)

- What is the total Sales and Total Customer?
  	$9.08M & 4K
-Compare order vs Quantity
	order-27K and Quantity-$5M
        Units per order=Quantity/Order=185.18
      ->Which indicates that customer are buying large volume mostly like whole sale.
- Top and Bottom performing countries
	UK is performing top with  $7.8M sales
      ->Focus marketing budget on UK and protecting this market, Study why UK is performing best and replace everywhere.
	Saudi Arabia is performing less sales with $131.17
      ->Few Customer, Weak Market Presence or poor pricing strategy etc.
-Revenue Drives
	Revenue heavily depends on UK, Business concentration is a risk.

---

### Sales(2010)

-Which month has highest and lowest sales?
	November has the highest sales-$1416697.2
	Seasonal Demand and Sales peak towards the later part of the year.
        February has the lowest sales-$531265.36
	Show weak demand on off season

-Growth or instability?
	Sharp spike, Sudden drop, fluctuation is found in the revenue trend this indicates that revenue is volatile
	with major spike followed by dip. Suggesting irregular purchasing cycle or promotion.

-Revenue vs Order(Does both spike together?)
	Yes in November so it indicates volume driven growth
      ->Revenue spikes are not always perfectly aligned with order spikes.
-Is business performance stable across the year?
	No here the business mostly depends on seasonal spike while normally comes towards the year end.

---

### Customer(2010)

-Total customers?
	4K
-Returning vs one time?
	3k returning and 1K one time customers which indicates that very large number of customers are returning suggesting
	very strong customer retention and repeat purchase behaviour.
-Is revenue evenly distributed across customer?
	No, unequal bars which is not evenly distributed.
      ->Customer spending is highly uneven here, minority of a customer generate majority of revenue and few customer generate
	generate high revenue.
-What business risk exist in this customer structure?
	Depends on limited set of high spending customer may expose the business revenue and may collapse if they churn.

---

### Product(2011)

-Best selling product by quantity?
 	Check-151314
     ->	Drives volume which indicates strong demand or frequent purchase
-Slowest moving product
	Printing Smudges- -22984
     -> Possible dead stock or discontinued or returned items.
-Are slow moving products expensive or cheap?
	Cheap 
     ->cheap slow movers which impact financially lower
-Are there products with negative sales values? Why?
	Example: Bank charges show negative
      ->Negative values may indicate returns, refunds, Adjustments.

---

### Geography(2011)
-Which country dominates orders?
	United Kingdom 
      ->business is heavily concentrated in one market and if UK demand drops, revenue drops.
-What does the gap between Germany/France orders vs Revenue tell
	->Customer may buy low priced product, discount may be common opportunity for upselling.
-Are there any outlawyer there in the scatter plot?
	Uk bubble appear far right so that means high revenue
      ->very high value customer, bulk purchases.
-Which country looks like an expansion opportunity?
	-Netherlands
        -> Demands exists, Customer acceptance proven and scaling marketing can multiply sales.    

---

## Files Included
- Raw Dataset
- Cleaned Excel File
- SQL Queries
- Power BI Dashboard File

---

##  Purpose of the Project
This project was developed to demonstrate practical data analytics skills:

✔ Data Cleaning  
✔ SQL Querying  
✔ Data Visualization  
✔ Insight Generation  

---

## 👤 Author
Sangeerth KM
Aspiring Data Analyst
