-- Campaign Intelligence System - Database Schema
-- PostgreSQL 15+

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Tenant (Multi-tenancy)
CREATE TABLE tenant (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tenant_created_at ON tenant(created_at);

-- ============================================================================
-- GEOGRAPHY & CLIMATE
-- ============================================================================

-- City
CREATE TABLE city (
    city_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    country_code CHAR(2) NOT NULL,
    name TEXT NOT NULL,
    region_code TEXT,
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_city_tenant ON city(tenant_id);
CREATE INDEX idx_city_country ON city(country_code);

-- Geo Climate Monthly
CREATE TABLE geo_climate_monthly (
    climate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    city_id UUID NOT NULL REFERENCES city(city_id) ON DELETE CASCADE,
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    avg_temp_c NUMERIC(5, 2),
    rainfall_mm NUMERIC(8, 2),
    humidity_pct NUMERIC(5, 2),
    season_tag TEXT CHECK (season_tag IN ('WINTER', 'SPRING', 'SUMMER', 'FALL')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(city_id, month)
);

CREATE INDEX idx_climate_city ON geo_climate_monthly(city_id);
CREATE INDEX idx_climate_month ON geo_climate_monthly(month);

-- ============================================================================
-- CUSTOMER
-- ============================================================================

-- Customer
CREATE TABLE customer (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    email TEXT,
    phone TEXT,
    birth_date DATE,
    gender TEXT,
    city_id UUID REFERENCES city(city_id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_customer_tenant ON customer(tenant_id);
CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_customer_city ON customer(city_id);
CREATE INDEX idx_customer_active ON customer(is_active);

-- ============================================================================
-- PRODUCT & CATEGORY
-- ============================================================================

-- Category
CREATE TABLE category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_category_id UUID REFERENCES category(category_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_category_tenant ON category(tenant_id);
CREATE INDEX idx_category_parent ON category(parent_category_id);

-- Product
CREATE TABLE product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    sku TEXT NOT NULL,
    name TEXT NOT NULL,
    category_id UUID REFERENCES category(category_id) ON DELETE SET NULL,
    brand TEXT,
    base_price NUMERIC(18, 2) NOT NULL,
    cost NUMERIC(18, 2),
    currency_code CHAR(3) NOT NULL DEFAULT 'TRY',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    stock_quantity INT NOT NULL DEFAULT 0,
    reserved_quantity INT NOT NULL DEFAULT 0,
    safety_stock INT,
    lifecycle_stage TEXT CHECK (lifecycle_stage IN ('NEW', 'GROWING', 'MATURE', 'DECLINING')),
    trend_score NUMERIC(5, 2),
    is_seasonal BOOLEAN NOT NULL DEFAULT FALSE,
    season_code TEXT CHECK (season_code IN ('WINTER', 'SPRING', 'SUMMER', 'FALL')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, sku)
);

CREATE INDEX idx_product_tenant ON product(tenant_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_sku ON product(sku);
CREATE INDEX idx_product_lifecycle ON product(lifecycle_stage);
CREATE INDEX idx_product_seasonal ON product(is_seasonal, season_code);

-- Product Seasonality Rule
CREATE TABLE product_seasonality_rule (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    rule_type TEXT NOT NULL CHECK (rule_type IN ('HIGH_RAINFALL', 'LOW_TEMP', 'HIGH_HUMIDITY', 'SEASON_TAG')),
    threshold_numeric NUMERIC(10, 2),
    threshold_text TEXT,
    weight_score NUMERIC(5, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_seasonality_product ON product_seasonality_rule(product_id);
CREATE INDEX idx_seasonality_type ON product_seasonality_rule(rule_type);

-- ============================================================================
-- ORDERS & CART
-- ============================================================================

-- Order
CREATE TABLE "order" (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    order_number TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    total_amount NUMERIC(18, 2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'TRY',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, order_number)
);

CREATE INDEX idx_order_tenant ON "order"(tenant_id);
CREATE INDEX idx_order_customer ON "order"(customer_id);
CREATE INDEX idx_order_status ON "order"(status);
CREATE INDEX idx_order_created ON "order"(created_at);

-- Order Item
CREATE TABLE order_item (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES product(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price NUMERIC(18, 2) NOT NULL,
    discount_amount NUMERIC(18, 2) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_order_item_product ON order_item(product_id);

-- Cart
CREATE TABLE cart (
    cart_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'ABANDONED', 'CONVERTED')),
    total_amount NUMERIC(18, 2) NOT NULL DEFAULT 0,
    currency_code CHAR(3) NOT NULL DEFAULT 'TRY',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cart_tenant ON cart(tenant_id);
CREATE INDEX idx_cart_customer ON cart(customer_id);
CREATE INDEX idx_cart_status ON cart(status);

-- Cart Item
CREATE TABLE cart_item (
    cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    cart_id UUID NOT NULL REFERENCES cart(cart_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    price NUMERIC(18, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cart_item_cart ON cart_item(cart_id);
CREATE INDEX idx_cart_item_product ON cart_item(product_id);

-- ============================================================================
-- CUSTOMER PROFILES (AI Signals)
-- ============================================================================

-- Customer Budget Profile
CREATE TABLE customer_budget_profile (
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    predicted_monthly_budget NUMERIC(18, 2),
    budget_tier TEXT CHECK (budget_tier IN ('LOW', 'MID', 'HIGH', 'PREMIUM')),
    avg_order_value NUMERIC(18, 2),
    spend_last_30 NUMERIC(18, 2),
    spend_last_90 NUMERIC(18, 2),
    price_sensitivity_score NUMERIC(5, 2) CHECK (price_sensitivity_score BETWEEN 0 AND 100),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, customer_id)
);

CREATE INDEX idx_budget_profile_tier ON customer_budget_profile(budget_tier);
CREATE INDEX idx_budget_profile_updated ON customer_budget_profile(updated_at);

-- Customer Loyalty Profile
CREATE TABLE customer_loyalty_profile (
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    loyalty_tier TEXT NOT NULL CHECK (loyalty_tier IN ('NEW', 'BRONZE', 'SILVER', 'GOLD', 'PLATINUM')),
    loyalty_score NUMERIC(5, 2) CHECK (loyalty_score BETWEEN 0 AND 100),
    lifetime_orders INT NOT NULL DEFAULT 0,
    lifetime_spent NUMERIC(18, 2) NOT NULL DEFAULT 0,
    days_since_last_order INT,
    reward_multiplier NUMERIC(5, 2) DEFAULT 1.0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, customer_id)
);

CREATE INDEX idx_loyalty_profile_tier ON customer_loyalty_profile(loyalty_tier);
CREATE INDEX idx_loyalty_profile_score ON customer_loyalty_profile(loyalty_score);

-- Customer Category Affinity
CREATE TABLE customer_category_affinity (
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES category(category_id) ON DELETE CASCADE,
    affinity_score NUMERIC(5, 2) CHECK (affinity_score BETWEEN 0 AND 100),
    orders_count INT NOT NULL DEFAULT 0,
    spend_total NUMERIC(18, 2) NOT NULL DEFAULT 0,
    last_purchased_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, customer_id, category_id)
);

CREATE INDEX idx_category_affinity_score ON customer_category_affinity(affinity_score DESC);
CREATE INDEX idx_category_affinity_customer ON customer_category_affinity(customer_id);

-- Customer Replenishment Profile
CREATE TABLE customer_replenishment_profile (
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    replenishment_cycle_days INT,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    last_purchased_at TIMESTAMPTZ,
    previous_purchased_at TIMESTAMPTZ,
    current_cycle_start DATE,
    current_cycle_end DATE,
    purchased_in_current_cycle BOOLEAN NOT NULL DEFAULT FALSE,
    next_expected_purchase_at TIMESTAMPTZ,
    confidence_score NUMERIC(5, 2) CHECK (confidence_score BETWEEN 0 AND 100),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, customer_id, product_id)
);

CREATE INDEX idx_replenishment_customer ON customer_replenishment_profile(customer_id);
CREATE INDEX idx_replenishment_next_expected ON customer_replenishment_profile(next_expected_purchase_at);
CREATE INDEX idx_replenishment_cycle_status ON customer_replenishment_profile(purchased_in_current_cycle);

-- Customer Variety Profile
CREATE TABLE customer_variety_profile (
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    variety_index NUMERIC(5, 2) CHECK (variety_index BETWEEN 0 AND 100),
    repeat_ratio NUMERIC(5, 2) CHECK (repeat_ratio BETWEEN 0 AND 100),
    unique_sku_last_90 INT,
    total_items_last_90 INT,
    explorer_type TEXT CHECK (explorer_type IN ('EXPLORER', 'BALANCED', 'REPEAT_BUYER')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, customer_id)
);

CREATE INDEX idx_variety_profile_type ON customer_variety_profile(explorer_type);
CREATE INDEX idx_variety_profile_index ON customer_variety_profile(variety_index);

-- ============================================================================
-- CAMPAIGN
-- ============================================================================

-- Campaign
CREATE TABLE campaign (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED')),
    priority INT NOT NULL DEFAULT 0,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    strategic_goal TEXT CHECK (strategic_goal IN ('STOCK_CLEARANCE', 'AOV_INCREASE', 'LOYALTY_REWARD', 'CUSTOMER_ACQUISITION', 'SEASONAL_PROMOTION')),
    min_loyalty_tier TEXT CHECK (min_loyalty_tier IN ('NEW', 'BRONZE', 'SILVER', 'GOLD', 'PLATINUM')),
    max_budget_tier TEXT CHECK (max_budget_tier IN ('LOW', 'MID', 'HIGH', 'PREMIUM')),
    personalization_level TEXT CHECK (personalization_level IN ('GENERIC', 'SEGMENT', 'PERSONAL')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, code)
);

CREATE INDEX idx_campaign_tenant ON campaign(tenant_id);
CREATE INDEX idx_campaign_status ON campaign(status);
CREATE INDEX idx_campaign_dates ON campaign(start_at, end_at);
CREATE INDEX idx_campaign_goal ON campaign(strategic_goal);

-- Campaign Condition Group
CREATE TABLE campaign_condition_group (
    condition_group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    campaign_id UUID NOT NULL REFERENCES campaign(campaign_id) ON DELETE CASCADE,
    group_type TEXT NOT NULL CHECK (group_type IN ('ELIGIBILITY', 'TRIGGER')),
    logic_operator TEXT NOT NULL DEFAULT 'AND' CHECK (logic_operator IN ('AND', 'OR')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_condition_group_campaign ON campaign_condition_group(campaign_id);

-- Campaign Condition
CREATE TABLE campaign_condition (
    condition_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    condition_group_id UUID NOT NULL REFERENCES campaign_condition_group(condition_group_id) ON DELETE CASCADE,
    condition_type TEXT NOT NULL,
    value_numeric NUMERIC(18, 2),
    value_text TEXT,
    value_bool BOOLEAN,
    product_id UUID REFERENCES product(product_id) ON DELETE CASCADE,
    category_id UUID REFERENCES category(category_id) ON DELETE CASCADE,
    lookback_days INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_condition_group ON campaign_condition(condition_group_id);
CREATE INDEX idx_condition_type ON campaign_condition(condition_type);

COMMENT ON COLUMN campaign_condition.condition_type IS 'Types: CUSTOMER_AGE_RANGE, CUSTOMER_CITY, CUSTOMER_BUDGET_TIER, CUSTOMER_LOYALTY_TIER, CUSTOMER_CATEGORY_AFFINITY_MIN, EXCLUDE_REPLENISHED_PRODUCTS, INCLUDE_REPLENISHMENT_GAP_PRODUCTS, GEO_CLIMATE_RULE_MATCH, CART_TOTAL_MIN, CART_TOTAL_MAX, etc.';

-- Campaign Benefit
CREATE TABLE campaign_benefit (
    benefit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    campaign_id UUID NOT NULL REFERENCES campaign(campaign_id) ON DELETE CASCADE,
    benefit_type TEXT NOT NULL CHECK (benefit_type IN ('PERCENTAGE_DISCOUNT', 'FIXED_DISCOUNT', 'FREE_SHIPPING', 'FREE_PRODUCT', 'LOYALTY_POINTS')),
    value_numeric NUMERIC(18, 2),
    value_text TEXT,
    product_id UUID REFERENCES product(product_id) ON DELETE SET NULL,
    max_usage_per_customer INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_benefit_campaign ON campaign_benefit(campaign_id);
CREATE INDEX idx_benefit_type ON campaign_benefit(benefit_type);

-- ============================================================================
-- AI DECISION TRACE
-- ============================================================================

-- AI Generation Run
CREATE TABLE ai_generation_run (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    run_type TEXT NOT NULL CHECK (run_type IN ('COMPANY_CAMPAIGN', 'PERSONAL_CAMPAIGN', 'CAMPAIGN_EVALUATION')),
    input_data JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'RUNNING' CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED')),
    error_message TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_ai_run_tenant ON ai_generation_run(tenant_id);
CREATE INDEX idx_ai_run_type ON ai_generation_run(run_type);
CREATE INDEX idx_ai_run_status ON ai_generation_run(status);
CREATE INDEX idx_ai_run_started ON ai_generation_run(started_at);

-- AI Decision Log
CREATE TABLE ai_decision_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    run_id UUID NOT NULL REFERENCES ai_generation_run(run_id) ON DELETE CASCADE,
    agent_name TEXT NOT NULL,
    decision_type TEXT NOT NULL,
    input_signals JSONB,
    output_decision JSONB,
    reasoning TEXT,
    confidence_score NUMERIC(5, 2) CHECK (confidence_score BETWEEN 0 AND 100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_decision_log_run ON ai_decision_log(run_id);
CREATE INDEX idx_decision_log_agent ON ai_decision_log(agent_name);
CREATE INDEX idx_decision_log_created ON ai_decision_log(created_at);

-- Campaign Proposal
CREATE TABLE campaign_proposal (
    proposal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    run_id UUID NOT NULL REFERENCES ai_generation_run(run_id) ON DELETE CASCADE,
    proposal_name TEXT NOT NULL,
    proposal_type TEXT NOT NULL,
    target_profile JSONB,
    product_selection JSONB,
    expected_roi NUMERIC(5, 2),
    risk_level TEXT CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    reasoning TEXT,
    confidence_score NUMERIC(5, 2) CHECK (confidence_score BETWEEN 0 AND 100),
    status TEXT NOT NULL DEFAULT 'PROPOSED' CHECK (status IN ('PROPOSED', 'APPROVED', 'REJECTED', 'IMPLEMENTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_proposal_run ON campaign_proposal(run_id);
CREATE INDEX idx_proposal_status ON campaign_proposal(status);
CREATE INDEX idx_proposal_confidence ON campaign_proposal(confidence_score);

-- Campaign Evaluation
CREATE TABLE campaign_evaluation (
    evaluation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    campaign_id UUID NOT NULL REFERENCES campaign(campaign_id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customer(customer_id) ON DELETE CASCADE,
    cart_id UUID REFERENCES cart(cart_id) ON DELETE SET NULL,
    is_eligible BOOLEAN NOT NULL,
    gap_analysis JSONB,
    recommendation JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_evaluation_campaign ON campaign_evaluation(campaign_id);
CREATE INDEX idx_evaluation_customer ON campaign_evaluation(customer_id);
CREATE INDEX idx_evaluation_eligible ON campaign_evaluation(is_eligible);

-- Campaign Redemption
CREATE TABLE campaign_redemption (
    redemption_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id) ON DELETE CASCADE,
    campaign_id UUID NOT NULL REFERENCES campaign(campaign_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    order_id UUID REFERENCES "order"(order_id) ON DELETE SET NULL,
    discount_amount NUMERIC(18, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_redemption_campaign ON campaign_redemption(campaign_id);
CREATE INDEX idx_redemption_customer ON campaign_redemption(customer_id);
CREATE INDEX idx_redemption_order ON campaign_redemption(order_id);
CREATE INDEX idx_redemption_created ON campaign_redemption(created_at);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tenant_updated_at BEFORE UPDATE ON tenant
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customer_updated_at BEFORE UPDATE ON customer
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_updated_at BEFORE UPDATE ON product
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_updated_at BEFORE UPDATE ON "order"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_updated_at BEFORE UPDATE ON cart
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_item_updated_at BEFORE UPDATE ON cart_item
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_updated_at BEFORE UPDATE ON campaign
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE customer_budget_profile IS 'AI Signal 1: Budget Estimation - Customer spending capacity and price sensitivity';
COMMENT ON TABLE customer_loyalty_profile IS 'AI Signal 3: Loyalty - Customer lifetime value and reward tier';
COMMENT ON TABLE customer_category_affinity IS 'AI Signal 4: Category Affinity - Customer preference for product categories';
COMMENT ON TABLE customer_replenishment_profile IS 'AI Signal 5: Replenishment - Recurring purchase patterns';
COMMENT ON TABLE customer_variety_profile IS 'AI Signal 6: Variety vs Repeat - Explorer or repeat buyer behavior';
COMMENT ON TABLE geo_climate_monthly IS 'AI Signal 2: Geo/Seasonal - Climate data for seasonal product matching';
