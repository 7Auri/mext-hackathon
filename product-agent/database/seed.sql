-- Campaign Intelligence System - Seed Data
-- Sample data for testing

-- ============================================================================
-- TENANT
-- ============================================================================

INSERT INTO tenant (tenant_id, name) VALUES
('11111111-1111-1111-1111-111111111111', 'Demo E-commerce'),
('22222222-2222-2222-2222-222222222222', 'Test Fashion Store'),
('33333333-3333-3333-3333-333333333333', 'Beauty Pro Shop');

-- ============================================================================
-- CITIES & CLIMATE
-- ============================================================================

-- İstanbul
INSERT INTO city (city_id, tenant_id, country_code, name, region_code, latitude, longitude) VALUES
('c0000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'TR', 'İstanbul', 'MARMARA', 41.0082, 28.9784),
('c0000002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'TR', 'Ankara', 'IC_ANADOLU', 39.9334, 32.8597),
('c0000003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'TR', 'İzmir', 'EGE', 38.4237, 27.1428),
('c0000004-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'TR', 'Antalya', 'AKDENIZ', 36.8969, 30.7133);

-- Climate data for İstanbul (12 months)
INSERT INTO geo_climate_monthly (tenant_id, city_id, month, avg_temp_c, rainfall_mm, humidity_pct, season_tag) VALUES
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 1, 6, 105, 75, 'WINTER'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 2, 7, 78, 78, 'WINTER'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 3, 9, 71, 72, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 4, 13, 46, 68, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 5, 18, 34, 65, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 6, 23, 24, 62, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 7, 26, 18, 60, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 8, 26, 22, 62, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 9, 22, 48, 68, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 10, 17, 85, 72, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 11, 12, 98, 75, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000001-0000-0000-0000-000000000001', 12, 8, 125, 78, 'WINTER');

-- Climate data for Ankara
INSERT INTO geo_climate_monthly (tenant_id, city_id, month, avg_temp_c, rainfall_mm, humidity_pct, season_tag) VALUES
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 1, 0, 42, 70, 'WINTER'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 2, 2, 35, 65, 'WINTER'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 3, 7, 38, 60, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 4, 12, 48, 58, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 5, 17, 52, 55, 'SPRING'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 6, 21, 28, 50, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 7, 24, 14, 45, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 8, 24, 12, 45, 'SUMMER'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 9, 19, 18, 50, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 10, 13, 32, 58, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 11, 6, 38, 65, 'FALL'),
('11111111-1111-1111-1111-111111111111', 'c0000002-0000-0000-0000-000000000002', 12, 2, 45, 70, 'WINTER');

-- ============================================================================
-- CATEGORIES
-- ============================================================================

INSERT INTO category (category_id, tenant_id, name) VALUES
-- Electronics
('cat00001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Laptops'),
('cat00002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Peripherals'),
('cat00003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Components'),
-- Fashion
('cat00004-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', 'Clothing'),
('cat00005-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', 'Shoes'),
('cat00006-0000-0000-0000-000000000006', '22222222-2222-2222-2222-222222222222', 'Accessories'),
-- Beauty
('cat00007-0000-0000-0000-000000000007', '33333333-3333-3333-3333-333333333333', 'Skincare'),
('cat00008-0000-0000-0000-000000000008', '33333333-3333-3333-3333-333333333333', 'Makeup'),
('cat00009-0000-0000-0000-000000000009', '33333333-3333-3333-3333-333333333333', 'Haircare');

-- ============================================================================
-- SAMPLE PRODUCTS
-- ============================================================================

-- Electronics
INSERT INTO product (product_id, tenant_id, sku, name, category_id, base_price, cost, stock_quantity, safety_stock, lifecycle_stage, trend_score, is_seasonal) VALUES
('prod0001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'LAPTOP-001', 'Gaming Laptop RTX 4070', 'cat00001-0000-0000-0000-000000000001', 25000, 20000, 5, 10, 'DECLINING', 35, FALSE),
('prod0002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'MOUSE-001', 'Wireless Mouse', 'cat00002-0000-0000-0000-000000000002', 250, 150, 150, 50, 'MATURE', 60, FALSE),
('prod0003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'KEYBOARD-001', 'Mechanical Keyboard', 'cat00002-0000-0000-0000-000000000002', 800, 500, 80, 30, 'GROWING', 85, FALSE);

-- Fashion
INSERT INTO product (product_id, tenant_id, sku, name, category_id, base_price, cost, stock_quantity, safety_stock, lifecycle_stage, trend_score, is_seasonal, season_code) VALUES
('prod0004-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', 'DRESS-001', 'Summer Dress', 'cat00004-0000-0000-0000-000000000004', 450, 200, 25, 50, 'MATURE', 65, TRUE, 'SUMMER'),
('prod0005-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', 'COAT-001', 'Winter Coat', 'cat00004-0000-0000-0000-000000000004', 1200, 600, 8, 20, 'DECLINING', 40, TRUE, 'WINTER'),
('prod0006-0000-0000-0000-000000000006', '22222222-2222-2222-2222-222222222222', 'SNEAKERS-001', 'Running Sneakers', 'cat00005-0000-0000-0000-000000000005', 800, 400, 60, 30, 'GROWING', 88, FALSE);

-- Beauty
INSERT INTO product (product_id, tenant_id, sku, name, category_id, brand, base_price, cost, stock_quantity, safety_stock, lifecycle_stage, trend_score, is_seasonal, season_code) VALUES
('prod0007-0000-0000-0000-000000000007', '33333333-3333-3333-3333-333333333333', 'MOIST-001', 'Hydrating Moisturizer', 'cat00007-0000-0000-0000-000000000007', 'GlowLab', 350, 150, 120, 50, 'MATURE', 85, TRUE, 'WINTER'),
('prod0008-0000-0000-0000-000000000008', '33333333-3333-3333-3333-333333333333', 'SERUM-001', 'Vitamin C Serum', 'cat00007-0000-0000-0000-000000000007', 'GlowLab', 450, 200, 85, 40, 'GROWING', 92, FALSE),
('prod0009-0000-0000-0000-000000000009', '33333333-3333-3333-3333-333333333333', 'LIPSTICK-001', 'Matte Lipstick', 'cat00008-0000-0000-0000-000000000008', 'ColorPro', 180, 80, 200, 80, 'MATURE', 70, FALSE);

-- Product Seasonality Rules
INSERT INTO product_seasonality_rule (tenant_id, product_id, rule_type, threshold_numeric, weight_score) VALUES
('33333333-3333-3333-3333-333333333333', 'prod0007-0000-0000-0000-000000000007', 'HIGH_HUMIDITY', 70, 80),
('33333333-3333-3333-3333-333333333333', 'prod0007-0000-0000-0000-000000000007', 'LOW_TEMP', 10, 75);

-- ============================================================================
-- SAMPLE CUSTOMERS
-- ============================================================================

INSERT INTO customer (customer_id, tenant_id, email, phone, birth_date, gender, city_id, is_active) VALUES
('cust0001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'ahmet@example.com', '+905551234567', '1990-05-15', 'M', 'c0000001-0000-0000-0000-000000000001', TRUE),
('cust0002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'ayse@example.com', '+905559876543', '1992-08-22', 'F', 'c0000001-0000-0000-0000-000000000001', TRUE),
('cust0003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'elif@example.com', '+905557778899', '1995-03-10', 'F', 'c0000001-0000-0000-0000-000000000001', TRUE);

-- ============================================================================
-- SAMPLE CUSTOMER PROFILES
-- ============================================================================

-- Budget Profiles
INSERT INTO customer_budget_profile (tenant_id, customer_id, predicted_monthly_budget, budget_tier, avg_order_value, spend_last_30, spend_last_90, price_sensitivity_score) VALUES
('22222222-2222-2222-2222-222222222222', 'cust0002-0000-0000-0000-000000000002', 1500, 'MID', 750, 450, 2250, 45),
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 1800, 'HIGH', 900, 900, 2700, 35);

-- Loyalty Profiles
INSERT INTO customer_loyalty_profile (tenant_id, customer_id, loyalty_tier, loyalty_score, lifetime_orders, lifetime_spent, days_since_last_order, reward_multiplier) VALUES
('22222222-2222-2222-2222-222222222222', 'cust0002-0000-0000-0000-000000000002', 'SILVER', 68, 5, 3750, 15, 1.2),
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 'GOLD', 85, 8, 7200, 7, 1.5);

-- Category Affinity
INSERT INTO customer_category_affinity (tenant_id, customer_id, category_id, affinity_score, orders_count, spend_total, last_purchased_at) VALUES
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 'cat00007-0000-0000-0000-000000000007', 95, 6, 2100, NOW() - INTERVAL '7 days'),
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 'cat00008-0000-0000-0000-000000000008', 72, 3, 540, NOW() - INTERVAL '20 days');

-- Replenishment Profile
INSERT INTO customer_replenishment_profile (tenant_id, customer_id, product_id, replenishment_cycle_days, is_recurring, last_purchased_at, previous_purchased_at, current_cycle_start, current_cycle_end, purchased_in_current_cycle, next_expected_purchase_at, confidence_score) VALUES
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 'prod0007-0000-0000-0000-000000000007', 30, TRUE, NOW() - INTERVAL '28 days', NOW() - INTERVAL '58 days', (NOW() - INTERVAL '28 days')::DATE, (NOW() + INTERVAL '2 days')::DATE, FALSE, NOW() + INTERVAL '2 days', 92);

-- Variety Profile
INSERT INTO customer_variety_profile (tenant_id, customer_id, variety_index, repeat_ratio, unique_sku_last_90, total_items_last_90, explorer_type) VALUES
('33333333-3333-3333-3333-333333333333', 'cust0003-0000-0000-0000-000000000003', 65, 35, 8, 12, 'BALANCED');

-- ============================================================================
-- SAMPLE CAMPAIGN
-- ============================================================================

INSERT INTO campaign (campaign_id, tenant_id, code, name, status, priority, start_at, end_at, strategic_goal, min_loyalty_tier, personalization_level) VALUES
('camp0001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'WINTER2024', 'Winter Skincare Special', 'ACTIVE', 10, NOW() - INTERVAL '7 days', NOW() + INTERVAL '30 days', 'SEASONAL_PROMOTION', 'SILVER', 'SEGMENT');

-- Campaign Condition Group
INSERT INTO campaign_condition_group (condition_group_id, tenant_id, campaign_id, group_type, logic_operator) VALUES
('cgrp0001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'camp0001-0000-0000-0000-000000000001', 'ELIGIBILITY', 'AND');

-- Campaign Conditions
INSERT INTO campaign_condition (tenant_id, condition_group_id, condition_type, value_text, category_id) VALUES
('33333333-3333-3333-3333-333333333333', 'cgrp0001-0000-0000-0000-000000000001', 'CUSTOMER_LOYALTY_TIER', 'SILVER,GOLD,PLATINUM', NULL),
('33333333-3333-3333-3333-333333333333', 'cgrp0001-0000-0000-0000-000000000001', 'CUSTOMER_CATEGORY_AFFINITY_MIN', NULL, 'cat00007-0000-0000-0000-000000000007');

-- Campaign Benefits
INSERT INTO campaign_benefit (tenant_id, campaign_id, benefit_type, value_numeric) VALUES
('33333333-3333-3333-3333-333333333333', 'camp0001-0000-0000-0000-000000000001', 'PERCENTAGE_DISCOUNT', 20),
('33333333-3333-3333-3333-333333333333', 'camp0001-0000-0000-0000-000000000001', 'FREE_SHIPPING', NULL);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON DATABASE postgres IS 'Campaign Intelligence System - AI-powered personalized campaign platform';
