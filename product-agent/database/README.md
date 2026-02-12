# Database Schema

Campaign Intelligence System için PostgreSQL database schema'sı.

## Gereksinimler

- PostgreSQL 15+
- UUID extension (genellikle varsayılan olarak gelir)

## Kurulum

### 1. Database Oluşturma

```bash
# PostgreSQL'e bağlan
psql -U postgres

# Database oluştur
CREATE DATABASE campaign_intelligence;

# Database'e geç
\c campaign_intelligence
```

### 2. Schema Yükleme

```bash
# Schema'yı yükle
psql -U postgres -d campaign_intelligence -f schema.sql

# Seed data'yı yükle (opsiyonel)
psql -U postgres -d campaign_intelligence -f seed.sql
```

## Schema Yapısı

### Veri Katmanları

#### 1. Core Tables
- `tenant` - Multi-tenancy
- `city` - Şehir bilgileri
- `geo_climate_monthly` - Aylık iklim verileri
- `customer` - Müşteri bilgileri
- `category` - Ürün kategorileri
- `product` - Ürün bilgileri
- `product_seasonality_rule` - Ürün-iklim eşleştirme kuralları

#### 2. Transactional Tables
- `order` - Siparişler
- `order_item` - Sipariş kalemleri
- `cart` - Sepetler
- `cart_item` - Sepet kalemleri

#### 3. Profile & Signals (AI Input)
- `customer_budget_profile` - Budget estimation (AI Signal 1)
- `customer_loyalty_profile` - Loyalty tier (AI Signal 3)
- `customer_category_affinity` - Category preferences (AI Signal 4)
- `customer_replenishment_profile` - Replenishment patterns (AI Signal 5)
- `customer_variety_profile` - Explorer vs Repeat (AI Signal 6)

#### 4. Campaign Tables
- `campaign` - Kampanya tanımları
- `campaign_condition_group` - Koşul grupları
- `campaign_condition` - Kampanya koşulları
- `campaign_benefit` - Kampanya faydaları
- `campaign_redemption` - Kampanya kullanımları

#### 5. Decision Trace (AI Output)
- `ai_generation_run` - AI çalıştırma kayıtları
- `ai_decision_log` - AI karar logları
- `campaign_proposal` - Kampanya önerileri
- `campaign_evaluation` - Kampanya değerlendirmeleri

## Önemli İndeksler

### Performance İndeksleri
```sql
-- Customer lookup
idx_customer_tenant, idx_customer_email, idx_customer_city

-- Product lookup
idx_product_tenant, idx_product_category, idx_product_sku

-- Order queries
idx_order_customer, idx_order_created, idx_order_status

-- Profile queries
idx_budget_profile_tier, idx_loyalty_profile_tier
idx_category_affinity_score, idx_replenishment_next_expected

-- Campaign queries
idx_campaign_status, idx_campaign_dates, idx_campaign_goal
```

## Condition Types

Campaign condition tablosunda kullanılabilecek condition_type değerleri:

### Customer-based
- `CUSTOMER_AGE_RANGE` - Yaş aralığı
- `CUSTOMER_CITY` - Şehir
- `CUSTOMER_BUDGET_TIER` - Budget seviyesi
- `CUSTOMER_LOYALTY_TIER` - Sadakat seviyesi
- `CUSTOMER_CATEGORY_AFFINITY_MIN` - Minimum kategori eğilimi

### Product-based
- `EXCLUDE_REPLENISHED_PRODUCTS` - Döneminde alınan ürünleri hariç tut
- `INCLUDE_REPLENISHMENT_GAP_PRODUCTS` - Döneminde alınmayan ürünleri dahil et
- `GEO_CLIMATE_RULE_MATCH` - İklim kuralı eşleşmesi

### Cart-based
- `CART_TOTAL_MIN` - Minimum sepet tutarı
- `CART_TOTAL_MAX` - Maximum sepet tutarı
- `CART_ITEM_COUNT_MIN` - Minimum ürün sayısı

## Trigger'lar

Otomatik `updated_at` güncellemesi için trigger'lar:
- `update_tenant_updated_at`
- `update_customer_updated_at`
- `update_product_updated_at`
- `update_order_updated_at`
- `update_cart_updated_at`
- `update_campaign_updated_at`

## Örnek Sorgular

### 1. Müşteri Profil Özeti

```sql
SELECT 
    c.customer_id,
    c.email,
    c.birth_date,
    ci.name as city,
    bp.budget_tier,
    bp.predicted_monthly_budget,
    lp.loyalty_tier,
    lp.loyalty_score,
    vp.explorer_type
FROM customer c
LEFT JOIN city ci ON c.city_id = ci.city_id
LEFT JOIN customer_budget_profile bp ON c.customer_id = bp.customer_id
LEFT JOIN customer_loyalty_profile lp ON c.customer_id = lp.customer_id
LEFT JOIN customer_variety_profile vp ON c.customer_id = vp.customer_id
WHERE c.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND c.is_active = TRUE;
```

