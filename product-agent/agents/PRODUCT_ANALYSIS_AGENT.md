# Ürün Analiz Ajanı Dökümanı

## Sorumluluk

Ürün Analiz Ajanı, ürün verilerini analiz eder ve segmentasyon yapar. **Müşteri analizi yapmaz, kampanya kararı almaz** — sadece ürün profili ve stok durumu çıkarır.

---

## Girdi

```json
{
  "tenantId": "farmasi",
  "products": [
    {
      "productId": "1002705",
      "productName": "Infinilash Maskara 9 ml",
      "category": "MAKEUP",
      "subcategory": "Maskara",
      "brand": "Farmasi",
      "season": "all",
      "isSeasonal": false,
      "seasonCode": "all",
      "stock": 450,
      "currentStock": 450,
      "last30DaysSales": 180,
      "cost": 45.00,
      "unitCost": 45.00,
      "basePrice": 89.90,
      "unitPrice": 89.90,
      "lifecycleStage": "MATURE",
      "trendScore": 82,
      "tags": ["maskara", "hacim"],
      "seasonalityRules": []
    }
  ],
  "orderHistory": [ /* son 90 günlük sipariş geçmişi */ ],
  "currentSeason": "winter",
  "currentMonth": 2,
  "climateData": { /* şehir bazlı iklim verileri */ }
}
```

---

## Çıktı (ProductInsightJSON)

```json
{
  "heroProducts": [
    {
      "productId": "prod-z-001",
      "productName": "Hydrating Moisturizer",
      "category": "Skincare",
      "brand": "GlowLab",
      "performanceSegment": "Star",
      "stockSegment": "Critical",
      "lifecycleStage": "MATURE",
      "trendScore": 85,
      "stockDays": 8,
      "dailySalesRate": 15.0,
      "inventoryPressure": false,
      "seasonalRelevance": "HIGH",
      "seasonMatch": true,
      "priceSegment": "MID",
      "marginHealth": "GOOD",
      "recommendedAction": "PROMOTE",
      "urgencyLevel": "HIGH"
    }
  ],
  "slowMovers": [
    {
      "productId": "prod-z-005",
      "productName": "SPF 50 Sunscreen",
      "category": "Skincare",
      "brand": "SunGuard",
      "performanceSegment": "Underperformer",
      "stockSegment": "Excess",
      "lifecycleStage": "DECLINING",
      "trendScore": 30,
      "stockDays": 95,
      "dailySalesRate": 0.5,
      "inventoryPressure": true,
      "seasonalRelevance": "LOW",
      "seasonMatch": false,
      "priceSegment": "MID",
      "marginHealth": "POOR",
      "recommendedAction": "CLEARANCE",
      "urgencyLevel": "CRITICAL"
    }
  ],
  "newProducts": [
    {
      "productId": "prod-z-011",
      "productName": "Niacinamide Serum",
      "category": "Skincare",
      "brand": "GlowLab",
      "performanceSegment": "Rising",
      "lifecycleStage": "NEW",
      "trendScore": 95,
      "stockDays": 45,
      "dailySalesRate": 2.2,
      "recommendedAction": "FEATURE",
      "urgencyLevel": "MEDIUM"
    }
  ],
  "seasonalProducts": [
    {
      "productId": "prod-z-001",
      "productName": "Hydrating Moisturizer",
      "seasonalRelevance": "HIGH",
      "climateMatch": ["HIGH_HUMIDITY", "LOW_TEMP"],
      "matchingCities": ["İstanbul", "Bursa"],
      "recommendedAction": "SEASONAL_PUSH"
    }
  ],
  "categoryInsights": {
    "Skincare": {
      "totalProducts": 14,
      "avgTrendScore": 78.5,
      "totalStock": 1450,
      "avgStockDays": 32,
      "performanceRating": "STRONG",
      "topPerformers": 5,
      "underperformers": 2
    },
    "Makeup": {
      "totalProducts": 13,
      "avgTrendScore": 72.3,
      "totalStock": 2100,
      "avgStockDays": 45,
      "performanceRating": "MODERATE",
      "topPerformers": 3,
      "underperformers": 4
    }
  },
  "priceSegmentAnalysis": {
    "BUDGET": {
      "priceRange": "0-200 TL",
      "productCount": 15,
      "avgTrendScore": 68,
      "stockHealth": "GOOD"
    },
    "MID": {
      "priceRange": "200-500 TL",
      "productCount": 32,
      "avgTrendScore": 75,
      "stockHealth": "MODERATE"
    },
    "PREMIUM": {
      "priceRange": "500+ TL",
      "productCount": 16,
      "avgTrendScore": 82,
      "stockHealth": "GOOD"
    }
  },
  "inventorySummary": {
    "totalProducts": 63,
    "totalStockValue": 125000,
    "criticalStockProducts": 8,
    "excessStockProducts": 12,
    "healthyStockProducts": 43,
    "avgStockDays": 38,
    "inventoryTurnoverRate": 9.6
  }
}
```

