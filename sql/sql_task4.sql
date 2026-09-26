-- Task 4: Joins, DML, and CRUD Operations

-- Create an enriched view by joining daily ads data with ad set and campaign data.
create view fb_enriched as 
select 
    a.adset_name,
    c.campaign_name,
    d.ad_date,
    spend,
    impressions,
    reach,
    clicks,
    leads,
    value
from facebook_ads_basic_daily d
left join facebook_adset a on d.adset_id = a.adset_id
left join facebook_campaign c on d.campaign_id = c.campaign_id;

with face_google_ads as 
(
    select ad_date, 'Facebook Ads' as media_source, campaign_name, adset_name, spend, impressions, clicks, value
    from fb_enriched
    union all 
    select ad_date, 'Google Ads' as media_source, campaign_name, adset_name, spend, impressions, clicks, value
    from google_ads_basic_daily
)
select ad_date, media_source, campaign_name, adset_name,
       sum(spend) as t_spend,
       sum(impressions) as t_impressions,
       sum(clicks) as t_clicks,
       sum(value) as t_value
from face_google_ads
group by ad_date, media_source, campaign_name, adset_name;
