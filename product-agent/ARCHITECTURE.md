# Campaign Intelligence System - Mimari Doküman

## Genel Bakış

Kullanıcı bazlı kişiselleştirilmiş kampanya üretimi yapan AI destekli bir sistem. Hem şirket seviyesinde (admin) hem de müşteri seviyesinde kampanya kararları üretir.

## Temel Prensipler

### Veri Katmanları

1. **Raw Transactional**: order, cart, product (ham işlem verileri)
2. **Profile & Signals**: Müşteri profil tabloları (budget, loyalty, affinity, vb.)
3. **Decision Trace**: AI karar kayıtları ve kampanya önerileri

### Mimari Avantajlar

- LLM'e temiz, gürültüsüz feature set
- Explainability (neden bu karar verildi?)
- Performans (önceden hesaplanmış profiller)

---

## AI Karar Eksenleri (6 Temel Sinyal)

### 1. Budget Estimation
**Kaynak**: `customer_budget_profile`
- Müşterinin aylık harcama tahmini
- Budget tier (LOW/MID/HIGH/PREMIUM)
- Fiyat hassasiyeti skoru

**Kullanım**: Kampanya fiyat limitlerini belirle, budget tier'a göre farklı teklifler

### 2. Demographic + Geo/Seasonal
**Kaynak**: `customer` (age, city), `geo_climate_monthly`, `product_seasonality_rule`
- Yaş, şehir, mevsim/iklim verileri
- Şehir bazlı iklim sinyalleri (yağış, sıcaklık)
- Ürün-iklim eşleştirme kuralları

**Kullanım**: Mevsimsel ürün önerileri (örn: yağışlı bölgede şemsiye/bot)

### 3. Loyalty
**Kaynak**: `customer_loyalty_profile`
- Sadakat seviyesi (NEW/BRONZE/SILVER/GOLD/PLATINUM)
- Lifetime değer, sipariş sayısı
- Reward çarpanı

**Kullanım**: Sadakat seviyesine göre farklı ödül oranları

### 4. Category Affinity
**Kaynak**: `customer_category_affinity`
- Kategori bazlı eğilim skoru
- Geçmiş harcama ve sipariş sayısı

**Kullanım**: Müşterinin ilgi duyduğu kategorilerden ürün öner

### 5. Replenishment (Dönemsel Alışveriş)
**Kaynak**: `customer_replenishment_profile`
- Düzenli alınan ürünler
- Alım döngüsü (30/60/90 gün)
- Bu dönemde alındı mı?

**Kullanım**: 
- Zaten alındıysa exclude et
- Alınmadıysa "restock nudge" kampanyası

### 6. Variety vs Repeat
**Kaynak**: `customer_variety_profile`
- Variety index (yeni ürün deneme eğilimi)
- Repeat ratio (tekrar alım oranı)
- Explorer type (EXPLORER/BALANCED/REPEAT_BUYER)

**Kullanım**:
- EXPLORER: Yeni kategori/marka öner
- REPEAT_BUYER: Favori ürünler + bundle

---

## Veri Modeli (Özet)

### Tenant & Geo
```
tenant (multi-tenancy)
city (şehir bilgisi)
geo_climate_monthly (aylık iklim verileri)
```

### Customer & Profiles
```
customer (temel bilgiler + city_id)
customer_budget_profile
customer_loyalty_profile
customer_category_affinity
customer_replenishment_profile
customer_variety_profile
```

### Product
```
product (+ seasonality fields)
product_seasonality_rule (iklim bazlı relevance)
category
```

### Campaign
```
campaign (+ min_loyalty_tier, max_budget_tier, personalization_level)
campaign_condition_group
campaign_condition (+ yeni condition_type'lar)
campaign_benefit
```

### Decision Trace
```
ai_generation_run
ai_decision_log
campaign_proposal
campaign_evaluation
```

---

## Yeni Campaign Condition Types

```
CUSTOMER_AGE_RANGE
CUSTOMER_CITY
CUSTOMER_BUDGET_TIER
CUSTOMER_LOYALTY_TIER
CUSTOMER_CATEGORY_AFFINITY_MIN
EXCLUDE_REPLENISHED_PRODUCTS
INCLUDE_REPLENISHMENT_GAP_PRODUCTS
GEO_CLIMATE_RULE_MATCH
```

---

## İş Akışları

### A) Company/Admin - AI ile Kampanya Oluşturma

**Input**:
- Goal: STOCK_CLEARANCE / LOYALTY_REWARD / AOV_INCREASE
- Constraints: budget, maxDiscount, dateRange
- Target: age range, cities, loyalty tier (opsiyonel)

**AI Agent Pipeline**:
1. **Product Analyst**: Stok analizi, seasonal relevance
2. **Profit & Risk**: Marj kontrolü, risk değerlendirmesi
3. **Strategist**: Kampanya tipi seçimi (bundle/gift/threshold)
4. **Supervisor**: Final proposals (3-5 adet) + reasoning

**Output**:
- Kampanya önerileri
- Her öneri için: target profile, product set, expected ROI, risk

**Persist**: `ai_generation_run`, `campaign_proposal`, `ai_decision_log`

### B) Customer - "Bana Özel Kampanya"

**Input**: customerId + cartId

**Signal Toplama**:
- 6 profil tablosundan veri çek
- Şehir iklim verisi
- Mevcut sepet analizi

**AI Output**:
- Kişiselleştirilmiş kampanya önerisi
- Açıklama (neden bu kampanya?)
- Önerilen ek ürünler:
  - Replenishment gap ürünleri
  - Seasonal relevance ürünleri
  - Category affinity ürünleri

### C) Customer - "Hangi Kampanyalara Yakınım?"

**Deterministic Evaluation**:
- Aktif kampanyaları değerlendir
- Gap hesapla (+amount / +product / +category)

**AI Enhancement**:
- Açıklamaları kullanıcı diline çevir
- One-click add önerileri

---

## Teknik Detaylar

### İlişkiler
- 1 Tenant → N Product, N Customer, N Campaign
- Customer → Orders → OrderItems
- Customer → 6 Profile Table
- Customer → City → GeoClimateMonthly
- Product → ProductSeasonalityRule
- Campaign → ConditionGroup → Conditions → Benefits

### Profile Tabloları Güncelleme
- Batch job ile periyodik güncelleme
- Order/cart event'lerinde incremental update
- Real-time scoring için cache layer

---

## Hackathon Vitrin Önerileri

### Decision Trace UI
Müşteri için 6 sinyali görselleştir:
1. Budget Tier + predicted monthly budget
2. Loyalty Tier + reward multiplier
3. Top 3 Category Affinity
4. Replenishment: Bu ay alınmayan düzenli ürünler
5. Variety Type (Explorer/Repeat)
6. City Climate + matched seasonal products

### Explainability
Her kampanya önerisinde:
- Hangi sinyaller kullanıldı?
- Neden bu ürünler seçildi?
- Risk/confidence skorları

---

## Sonraki Adımlar

1. Profile tablolarını doldurmak için batch job implementasyonu
2. Agent'lara verilecek CustomerSignals DTO tasarımı
3. Campaign condition evaluation engine
4. AI agent orchestration pipeline
5. Real-time personalization API