---

## Segmentasyon Tabloları

### Performance Segment (Performans Segmenti)

| Segment | Koşul | Profil | Kampanya Yaklaşımı |
|---|---|---|---|
| Star | trendScore > 80 && stockDays < 30 | Yüksek talep, hızlı satış | Öne çıkar, premium paketlerde kullan, stok artır |
| Rising | lifecycleStage = NEW && trendScore > 85 | Yeni ürün, yüksek potansiyel | Feature kampanyaları, deneme teşviki, influencer |
| Steady | 60 < trendScore ≤ 80 && stockDays < 60 | İstikrarlı satış | Standart kampanyalarda kullan, çapraz satış |
| Underperformer | trendScore < 60 \|\| stockDays > 60 | Düşük talep veya stok baskısı | İndirim, bundle, clearance |

### Stock Segment (Stok Segmenti)

| Segment | Koşul | Durum | Aksiyon |
|---|---|---|---|
| Critical | stockDays < 15 | Stok tükeniyor | Acil tedarik, stok artır, promosyonu azalt |
| Healthy | 15 ≤ stockDays ≤ 60 | Optimal stok seviyesi | Normal kampanya akışı |
| Excess | stockDays > 60 | Stok baskısı | Clearance, agresif indirim, bundle |

### Lifecycle Stage (Yaşam Döngüsü)

| Stage | Özellikler | Kampanya Stratejisi |
|---|---|---|
| NEW | Yeni piyasaya sürüldü, < 3 ay | Tanıtım kampanyaları, deneme teşviki, influencer işbirlikleri |
| GROWING | Satışlar artıyor, trend yükseliyor | Feature kampanyaları, stok artırımı, kategori lideri pozisyonu |
| MATURE | İstikrarlı satış, pazar payı sabit | Standart kampanyalar, sadakat programları, çapraz satış |
| DECLINING | Satışlar düşüyor, trend azalıyor | Clearance, bundle, yeni ürünle değiştirme |

### Price Segment (Fiyat Segmenti)

| Segment | Fiyat Aralığı | Hedef Müşteri | Kampanya Yaklaşımı |
|---|---|---|---|
| BUDGET | 0-200 TL | Fiyat hassas, GenZ, yeni müşteri | Miktar indirimi, 2+1, giriş seviyesi paketler |
| MID | 200-500 TL | Orta gelir, kalite-fiyat dengesi | Standart indirimler, bundle, sadakat bonusu |
| PREMIUM | 500+ TL | Yüksek gelir, kalite odaklı | Düşük indirim, özel paketler, VIP erişim |

### Margin Health (Marj Sağlığı)

| Health | Koşul | Durum | Kampanya Kısıtı |
|---|---|---|---|
| EXCELLENT | margin > 60% | Çok yüksek marj | Agresif indirim yapılabilir (%30+) |
| GOOD | 40% < margin ≤ 60% | Sağlıklı marj | Orta indirim (%15-25) |
| MODERATE | 25% < margin ≤ 40% | Kabul edilebilir marj | Düşük indirim (%10-15) |
| POOR | margin ≤ 25% | Düşük marj | Minimal indirim (%5-10), bundle tercih et |

### Seasonal Relevance (Mevsimsel Uygunluk)

| Relevance | Koşul | Kampanya Etkisi |
|---|---|---|
| HIGH | seasonMatch = true && climate rules match | Mevsimsel kampanyalarda öncelikli, coğrafi hedefleme |
| MEDIUM | seasonCode = "all" \|\| partial match | Genel kampanyalarda kullan |
| LOW | seasonMatch = false | Kampanyadan çıkar veya clearance |

