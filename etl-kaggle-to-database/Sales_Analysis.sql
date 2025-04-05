-- Table creation script

create table orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code int,
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
cost_price int,
list_price int,
quantity int,
discount_percent int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2)
);



-- 1. find top 10 highest reveue generating products

select product_id,sum(sale_price*quantity) as "Total_Revenue" from orders 
group by product_id order by Total_Revenue desc limit 10 ;


-- 2. find top 5 highest selling products in each region

with total_sales as (
select region,product_id,sum(sale_price) as "Total_Sales" from orders 
group by region,product_id order by region
), 
unique_values as (
select *,row_number() over(partition by region order by Total_Sales desc) as rn from total_sales 
),
top5_products as (
select region,product_id,Total_Sales from  unique_values where rn<=5
)
select * from top5_products;


-- 3. find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023


with year_mon_sales as (
select date_format(order_date,"%Y")as "year",date_format(order_date,"%m")as "month",sum(sale_price)  as "Total_Monthsale" from orders 
group by year,month order by month
)
select *,lag(Total_Monthsale) over(partition by month order by year) as prev_year_monthsales,
(Total_Monthsale - lag(Total_Monthsale) over(partition by month order by year)) as "SaleDifference" 
from year_mon_sales;


-- 4. for each category which month had highest sales

with monthy_sales as (
select category,year(order_date) as "year",month(order_date) as "month",sum(sale_price) as "Total_MonthSales"
from orders group by category,year,month order by category
),
unique_values as 
(
select * , row_number() over(partition by category order by Total_MonthSales desc) as rn from monthy_sales
)
select category,year,month,Total_MonthSales  from unique_values where rn=1;


-- 5. which sub category had highest growth by profit in 2023 compare to 2022

with totalprofit as (
select year(order_date) as "year",sub_category,sum(profit) as "Total_Profit" 
from orders group by sub_category, year
order by sub_category
),yearwise_profit as (
select sub_category,max(case when year=2022 then Total_Profit else 0 end) as profit_2022,
max(case when year=2023 then Total_Profit else 0 end) as profit_2023 
from totalprofit group by sub_category)
select sub_category,profit_2022,profit_2023,(profit_2023-profit_2022) as "Profit_Growth" from yearwise_profit
order by Profit_Growth desc limit 1




