# Example Data Guide - User & User Segment JSON

## 📋 İçindekiler

1. [User JSON Format](#user-json-format)
2. [User Segment JSON Format](#user-segment-json-format)
3. [Örnek Senaryolar](#örnek-senaryolar)
4. [Field Açıklamaları](#field-açıklamaları)

---

## User JSON Format

### Temel Yapı

```json
{
  "customerId": "string",
  "city": "string",
  "region": "string",
  "age": number,
  "gender": "string",
  "registeredAt": "YYYY-MM-DD",
  "productHistory": [
    {
      "productId": "string",
      "category": "string",
      "totalQuantity": number,
      "totalSpent": number,
      "orderCount": number,
      "firstPurchase": "YYYY-MM-DD",
      "lastPurchase": "YYYY-MM-DD",
      "avgDaysBetween": number | null
    }
  ]
}
```

### Örnek 1: Aktif High-Value Müşteri

```json
{
  "customerId": "C-1001",
  "city": "Istanbul",
  "region": "Marmara",
  "age": 32,
  "gender": "F",
  "registeredAt": "2024-03-15",
  "productHistory": [
    {
      "productId": "P-2001",
      "category": "SKINCARE",
      "totalQuantity": 8,
      "totalSpent": 479.20,
      "orderCount": 8,
      "firstPurchase": "2025-01-15",
      "lastPurchase": "2026-01-20",
      "avgDaysBetween": 30
    },
    {
      "productId": "P-2004",
      "category": "SKINCARE",
      "totalQuantity": 7,
      "totalSpent": 454.30,
      "orderCount": 5,
      "firstPurchase": "2025-02-10",
      "lastPurchase": "2026-02-01",
      "avgDaysBetween": 45
    }
  ]
}
```

### Örnek 2: Yeni Müşteri (Boş History)

```json
{
  "customerId": "C-NEW-001",
  "city": "Antalya",
  "region": "Akdeniz",
  "age": 22,
  "gender": "F",
  "registeredAt": "2026-02-01",
  "productHistory": []
}
```

### Örnek 3: Riskli Müşteri (Churn Risk)

```json
{
  "customerId": "C-1005",
  "city": "Trabzon",
  "region": "Karadeniz",
  "age": 38,
  "gender": "F",
  "registeredAt": "2024-08-20",
  "productHistory": [
    {
      "productId": "P-2006",
      "category": "SKINCARE",
      "totalQuantity": 1,
      "totalSpent": 79.90,
      "orderCount": 1,
      "firstPurchase": "2025-08-10",
      "lastPurchase": "2025-08-10",
      "avgDaysBetween": null
    }
  ]
}
```

---

## User Segment JSON Format

### Temel Yapı

```json
{
  "customerId": "string",
  "city": "string",
  "region": "string",
  "climateType": "string",
  "age": number,
  "ageSegment": "GenZ" | "GençYetişkin" | "Yetişkin" | "Olgun",
  "gender": "string",
  "churnSegment": "Aktif" | "Ilık" | "Riskli",
  "valueSegment": "HighValue" | "Standard",
  "loyaltyTier": "Platin" | "Altın" | "Gümüş" | "Bronz",
  "affinityCategory": "string",
  "affinityType": "Odaklı" | "Keşifçi",
  "diversityProfile": "Kaşif" | "Dengeli" | "Sadık",
  "estimatedBudget": number,
  "avgBasket": number,
  "avgMonthlySpend": number,
  "lastPurchaseDaysAgo": number,
  "orderCount": number,
  "totalSpent": number,
  "membershipDays": number,
  "missingRegulars": [
    {
      "productId": "string",
      "productName": "string",
      "lastBought": "YYYY-MM-DD",
      "avgDaysBetween": number,
      "daysOverdue": number
    }
  ],
  "topProducts": [
    {
      "productId": "string",
      "totalQuantity": number,
      "totalSpent": number,
      "lastBought": "YYYY-MM-DD"
    }
  ]
}
```

### Örnek 1: Aktif High-Value Müşteri Segmenti

```json
{
  "customerId": "C-1001",
  "city": "Istanbul",
  "region": "Marmara",
  "climateType": "Metropol",
  "age": 32,
  "ageSegment": "GençYetişkin",
  "gender": "F",
  "churnSegment": "Aktif",
  "valueSegment": "Standard",
  "loyaltyTier": "Gümüş",
  "affinityCategory": "SKINCARE",
  "affinityType": "Odaklı",
  "diversityProfile": "Sadık",
  "estimatedBudget": 95.15,
  "avgBasket": 79.29,
  "avgMonthlySpend": 57.85,
  "lastPurchaseDaysAgo": 11,
  "orderCount": 17,
  "totalSpent": 1348.00,
  "membershipDays": 699,
  "missingRegulars": [],
  "topProducts": [
    {
      "productId": "P-2001",
      "totalQuantity": 8,
      "totalSpent": 479.20,
      "lastBought": "2026-01-20"
    },
    {
      "productId": "P-2004",
      "totalQuantity": 7,
      "totalSpent": 454.30,
      "lastBought": "2026-02-01"
    }
  ]
}
```

### Örnek 2: Yeni Müşteri Segmenti

```json
{
  "customerId": "C-NEW-001",
  "city": "Antalya",
  "region": "Akdeniz",
  "climateType": "Sıcak-Nemli",
  "age": 22,
  "ageSegment": "GenZ",
  "gender": "F",
  "churnSegment": "Riskli",
  "valueSegment": "Standard",
  "loyaltyTier": "Bronz",
  "affinityCategory": "SKINCARE",
  "affinityType": "Keşifçi",
  "diversityProfile": "Kaşif",
  "estimatedBudget": 102.00,
  "avgBasket": 85.00,
  "avgMonthlySpend": 0.00,
  "lastPurchaseDaysAgo": 999,
  "orderCount": 0,
  "totalSpent": 0.00,
  "membershipDays": 11,
  "missingRegulars": [],
  "topProducts": []
}
```

### Örnek 3: Riskli Müşteri Segmenti (Missing Regulars)

```json
{
  "customerId": "C-1013",
  "city": "Konya",
  "region": "İç Anadolu",
  "climateType": "Sıcak-Kuru",
  "age": 33,
  "ageSegment": "GençYetişkin",
  "gender": "F",
  "churnSegment": "Aktif",
  "valueSegment": "Standard",
  "loyaltyTier": "Gümüş",
  "affinityCategory": "SKINCARE",
  "affinityType": "Odaklı",
  "diversityProfile": "Sadık",
  "estimatedBudget": 79.88,
  "avgBasket": 66.57,
  "avgMonthlySpend": 41.52,
  "lastPurchaseDaysAgo": 13,
  "orderCount": 12,
  "totalSpent": 798.80,
  "membershipDays": 577,
  "missingRegulars": [
    {
      "productId": "P-2001",
      "productName": "Hydrating Serum",
      "lastBought": "2025-10-20",
      "avgDaysBetween": 30,
      "daysOverdue": 84
    },
    {
      "productId": "P-2004",
      "productName": "Night Cream",
      "lastBought": "2025-11-15",
      "avgDaysBetween": 45,
      "daysOverdue": 35
    }
  ],
  "topProducts": [
    {
      "productId": "P-2001",
      "totalQuantity": 6,
      "totalSpent": 359.40,
      "lastBought": "2025-10-20"
    },
    {
      "productId": "P-2004",
      "totalQuantity": 4,
      "totalSpent": 259.60,
      "lastBought": "2025-11-15"
    },
    {
      "productId": "P-1001",
      "totalQuantity": 2,
      "totalSpent": 179.80,
      "lastBought": "2026-01-30"
    }
  ]
}
```

---

## Örnek Senaryolar

### Senaryo 1: Platin Tier Müşteri

**User:**
```json
{
  "customerId": "C-PLATIN-001",
  "city": "Kocaeli",
  "region": "Marmara",
  "age": 34,
  "gender": "F",
  "registeredAt": "2023-06-01",
  "productHistory": [
    {
      "productId": "P-2001",
      "category": "SKINCARE",
      "totalQuantity": 25,
      "totalSpent": 1498.75,
      "orderCount": 25,
      "lastPurchase": "2026-02-11",
      "avgDaysBetween": 20
    }
  ]
}
```

**Segment:**
```json
{
  "customerId": "C-PLATIN-001",
  "loyaltyTier": "Altın",
  "churnSegment": "Aktif",
  "valueSegment": "Standard",
  "orderCount": 25,
  "membershipDays": 987
}
```

### Senaryo 2: GenZ Explorer

**User:**
```json
{
  "customerId": "C-GENZ-001",
  "city": "Bursa",
  "region": "Marmara",
  "age": 24,
  "gender": "F",
  "registeredAt": "2025-08-15",
  "productHistory": [
    {
      "productId": "P-1001",
      "category": "MAKEUP",
      "totalQuantity": 1,
      "totalSpent": 89.90,
      "orderCount": 1,
      "lastPurchase": "2026-01-20",
      "avgDaysBetween": null
    },
    {
      "productId": "P-2004",
      "category": "SKINCARE",
      "totalQuantity": 1,
      "totalSpent": 64.90,
      "orderCount": 1,
      "lastPurchase": "2026-01-15",
      "avgDaysBetween": null
    },
    {
      "productId": "P-3001",
      "category": "FRAGRANCE",
      "totalQuantity": 1,
      "totalSpent": 149.90,
      "orderCount": 1,
      "lastPurchase": "2026-01-10",
      "avgDaysBetween": null
    }
  ]
}
```

**Segment:**
```json
{
  "customerId": "C-GENZ-001",
  "ageSegment": "GenZ",
  "affinityType": "Keşifçi",
  "diversityProfile": "Kaşif",
  "orderCount": 3,
  "totalSpent": 304.70
}
```

---

## Field Açıklamaları

### User JSON Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| customerId | string | Yes | Unique customer identifier |
| city | string | Yes | Customer's city |
| region | string | Yes | Geographic region |
| age | number | Yes | Customer age (18+) |
| gender | string | Yes | "F", "M", or other |
| registeredAt | string | Yes | Registration date (YYYY-MM-DD) |
| productHistory | array | Yes | Purchase history (can be empty) |

### Product History Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| productId | string | Yes | Product identifier |
| category | string | Yes | Product category |
| totalQuantity | number | Yes | Total units purchased |
| totalSpent | number | Yes | Total amount spent |
| orderCount | number | Yes | Number of orders |
| firstPurchase | string | Yes | First purchase date |
| lastPurchase | string | Yes | Last purchase date |
| avgDaysBetween | number/null | Yes | Average days between purchases (null if single purchase) |

### User Segment Fields

| Field | Type | Description |
|-------|------|-------------|
| customerId | string | Customer identifier |
| ageSegment | string | GenZ (18-25), GençYetişkin (26-35), Yetişkin (36-50), Olgun (51+) |
| churnSegment | string | Aktif (<30 days), Ilık (30-60), Riskli (>60) |
| valueSegment | string | HighValue (above median), Standard (at/below median) |
| loyaltyTier | string | Platin, Altın, Gümüş, Bronz |
| affinityCategory | string | Most purchased category |
| affinityType | string | Odaklı (>60% one category), Keşifçi (diverse) |
| diversityProfile | string | Kaşif (>70%), Dengeli (40-70%), Sadık (≤40%) |
| estimatedBudget | number | avgBasket * 1.2 |
| avgBasket | number | totalSpent / orderCount |
| avgMonthlySpend | number | totalSpent / membershipMonths |
| lastPurchaseDaysAgo | number | Days since last purchase |
| orderCount | number | Total number of orders |
| totalSpent | number | Total amount spent |
| membershipDays | number | Days since registration |
| missingRegulars | array | Products overdue for repurchase |
| topProducts | array | Top 5 products by spending |

---

## Kategoriler

### Mevcut Kategoriler

- **SKINCARE**: Cilt bakım ürünleri
- **MAKEUP**: Makyaj ürünleri
- **FRAGRANCE**: Parfüm ve koku ürünleri
- **HAIRCARE**: Saç bakım ürünleri
- **PERSONALCARE**: Kişisel bakım ürünleri
- **WELLNESS**: Sağlık ve wellness ürünleri

### Bölgeler

- **Marmara**: Istanbul, Bursa, Kocaeli (Metropol)
- **Ege**: Izmir, Denizli (Sıcak-Nemli)
- **Akdeniz**: Antalya, Mersin, Adana (Sıcak-Nemli)
- **İç Anadolu**: Ankara, Konya, Kayseri (Sıcak-Kuru)
- **Karadeniz**: Trabzon, Samsun (Soğuk)
- **Doğu Anadolu**: Erzurum, Van (Soğuk)
- **Güneydoğu Anadolu**: Gaziantep, Diyarbakır (Sıcak-Kuru)

---

## Kullanım Örnekleri

### Python

```python
import json

# User JSON'u oku
with open('example-user.json', 'r') as f:
    user = json.load(f)

# Segment JSON'u oku
with open('example-user-segment.json', 'r') as f:
    segment = json.load(f)

print(f"Customer: {user['customerId']}")
print(f"Segment: {segment['ageSegment']} - {segment['loyaltyTier']}")
```

### JavaScript

```javascript
// User JSON'u oku
const user = require('./example-user.json');

// Segment JSON'u oku
const segment = require('./example-user-segment.json');

console.log(`Customer: ${user.customerId}`);
console.log(`Segment: ${segment.ageSegment} - ${segment.loyaltyTier}`);
```

### cURL (API Test)

```bash
curl -X POST https://your-api.com/analyze \
  -H "Content-Type: application/json" \
  -d @example-user.json
```

---

## Dosyalar

- `example-user.json` - Örnek user data
- `example-user-segment.json` - Örnek segment data
- `mock-data/farmasi/customers.json` - 8 gerçek müşteri örneği
- `test_customer_data.json` - Test için kullanılan data

---

## Notlar

1. **Tarih Formatı**: YYYY-MM-DD veya YYYY-MM-DDTHH:MM:SS
2. **avgDaysBetween**: Tek seferlik alışverişlerde `null` olmalı
3. **productHistory**: Boş array olabilir (yeni müşteriler için)
4. **missingRegulars**: Sadece avgDaysBetween * 1.2'den fazla gecikmiş ürünler
5. **topProducts**: En fazla 5 ürün, totalSpent'e göre sıralı

---

Daha fazla örnek için `mock-data/farmasi/customers.json` dosyasına bakabilirsin!