### Recommended Action (Önerilen Aksiyon)

| Action | Tetikleyici | Açıklama |
|---|---|---|
| PROMOTE | Star + Healthy stock | Öne çıkar, feature kampanyalarında kullan |
| FEATURE | Rising + NEW | Yeni ürün tanıtımı, deneme teşviki |
| MAINTAIN | Steady + Healthy stock | Standart kampanya akışı |
| DISCOUNT | Underperformer + Excess stock | Orta seviye indirim (%15-25) |
| CLEARANCE | Declining + Excess stock | Agresif indirim (%30+), stok eritme |
| RESTOCK | Star + Critical stock | Acil tedarik, promosyonu geçici durdur |
| BUNDLE | Moderate margin + Excess stock | Yüksek marjlı ürünlerle bundle |
| SEASONAL_PUSH | HIGH seasonal relevance | Mevsimsel kampanyalarda öne çıkar |

---

## İş Akışı

Ürün Analiz Ajanı 5 ana bölümde çalışır:

1. **Stok Analizi** — Günlük satış hızı ve stok günü hesaplama
2. **Performans Segmentasyonu** — Star/Rising/Steady/Underperformer
3. **Mevsimsel Analiz** — İklim ve mevsim uyumu
4. **Kategori Analizi** — Kategori bazlı performans
5. **Fiyat Segmenti Analizi** — Fiyat aralığı bazlı analiz

---

## 1. Stok Analizi

### 1.1 Günlük Satış Hızı Hesaplama

```javascript
// Son 90 günlük sipariş geçmişinden ürün bazlı satış hesapla
const productSales = {};

orderHistory.forEach(order => {
  order.items.forEach(item => {
    if (!productSales[item.productId]) {
      productSales[item.productId] = 0;
    }
    productSales[item.productId] += item.quantity;
  });
});

// Günlük satış hızı
const dailySalesRate = productSales[productId] / 90;
```

### 1.2 Stok Günü Hesaplama

```javascript
const stockDays = dailySalesRate > 0 
  ? product.stock / dailySalesRate 
  : 999;  // Satış yoksa sonsuz

const inventoryPressure = stockDays > 60;
```

### 1.3 Stok Segmenti

```javascript
const stockSegment = 
  stockDays < 15 ? "Critical" :
  stockDays <= 60 ? "Healthy" : "Excess";
```

---

## 2. Performans Segmentasyonu

### 2.1 Performance Segment

```javascript
const performanceSegment = 
  (product.lifecycleStage === "NEW" && product.trendScore > 85) ? "Rising" :
  (product.trendScore > 80 && stockDays < 30) ? "Star" :
  (product.trendScore >= 60 && product.trendScore <= 80 && stockDays < 60) ? "Steady" :
  "Underperformer";
```

### 2.2 Marj Sağlığı

```javascript
const margin = ((product.basePrice - product.cost) / product.basePrice) * 100;

const marginHealth = 
  margin > 60 ? "EXCELLENT" :
  margin > 40 ? "GOOD" :
  margin > 25 ? "MODERATE" : "POOR";
```

### 2.3 Fiyat Segmenti

```javascript
const priceSegment = 
  product.basePrice <= 200 ? "BUDGET" :
  product.basePrice <= 500 ? "MID" : "PREMIUM";
```

---

## 3. Mevsimsel Analiz

### 3.1 Mevsim Belirleme

```javascript
function getCurrentSeason(month) {
  if (month >= 3 && month <= 5) return "SPRING";
  if (month >= 6 && month <= 8) return "SUMMER";
  if (month >= 9 && month <= 11) return "FALL";
  return "WINTER";
}

const currentSeason = getCurrentSeason(currentMonth);
```

### 3.2 Mevsimsel Uygunluk

```javascript
const seasonMatch = 
  !product.isSeasonal || 
  product.seasonCode === currentSeason;

// İklim kuralı kontrolü
const climateMatch = [];
if (product.seasonalityRules) {
  product.seasonalityRules.forEach(rule => {
    const matches = checkClimateRule(rule, climateData);
    if (matches) {
      climateMatch.push(rule.ruleType);
    }
  });
}

const seasonalRelevance = 
  (seasonMatch && climateMatch.length > 0) ? "HIGH" :
  seasonMatch ? "MEDIUM" : "LOW";
```

