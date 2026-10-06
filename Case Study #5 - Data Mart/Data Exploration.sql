=========================================================2. Data Exploration==========================================================

--  database

use database;

-- Case Study #5 - Data Mart
select * from data_mart.clean_weekly_sales;

-- 1. What day of the week is used for each week_date value?
select week_date,dayname(week_date) as week_days
from data_mart.clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
with recursive week_range as (
    select min(week_number) as week_number
    from data_mart.clean_weekly_sales

    union all

    select week_number + 1
    from week_range
    where week_number < (
        select max(week_number)
        from data_mart.clean_weekly_sales
    )
)
select week_number
from week_range
where week_number not in (
    select distinct week_number
    from data_mart.clean_weekly_sales
)
order by week_number;



-- 3. How many total transactions were there for each year in the dataset?
select calendar_year,sum(transactions)
from data_mart.clean_weekly_sales
group by calendar_year
order by sum(transactions) desc;


-- 4. What is the total sales for each region for each month?
select month_number, region,sum(sales)
from data_mart.clean_weekly_sales
group by month_number,region

-- 5. What is the total count of transactions for each platform
select platform, count(transactions) as  total_count_of_transactions
from data_mart.clean_weekly_sales
group by platform

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
with cte as (
select platform,month_number,sum(sales) as platform_sales
from data_mart.clean_weekly_sales
group by month_number, platform
)
select platform, 
	   month_number,
       platform_sales,
       round(platform_sales * 100.0 / sum(platform_sales) over(partition by month_number) , 2) as sales_percentage
       from cte
	   order by month_number;


-- 7. What is the percentage of sales by demographic for each year in the dataset?
with cte as (
select demographic,
	   calendar_year,
       sum(sales) as sales_by_demographic
from data_mart.clean_weekly_sales
group by demographic, calendar_year
)
select demographic,
	   calendar_year,
       sales_by_demographic,
      round(sales_by_demographic * 100.0 / sum(sales_by_demographic) over(partition by calendar_year),2) as percentage_of_sales_by_demographic
from cte
group by demographic,
	   calendar_year


-- 8. Which age_band and demographic values contribute the most to Retail sales?
select age_band, 
	   demographic,
       sum(sales) as most_to_Retail_sales
from data_mart.clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic,platform
order by most_to_Retail_sales 
limit 1;


-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select calendar_year,
		platform,
		sum(sales) as total_sales,
        sum(transactions) as total_transactions,
        round(sum(sales) / sum(transactions),2) as avg_transaction_sales
from data_mart.clean_weekly_sales
group by calendar_year, platform
order by calendar_year, platform;
		
        
        
        