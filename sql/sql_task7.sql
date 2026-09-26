-- Task 7: Date, Time, and Window Functions

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
),
monthly_utm_campaigns as (
    select 
        date_trunc('month', ad_date) as ad_month,
        utm_campaign,
        sum(t_spend) as total_cost,
        sum(t_impressions) as number_of_impressions,
        sum(t_clicks) as number_of_clicks,
        sum(t_value) as conversion_value,
        case when sum(t_impressions) > 0 then round(sum(t_clicks) * 100 / sum(t_impressions), 2) else 0 end as ctr,
        case when sum(t_clicks) > 0 then round(sum(t_spend) / sum(t_clicks), 2) else 0 end as cpc,
        case when sum(t_impressions) > 0 then round(1000 * sum(t_spend) / sum(t_impressions), 2) else 0 end as cpm,
        case when sum(t_spend) > 0 then round(sum(t_value) - sum(t_spend), 2) else 0 end as romi
    from utm_campaigns
    group by date_trunc('month', ad_date), utm_campaign
)
select 
    ad_month,
    utm_campaign,
    total_cost,
    number_of_impressions,
    number_of_clicks,
    conversion_value,
    ctr,
    cpc,
    cpm,
    romi,
    case when lag(cpm) over(partition by utm_campaign order by ad_month) > 0
         then round((cpm - lag(cpm) over(partition by utm_campaign order by ad_month)) * 100 / lag(cpm) over(partition by utm_campaign order by ad_month), 2)
         else null end as cpm_mom,
    case when lag(ctr) over(partition by utm_campaign order by ad_month) > 0
         then round((ctr - lag(ctr) over(partition by utm_campaign order by ad_month)) * 100 / lag(ctr) over(partition by utm_campaign order by ad_month), 2)
         else null end as ctr_mom,
    case when lag(romi) over(partition by utm_campaign order by ad_month) > 0
         then round((romi - lag(romi) over(partition by utm_campaign order by ad_month)) * 100 / lag(romi) over(partition by utm_campaign order by ad_month), 2)
         else null end as romi_mom
from monthly_utm_campaigns
order by ad_month asc, utm_campaign;