### 3.3 İklim Kuralı Kontrolü

```javascript
function checkClimateRule(rule, climateData) {
  switch (rule.ruleType) {
    case "HIGH_HUMIDITY":
      return climateData.humidityPct > rule.threshold;
    case "LOW_TEMP":
      return climateData.avgTempC < rule.threshold;
    case "HIGH_RAINFALL":
      return climateData.rainfallMm > rule.threshold;
    case "SEASON_TAG":
      return climateData.seasonTag === rule.thresholdText;
    default:
      return false;
  }
}
```

---

## 4. Önerilen Aksiyon Belirleme

```javascript
function getRecommendedAction(product, performanceSegment, stockSegment, seasonalRelevance, marginHealth) {
  // Critical stock - acil tedarik
  if (stockSegment === "Critical" && performanceSegment === "Star") {
    return { action: "RESTOCK", urgency: "CRITICAL" };
  }
  
  // Rising star - feature
  if (performanceSegment === "Rising") {
    return { action: "FEATURE", urgency: "HIGH" };
  }
  
  // Star product - promote
  if (performanceSegment === "Star" && stockSegment === "Healthy") {
    return { action: "PROMOTE", urgency: "HIGH" };
  }
  
  // Seasonal relevance - seasonal push
  if (seasonalRelevance === "HIGH" && stockSegment !== "Critical") {
    return { action: "SEASONAL_PUSH", urgency: "MEDIUM" };
  }
  
  // Excess stock + declining - clearance
  if (stockSegment === "Excess" && product.lifecycleStage === "DECLINING") {
    return { action: "CLEARANCE", urgency: "CRITICAL" };
  }
  
  // Excess stock + moderate margin - bundle
  if (stockSegment === "Excess" && marginHealth === "MODERATE") {
    return { action: "BUNDLE", urgency: "HIGH" };
  }
  
  // Underperformer - discount
  if (performanceSegment === "Underperformer") {
    return { action: "DISCOUNT", urgency: "MEDIUM" };
  }
  
  // Default - maintain
  return { action: "MAINTAIN", urgency: "LOW" };
}
```

---

## 5. Kategori Analizi

```javascript
const categoryInsights = {};

products.forEach(product => {
  const cat = product.categoryId;
  
  if (!categoryInsights[cat]) {
    categoryInsights[cat] = {
      totalProducts: 0,
      totalTrendScore: 0,
      totalStock: 0,
      totalStockDays: 0,
      topPerformers: 0,
      underperformers: 0
    };
  }
  
  categoryInsights[cat].totalProducts++;
  categoryInsights[cat].totalTrendScore += product.trendScore;
  categoryInsights[cat].totalStock += product.stock;
  categoryInsights[cat].totalStockDays += stockDays;
  
  if (performanceSegment === "Star" || performanceSegment === "Rising") {
    categoryInsights[cat].topPerformers++;
  }
  if (performanceSegment === "Underperformer") {
    categoryInsights[cat].underperformers++;
  }
});

// Ortalamalar ve rating
Object.keys(categoryInsights).forEach(cat => {
  const insight = categoryInsights[cat];
  insight.avgTrendScore = insight.totalTrendScore / insight.totalProducts;
  insight.avgStockDays = insight.totalStockDays / insight.totalProducts;
  
  // Performance rating
  insight.performanceRating = 
    insight.avgTrendScore > 80 ? "STRONG" :
    insight.avgTrendScore > 65 ? "MODERATE" : "WEAK";
});
```

---

## 6. Fiyat Segmenti Analizi

