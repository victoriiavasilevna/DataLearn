--Overview
--Total Sales,Total Profit, Profit Ratio, Profit per Order, Sales per Customer, Avg. Discount
select round(sum(sales),0) Total_Sales, round(sum(profit),0)  Total_Profit,
round(sum(profit)/sum(sales),2) as profit_ratio,
round(sum(profit)/count(order_id),1) Profit_per_order,
round(sum(sales)/count(distinct(o.customer_id)),0) Sales_per_customer,
round(sum(discount*sales)/sum(sales),2) as avg_discount
from public.orders o 

--Monthly Sales by Segment


select segment, extract(year from order_date) as year,extract(month from order_date) as month, round(sum(sales),0) as revenue from orders o 
group by segment, extract(year from order_date), extract(month from order_date)
order by segment, year, month

--Monthly Sales by Category
select category, extract(year from order_date) as year,extract(month from order_date) as month, round(sum(sales),0) as revenue from orders o 
group by category, extract(year from order_date), extract(month from order_date)
order by category, year, month

--Sales by Product Category over time
select category, subcategory, product_name, extract(year from order_date) as year,extract(month from order_date) as month, round(sum(sales),0)
as revenue from orders o 
group by category, subcategory, product_name, extract(year from order_date), extract(month from order_date)
order by category, year, month

--Customer Analysis
--Sales and Profit by Customer and ranking

select customer_name, round(sum(sales),0) as revenue, round(sum(profit),0) as profit from orders o2 
group by customer_name order by round(sum(profit),0) desc 

--Sales per region

select o.region, p.person as territory_manager, round(sum(sales),0) as revenue from orders o left join people p
on o.region = p.region 
group by o.region, p.person order by round(sum(profit),0) desc 




