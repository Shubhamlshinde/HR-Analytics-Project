use Olist;
#Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

select Weekday_Weekend.day_end ,
	concat(round(Weekday_Weekend.total_payment /(select sum(payment_value) from olist_order_payments_dataset) *100,2), '%') as percentage_payment_values
from
(select ord.day_end, sum(pmt.payment_value) as total_payment
	from olist_order_payments_dataset as pmt
	join
(select distinct order_id,
case
when weekday(order_purchase_timestamp) in (5,6) then "Weekends"
else "Weekdays"
end as  day_end
from olist_orders_dataset) as ord
on ord.order_id = pmt.order_id
group by ord.day_end) as Weekday_Weekend;

#Number of Orders with review score 5 and payment type as credit card.
select
concat(round(count(pmt.order_id) / 1000, 1), 'K') as Total_Orders
from
olist_order_payments_dataset pmt
inner join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where
rev.review_score =5
and pmt.payment_type = 'credit_card';

#3--Average number of days taken for order_delivered_customer_date for pet_shop

select
prod.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) as Avg_Shipping_Days
from olist_orders_dataset ord
join 
(select product_id,order_id,product_category_name
from olist_products_dataset
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "pet_shop"
group by prod.product_category_name;

#3--Average price and payment values from customers of sao paulo city

with OrderItemAvg as (
	select round(avg(item.price)) AS avg_order_item_price
	from olist_order_items_dataset item
	join olist_orders_dataset ord
	on item.order_id = ord.order_id
	join olist_customers_dataset cust on ord.customer_id =cust.customer_id
	where cust.customer_city = "Sao Paulo"
)
select
(select avg_order_item_price from OrderItemAvg) as avg_order_item_price,
round(avg(pmt.payment_value)) as avg_payment_value
from olist_order_payments_dataset pmt
join olist_orders_dataset ord on pmt.order_id = ord.order_id
join olist_customers_dataset cust on ord.customer_id = cust.customer_id
where
cust.customer_city ="Sao Paulo";

#5--Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date ,order_purchase_timestamp)),0) as "Avg Shipping Days"
from olist_orders_dataset as ord
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score;
