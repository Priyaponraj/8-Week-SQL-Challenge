-- ============================================= 3.efore & After Analysis Before & After Analysis ==================

--  database

use data_mart;

-- Case Study #5 - Data Mart
select * from data_mart.clean_weekly_sales
where calendar_year=2020 and week_date = '2020-07-06'
order by week_date asc;

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? and 
-- What is the growth or reduction rate in actual values and percentage of sales?


-- find the 4 weeks before and after 2020-06-15?

-- before
select distinct week_date
from data_mart.clean_weekly_sales
where week_date < '2020-06-15'
order by week_date desc
limit 4;

-- after
select distinct week_date
from data_mart.clean_weekly_sales
where week_date > '2020-06-15'
order by week_date desc
limit 4;

with sales_period as (
select 
	case
		when week_date < '2020-06-15' then 'before'
        else 'after'
	end as period,
    sum(sales) as total_sales
from data_mart.clean_weekly_sales
where week_date between '2020-05-18' and '2020-07-06'
group by 
case
	when week_date < '2020-06-15' then 'before'
	else 'after'
	end
), comparison as (
select max(case when period = 'before' then total_sales end) as before_sales ,
            
		max(case  when period = 'after' then total_sales end) as after_sales
 from sales_period           
)
select before_sales,
		after_sales,
        (after_sales - before_sales) as sub,
        round((after_sales - before_sales) * 100.0 / before_sales , 2) as percentage_changes_in_sales
 from comparison;       
 

 -- What about the entire 12 weeks before and after?
 with sales_period as (
    select 
        case
            when week_date < '2020-06-15' then 'before'
            else 'after'
        end as period,

        sum(sales) as total_sales

    from data_mart.clean_weekly_sales

    where week_date between '2020-03-23' and '2020-08-31'

    group by 
        case
            when week_date < '2020-06-15' then 'before'
            else 'after'
        end
),

comparison as (
    select
        max(case 
            when period = 'before' then total_sales
        end) as before_sales,

        max(case 
            when period = 'after' then total_sales
        end) as after_sales

    from sales_period
)

select
    before_sales,
    after_sales,
    after_sales - before_sales as sales_change,

    round(
        (after_sales - before_sales) * 100.0 / before_sales,
        2
    ) as percentage_changes_in_sales

from comparison;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

with sales_comparison as (

    select
        calendar_year,

        case
            when weekofyear(week_date) between 13 and 24
                then 'before'
            when weekofyear(week_date) between 25 and 36
                then 'after'
        end as period,

        sum(sales) as total_sales

    from data_mart.clean_weekly_sales

    where calendar_year in (2018, 2019, 2020)
      and weekofyear(week_date) between 13 and 36

    group by
        calendar_year,
        case
            when weekofyear(week_date) between 13 and 24
                then 'before'
            when weekofyear(week_date) between 25 and 36
                then 'after'
        end
)

select
    calendar_year,
    period,
    total_sales
from sales_comparison
where period is not null
order by calendar_year, period;
