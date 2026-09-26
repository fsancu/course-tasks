-- Task 6: String Functions, NULL Handling, and SQL Functions

-- Create a Facebook Ads view enriched with ad set and campaign names.
create view fb_cte as
select
    a.adset_name,
    c.campaign_name,
    d.ad_date,
    spend,
    impressions,
    reach,
    clicks,
    leads,
    value,
    url_parameters
from facebook_ads_basic_daily d
left join facebook_adset a on d.adset_id = a.adset_id
left join facebook_campaign c on d.campaign_id = c.campaign_id;

-- Combine Facebook Ads and Google Ads data while handling NULL values.
create view fb_ggl_cte as
select coalesce(adset_name, 'Unknown') as adset_name,
       coalesce(campaign_name, 'Unknown') as campaign_name,
       ad_date,
       sum(coalesce(spend, 0)) as t_spend,
       sum(coalesce(impressions, 0)) as t_impressions,
       sum(coalesce(reach, 0)) as t_reach,
       sum(coalesce(clicks, 0)) as t_clicks,
       sum(coalesce(leads, 0)) as t_leads,
       sum(coalesce(value, 0)) as t_value,
       coalesce(url_parameters, 'Unknown') as url_parameters
from fb_cte
group by ad_date, adset_name, campaign_name, url_parameters
union all
select coalesce(adset_name, 'Unknown') as adset_name,
       coalesce(campaign_name, 'Unknown') as campaign_name,
       ad_date,
       sum(coalesce(spend, 0)) as t_spend,
       sum(coalesce(impressions, 0)) as t_impressions,
       sum(coalesce(reach, 0)) as t_reach,
       sum(coalesce(clicks, 0)) as t_clicks,
       sum(coalesce(leads, 0)) as t_leads,
       sum(coalesce(value, 0)) as t_value,
       coalesce(url_parameters, 'Unknown') as url_parameters
from google_ads_basic_daily
group by ad_date, adset_name, campaign_name, url_parameters;

-- Extract UTM campaign names and calculate marketing metrics.
with utm_campaigns as
(
    select 
        ad_date,
        case 
            when lower(substring(url_parameters from 'utm_campaign=([^&]+)')) = 'nan' then null
            else lower(substring(url_parameters from 'utm_campaign=([^&]+)'))
        end as utm_campaign,
        t_spend,
        t_impressions,
        t_clicks,
        t_value
    from fb_ggl_cte
)
select 
    ad_date,
    utm_campaign,
    case when sum(t_impressions) > 0 then round(sum(t_clicks) * 100 / sum(t_impressions), 2) else 0 end as ctr,
    case when sum(t_clicks) > 0 then round(sum(t_spend) / sum(t_clicks), 2) else 0 end as cpc,
    case when sum(t_impressions) > 0 then round(1000 * sum(t_spend) / sum(t_impressions), 2) else 0 end as cpm,
    case when sum(t_spend) > 0 then round(sum(t_value) - sum(t_spend), 2) else 0 end as romi
from utm_campaigns
group by ad_date, utm_campaign
order by ad_date asc;
