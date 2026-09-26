-- Task 1: Basic SQL Queries
-- Topics: SELECT, WHERE, ORDER BY, and calculated columns

select 
ad_date,
spend,
clicks,
spend / clicks as sc
from 
facebook_ads_basic_daily
where 
clicks > 0 
order by 
ad_date desc;
