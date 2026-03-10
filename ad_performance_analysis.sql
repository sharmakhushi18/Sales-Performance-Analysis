-- ============================================================
-- Ad Performance Analysis using SQL
-- Author: Khushi Sharma
-- Description: Analyzes advertising campaign performance
-- to uncover insights and optimization opportunities
-- ============================================================

-- ─────────────────────────────────────────
-- TABLE SETUP (Mock Data)
-- ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id     INT PRIMARY KEY,
    campaign_name   VARCHAR(100),
    channel         VARCHAR(50),   -- e.g. Search, Display, Video
    budget          DECIMAL(10,2),
    start_date      DATE,
    end_date        DATE
);

CREATE TABLE IF NOT EXISTS ad_metrics (
    metric_id       INT PRIMARY KEY,
    campaign_id     INT,
    date            DATE,
    impressions     INT,
    clicks          INT,
    conversions     INT,
    spend           DECIMAL(10,2),
    revenue         DECIMAL(10,2),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- ─────────────────────────────────────────
-- INSERT SAMPLE DATA
-- ─────────────────────────────────────────

INSERT INTO campaigns VALUES
(1, 'Summer Sale Search',   'Search',  5000.00, '2024-06-01', '2024-06-30'),
(2, 'Brand Awareness Video','Video',   8000.00, '2024-06-01', '2024-06-30'),
(3, 'Retargeting Display',  'Display', 3000.00, '2024-06-01', '2024-06-30'),
(4, 'Performance Max Q2',   'PMax',    10000.00,'2024-06-01', '2024-06-30');

INSERT INTO ad_metrics VALUES
(1,  1, '2024-06-01', 15000, 600,  30, 450.00,  1800.00),
(2,  1, '2024-06-02', 18000, 720,  42, 540.00,  2520.00),
(3,  2, '2024-06-01', 50000, 300,  10, 600.00,   800.00),
(4,  2, '2024-06-02', 48000, 290,  12, 580.00,   960.00),
(5,  3, '2024-06-01', 20000, 800,  55, 320.00,  2750.00),
(6,  3, '2024-06-02', 22000, 880,  60, 352.00,  3000.00),
(7,  4, '2024-06-01', 35000, 1400, 90, 980.00,  6300.00),
(8,  4, '2024-06-02', 40000, 1600, 110,1120.00, 7700.00);

-- ─────────────────────────────────────────
-- ANALYSIS 1: Overall Campaign Performance
-- ─────────────────────────────────────────

SELECT
    c.campaign_name,
    c.channel,
    SUM(m.impressions)                              AS total_impressions,
    SUM(m.clicks)                                   AS total_clicks,
    SUM(m.conversions)                              AS total_conversions,
    ROUND(SUM(m.clicks) * 100.0 / SUM(m.impressions), 2) AS ctr_percent,
    ROUND(SUM(m.conversions) * 100.0 / SUM(m.clicks), 2) AS conversion_rate,
    ROUND(SUM(m.spend), 2)                          AS total_spend,
    ROUND(SUM(m.revenue), 2)                        AS total_revenue,
    ROUND(SUM(m.revenue) / SUM(m.spend), 2)         AS roas   -- Return on Ad Spend
FROM campaigns c
JOIN ad_metrics m ON c.campaign_id = m.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.channel
ORDER BY roas DESC;

-- ─────────────────────────────────────────
-- ANALYSIS 2: Best Performing Channel
-- ─────────────────────────────────────────

SELECT
    c.channel,
    ROUND(AVG(m.clicks * 100.0 / m.impressions), 2) AS avg_ctr,
    ROUND(SUM(m.revenue) / SUM(m.spend), 2)          AS avg_roas,
    SUM(m.conversions)                                AS total_conversions
FROM campaigns c
JOIN ad_metrics m ON c.campaign_id = m.campaign_id
GROUP BY c.channel
ORDER BY avg_roas DESC;

-- ─────────────────────────────────────────
-- ANALYSIS 3: Daily Trend (Spend vs Revenue)
-- ─────────────────────────────────────────

SELECT
    m.date,
    SUM(m.spend)                                    AS daily_spend,
    SUM(m.revenue)                                  AS daily_revenue,
    ROUND(SUM(m.revenue) - SUM(m.spend), 2)         AS daily_profit,
    ROUND(SUM(m.revenue) / SUM(m.spend), 2)         AS daily_roas
FROM ad_metrics m
GROUP BY m.date
ORDER BY m.date;

-- ─────────────────────────────────────────
-- ANALYSIS 4: Underperforming Campaigns
-- (High spend but low ROAS — needs optimization)
-- ─────────────────────────────────────────

SELECT
    c.campaign_name,
    c.channel,
    ROUND(SUM(m.spend), 2)                    AS total_spend,
    ROUND(SUM(m.revenue) / SUM(m.spend), 2)   AS roas,
    CASE
        WHEN SUM(m.revenue) / SUM(m.spend) < 2 THEN '⚠ Needs Optimization'
        WHEN SUM(m.revenue) / SUM(m.spend) < 4 THEN '✓ Acceptable'
        ELSE '★ High Performer'
    END AS performance_flag
FROM campaigns c
JOIN ad_metrics m ON c.campaign_id = m.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.channel
ORDER BY roas ASC;
