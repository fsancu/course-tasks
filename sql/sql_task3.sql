-- Task 3: CTEs, Subqueries, UNION, UNION ALL, and DDL

select * 
from facebook_ads_basic_daily;

select * 
from google_ads_basic_daily;

with fb_google as
(
    select ad_date, 'Facebook Ads' as media_source, spend, impressions, reach, clicks, leads, value
    from facebook_ads_basic_daily
    union all
    select ad_date, 'Google Ads' as media_source, spend, impressions, reach, clicks, leads, value
    from google_ads_basic_daily
)
select ad_date, media_source, sum(spend) as t_spend, sum(impressions) as t_impressions, sum(clicks) as t_clicks, sum(value) as t_value
from fb_google
group by ad_date, media_source;