```javascript
const priceSegmentAnalysis = {
  BUDGET: { priceRange: "0-200 TL", productCount: 0, totalTrendScore: 0, stockHealth: [] },
  MID: { priceRange: "200-500 TL", productCount: 0, totalTrendScore: 0, stockHealth: [] },
  PREMIUM: { priceRange: "500+ TL", productCount: 0, totalTrendScore: 0, stockHealth: [] }
};

products.forEach(product => {
  const segment = priceSegment;
  priceSegmentAnalysis[segment].productCount++;
  priceSegmentAnalysis[segment].totalTrendScore += product.trendScore;
  priceSegmentAnalysis[segment].stockHealth.push(stockSegment);
});

// Ortalamalar
Object.keys(priceSegmentAnalysis).forEach(segment => {
  const analysis = priceSegmentAnalysis[segment];
  analysis.avgTrendScore = analysis.totalTrendScore / analysis.productCount;
  
  // Stock health summary
  const healthyCount = analysis.stockHealth.filter(h => h === "Healthy").length;
  analysis.stockHealth = 
    healthyCount / analysis.productCount > 0.7 ? "GOOD" :
    healthyCount / analysis.productCount > 0.4 ? "MODERATE" : "POOR";
});
```

---

## 7. Envanter Özeti

```javascript
const inventorySummary = {
  totalProducts: products.length,
  totalStockValue: products.reduce((sum, p) => sum + (p.stock * p.cost), 0),
  criticalStockProducts: products.filter(p => stockSegment === "Critical").length,
  excessStockProducts: products.filter(p => stockSegment === "Excess").length,
  healthyStockProducts: products.filter(p => stockSegment === "Healthy").length,
  avgStockDays: products.reduce((sum, p) => sum + stockDays, 0) / products.length,
  inventoryTurnoverRate: 365 / avgStockDays  // Yıllık devir hızı
};
```

---

## Pseudo-kod

```javascript
async function analyzeProducts({ tenantId, products, orderHistory, currentMonth, climateData }) {
  // 1. Mevsim belirleme
  const currentSeason = getCurrentSeason(currentMonth);
  
  // 2. Ürün bazlı satış hesaplama
  const productSales = calculateProductSales(orderHistory);
  
  // 3. Her ürün için analiz
  const analyzedProducts = products.map(product => {
    // Stok analizi
    const dailySalesRate = productSales[product.id] / 90;
    const stockDays = dailySalesRate > 0 ? product.stock / dailySalesRate : 999;
    const stockSegment = getStockSegment(stockDays);
    
    // Performans segmentasyonu
    const performanceSegment = getPerformanceSegment(product, stockDays);
    const marginHealth = getMarginHealth(product);
    const priceSegment = getPriceSegment(product.basePrice);
    
    // Mevsimsel analiz
    const seasonMatch = checkSeasonMatch(product, currentSeason);
    const climateMatch = checkClimateMatch(product, climateData);
    const seasonalRelevance = getSeasonalRelevance(seasonMatch, climateMatch);
    
    // Önerilen aksiyon
    const { action, urgency } = getRecommendedAction(
      product, performanceSegment, stockSegment, seasonalRelevance, marginHealth
    );
    
    return {
      ...product,
      performanceSegment,
      stockSegment,
      stockDays,
      dailySalesRate,
      seasonalRelevance,
      priceSegment,
      marginHealth,
      recommendedAction: action,
      urgencyLevel: urgency
    };
  });
  
  // 4. Segmentlere ayır
  const heroProducts = analyzedProducts
    .filter(p => p.performanceSegment === "Star" || p.performanceSegment === "Rising")
    .sort((a, b) => b.trendScore - a.trendScore)
    .slice(0, 10);
  
  const slowMovers = analyzedProducts
    .filter(p => p.stockSegment === "Excess" || p.performanceSegment === "Underperformer")
    .sort((a, b) => b.stockDays - a.stockDays)
    .slice(0, 15);
  
  const newProducts = analyzedProducts
    .filter(p => p.lifecycleStage === "NEW")
    .sort((a, b) => b.trendScore - a.trendScore);
  
  const seasonalProducts = analyzedProducts
    .filter(p => p.seasonalRelevance === "HIGH")
    .slice(0, 10);
  
  // 5. Kategori ve fiyat analizi
  const categoryInsights = analyzeCategoryPerformance(analyzedProducts);
  const priceSegmentAnalysis = analyzePriceSegments(analyzedProducts);
  const inventorySummary = calculateInventorySummary(analyzedProducts);
  
  // 6. ProductInsightJSON oluştur
  return {
    heroProducts,
    slowMovers,
    newProducts,
    seasonalProducts,
    categoryInsights,
    priceSegmentAnalysis,
    inventorySummary
  };
}
```

