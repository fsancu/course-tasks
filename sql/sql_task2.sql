-- Task 2: Marketing Analytics and Aggregation
-- Topics: marketing analytics, conversion metrics, logical operators, and aggregation

select * 
from facebook_ads_basic_daily;

select 
distinct campaign_id,
ad_date,
sum(spend) as Tspend,
sum(impressions) as Timpressions,
sum(clicks) as Tclicks,
sum(value) as Tvalues,
round((sum(spend) * 1.0 / sum(impressions)) * 1000, 2) as CPM,
round((sum(clicks) * 1.0 / sum(impressions)) * 100, 2) as CTR,
round(sum(spend) * 1.0 / sum(clicks), 2) as CPC,
round(((sum(value) - sum(spend)) * 1.0 / sum(spend)) * 100, 2) as ROMI
from
facebook_ads_basic_daily
group by 
ad_date, campaign_id
having
sum(impressions) > 0
and sum(clicks) > 0
and sum(spend) > 0
order by romi desc;

-- Bonus
select 
distinct campaign_id,
ad_date,
sum(spend) as Tspend,
sum(value) as Tvalues
from
facebook_ads_basic_daily
group by 
ad_date, campaign_id
having
sum(spend) > 500000;