### 2. Replenishment Gap Analizi

```sql
SELECT 
    c.email,
    p.name as product_name,
    rp.replenishment_cycle_days,
    rp.last_purchased_at,
    rp.next_expected_purchase_at,
    CASE 
        WHEN rp.next_expected_purchase_at < NOW() 
        THEN EXTRACT(DAY FROM NOW() - rp.next_expected_purchase_at)
        ELSE 0 
    END as days_overdue
FROM customer_replenishment_profile rp
JOIN customer c ON rp.customer_id = c.customer_id
JOIN product p ON rp.product_id = p.product_id
WHERE rp.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND rp.is_recurring = TRUE
    AND rp.purchased_in_current_cycle = FALSE
    AND rp.next_expected_purchase_at < NOW()
ORDER BY days_overdue DESC;
```

### 3. Kategori Affinity Top 5

```sql
SELECT 
    c.email,
    cat.name as category_name,
    ca.affinity_score,
    ca.orders_count,
    ca.spend_total
FROM customer_category_affinity ca
JOIN customer c ON ca.customer_id = c.customer_id
JOIN category cat ON ca.category_id = cat.category_id
WHERE ca.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND ca.customer_id = 'cust0003-0000-0000-0000-000000000003'
ORDER BY ca.affinity_score DESC
LIMIT 5;
```

### 4. Aktif Kampanyalar ve Koşulları

```sql
SELECT 
    c.name as campaign_name,
    c.status,
    c.strategic_goal,
    c.start_at,
    c.end_at,
    cc.condition_type,
    cc.value_text,
    cc.value_numeric
FROM campaign c
JOIN campaign_condition_group cg ON c.campaign_id = cg.campaign_id
JOIN campaign_condition cc ON cg.condition_group_id = cc.condition_group_id
WHERE c.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND c.status = 'ACTIVE'
    AND NOW() BETWEEN c.start_at AND c.end_at;
```

### 5. Stok Baskısı Olan Ürünler

```sql
SELECT 
    p.name,
    p.sku,
    p.stock_quantity,
    p.safety_stock,
    p.lifecycle_stage,
    p.trend_score,
    (p.stock_quantity - p.safety_stock) as stock_pressure
FROM product p
WHERE p.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND p.is_active = TRUE
    AND p.stock_quantity < p.safety_stock
ORDER BY stock_pressure ASC;
```

### 6. Mevsimsel Ürün Eşleştirme

```sql
SELECT 
    p.name as product_name,
    p.season_code,
    ci.name as city_name,
    gcm.season_tag,
    gcm.avg_temp_c,
    gcm.rainfall_mm,
    psr.rule_type,
    psr.weight_score
FROM product p
JOIN product_seasonality_rule psr ON p.product_id = psr.product_id
CROSS JOIN city ci
JOIN geo_climate_monthly gcm ON ci.city_id = gcm.city_id
WHERE p.tenant_id = '11111111-1111-1111-1111-111111111111'
    AND gcm.month = EXTRACT(MONTH FROM NOW())
    AND (
        (psr.rule_type = 'HIGH_HUMIDITY' AND gcm.humidity_pct > psr.threshold_numeric)
        OR (psr.rule_type = 'LOW_TEMP' AND gcm.avg_temp_c < psr.threshold_numeric)
        OR (psr.rule_type = 'HIGH_RAINFALL' AND gcm.rainfall_mm > psr.threshold_numeric)
    );
```

## Bakım

### Vacuum ve Analyze

```sql
-- Tüm tabloları optimize et
VACUUM ANALYZE;

-- Belirli tabloları optimize et
VACUUM ANALYZE customer;
VACUUM ANALYZE "order";
VACUUM ANALYZE order_item;
```

### İndeks Yeniden Oluşturma

```sql
-- İndeks istatistiklerini güncelle
REINDEX TABLE customer;
REINDEX TABLE "order";
```

## Migration Stratejisi

Yeni sütun veya tablo eklerken:

1. Migration dosyası oluştur: `migrations/001_add_feature.sql`
2. Rollback dosyası oluştur: `migrations/001_add_feature_rollback.sql`
3. Test ortamında test et
4. Production'a uygula

## Performans İpuçları

1. **Partitioning**: `order` ve `order_item` tablolarını tarih bazlı partition'la
2. **Archiving**: Eski siparişleri archive tablosuna taşı
3. **Materialized Views**: Sık kullanılan profil sorguları için
4. **Connection Pooling**: PgBouncer kullan
5. **Read Replicas**: Raporlama sorguları için

## Güvenlik

### Row Level Security (RLS)

```sql
-- Tenant bazlı RLS
ALTER TABLE customer ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON customer
    USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

### Roller

```sql
-- Read-only role
CREATE ROLE campaign_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO campaign_readonly;

-- Application role
CREATE ROLE campaign_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO campaign_app;
```