---

## Test Senaryoları

### Senaryo 1: Star Product (Yıldız Ürün)
```
productId: "prod-z-001"
trendScore: 85
stockDays: 8
lifecycleStage: "MATURE"
Beklenen:
  - performanceSegment: "Star"
  - stockSegment: "Critical"
  - recommendedAction: "RESTOCK"
  - urgencyLevel: "CRITICAL"
```

### Senaryo 2: Slow Mover (Yavaş Ürün)
```
productId: "prod-z-005"
trendScore: 30
stockDays: 95
lifecycleStage: "DECLINING"
seasonMatch: false
Beklenen:
  - performanceSegment: "Underperformer"
  - stockSegment: "Excess"
  - recommendedAction: "CLEARANCE"
  - urgencyLevel: "CRITICAL"
```

### Senaryo 3: Rising Star (Yükselen Yıldız)
```
productId: "prod-z-011"
trendScore: 95
lifecycleStage: "NEW"
stockDays: 45
Beklenen:
  - performanceSegment: "Rising"
  - stockSegment: "Healthy"
  - recommendedAction: "FEATURE"
  - urgencyLevel: "HIGH"
```

### Senaryo 4: Seasonal Product (Mevsimsel Ürün)
```
productId: "prod-z-001"
seasonCode: "WINTER"
currentSeason: "WINTER"
climateMatch: ["HIGH_HUMIDITY", "LOW_TEMP"]
Beklenen:
  - seasonalRelevance: "HIGH"
  - recommendedAction: "SEASONAL_PUSH"
  - matchingCities: ["İstanbul", "Bursa"]
```

### Senaryo 5: Bundle Candidate (Bundle Adayı)
```
productId: "prod-z-007"
stockDays: 75
marginHealth: "MODERATE"
performanceSegment: "Steady"
Beklenen:
  - stockSegment: "Excess"
  - recommendedAction: "BUNDLE"
  - urgencyLevel: "HIGH"
```

---

## Notlar

- Ürün Analiz Ajanı **sadece ürün segmentasyonu** yapar
- Müşteri analizi yapmaz
- Kampanya kararı almaz (sadece öneriler sunar)
- Tüm hesaplamalar deterministik (ML yok)
- Segment tabloları referans olarak kullanılır
- Stok günü hesaplaması son 90 günlük satış verisi kullanır
- İklim kuralları şehir bazlı uygulanır



---

## Veritabanı Şeması ile Uyum

Ürün Analiz Ajanı, `database/schema.sql` dosyasındaki `products` tablosu ile uyumlu çalışır:

### Tablo Yapısı (products)
- `product_id` → productId
- `tenant_id` → tenantId
- `product_name` → productName
- `category` → category (ENUM: MAKEUP, SKINCARE, FRAGRANCE, PERSONALCARE, HAIRCARE, WELLNESS)
- `subcategory` → subcategory
- `season` → season (ENUM: all, winter, summer, spring, autumn)
- `current_stock` → stock / currentStock
- `last_30_days_sales` → last30DaysSales
- `unit_cost` → cost / unitCost
- `unit_price` → basePrice / unitPrice
- `source_url` → sourceUrl

### Ek Alanlar (JSON'da)
- `brand` → Marka bilgisi (Farmasi)
- `isSeasonal` → Mevsimsel ürün mü? (boolean)
- `seasonCode` → Mevsim kodu (all, WINTER, SUMMER, SPRING, FALL)
- `lifecycleStage` → Yaşam döngüsü (NEW, GROWING, MATURE, DECLINING)
- `trendScore` → Trend skoru (0-100)
- `tags` → Ürün etiketleri (array)
- `seasonalityRules` → İklim kuralları (array)

### Örnek Veri Kaynağı
`data/products.json` dosyası, Farmasi ürünlerini içerir ve Product Analysis Agent'ın beklediği formatta yapılandırılmıştır.

### Kullanım
```javascript
// products.json dosyasını yükle
const productData = require('./data/products.json');

// Product Analysis Agent'a gönder
const insights = await analyzeProducts({
  tenantId: productData.tenantId,
  products: productData.products,
  orderHistory: orderHistory,
  currentMonth: 2,
  climateData: climateData
});
```
