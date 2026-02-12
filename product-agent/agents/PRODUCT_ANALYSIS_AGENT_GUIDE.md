# Product Analysis Agent — Kullanım Rehberi

## 1. Genel Bakış

Product Analysis Agent, ürün kataloğunu analiz ederek kampanya yönetimi için aksiyon önerileri üreten deterministik bir analiz ajanıdır. Amazon Bedrock AgentCore Runtime üzerinde deploy edilmiştir.

**Ne yapar:**
- Ürün performans segmentasyonu (Star / Rising / Steady / Underperformer)
- Stok sağlığı analizi (Critical / Healthy / Excess)
- Mevsimsel uygunluk ve iklim eşleştirmesi
- Kategori ve fiyat segmenti analizi
- Her ürün için aksiyon önerisi (RESTOCK, PROMOTE, CLEARANCE vb.)

**Ne yapmaz:**
- Müşteri analizi yapmaz
- Kampanya kararı almaz
- ML/LLM kullanmaz — tüm hesaplamalar deterministiktir

---

## 2. Deployment Bilgileri

| Bilgi | Değer |
|-------|-------|
| Agent Adı | `product_analysis_agent_kiro` |
| Region | `us-west-2` |
| AgentCore ARN | `arn:aws:bedrock-agentcore:us-west-2:853548971581:runtime/product_analysis_agent_kiro-DbG83rES5F` |
| ECR URI | `853548971581.dkr.ecr.us-west-2.amazonaws.com/bedrock-agentcore-product_analysis_agent_kiro` |
| IAM Role | `arn:aws:iam::853548971581:role/AmazonBedrockAgentCoreSDKRuntime-us-west-2-27930069dd` |
| Memory ID | `product_analysis_agent_kiro_mem-Ypo7PD3UlH` |
| Account | `853548971581` |

---

## 3. Input / Output Şeması

### 3.1 Input (Girdi)

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
  "orderHistory": [
    {
      "orderId": "ORD-001",
      "orderDate": "2025-11-20",
      "customerId": "C001",
      "items": [
        { "productId": "1002705", "quantity": 25, "unitPrice": 89.9 }
      ]
    }
  ],
  "currentMonth": 2,
  "climateData": {
    "Istanbul": {
      "month": 2,
      "avgTempC": 6.5,
      "humidityPct": 72,
      "rainfallMm": 85,
      "seasonTag": "winter"
    }
  }
}
```

**Zorunlu alanlar:** `tenantId`, `products` (min 1), `orderHistory` (boş olabilir), `currentMonth` (1-12), `climateData` (boş obje olabilir)

**climateData alan isimleri:** `avgTempC`, `humidityPct`, `rainfallMm`, `seasonTag` (bu isimlere dikkat — `avgTemp` veya `humidity` kabul edilmez)

### 3.2 Output (Çıktı) — ProductInsightJSON

```json
{
  "heroProducts": [...],       // Top 10 Star/Rising (trendScore desc)
  "slowMovers": [...],         // Top 15 Excess/Underperformer (stockDays desc)
  "newProducts": [...],        // Tüm NEW lifecycle (trendScore desc)
  "seasonalProducts": [...],   // Top 10 HIGH seasonal relevance
  "categoryInsights": {...},   // Kategori bazlı performans
  "priceSegmentAnalysis": {...}, // BUDGET/MID/PREMIUM analizi
  "inventorySummary": {...}    // Genel envanter özeti
}
```

---

## 4. Segmentasyon Kuralları (Özet)

### Performance Segment
| Segment | Koşul |
|---------|-------|
| Rising | `lifecycleStage == "NEW" && trendScore > 85` |
| Star | `trendScore > 80 && stockDays < 30` |
| Steady | `60 <= trendScore <= 80 && stockDays < 60` |
| Underperformer | Diğer tüm durumlar |

> Rising önce kontrol edilir. NEW + trend > 85 olan ürün Star olamaz.

### Stock Segment
| Segment | Koşul |
|---------|-------|
| Critical | `stockDays < 15` |
| Healthy | `15 <= stockDays <= 60` |
| Excess | `stockDays > 60` |

`stockDays = stock / (totalOrderQuantity / 90)`

### Recommended Action
| Action | Tetikleyici |
|--------|-------------|
| RESTOCK | Star + Critical stock |
| FEATURE | Rising (NEW) ürünler |
| PROMOTE | Star + Healthy stock |
| SEASONAL_PUSH | HIGH seasonal relevance |
| CLEARANCE | Declining + Excess stock |
| BUNDLE | Moderate margin + Excess stock |
| DISCOUNT | Underperformer |
| MAINTAIN | Varsayılan |

---

## 5. Lokal Çalıştırma

### Gereksinimler
- Python 3.11+ (`.venv` virtual environment)
- `requirements.txt` bağımlılıkları

### Komut

```bash
# Windows
.venv\Scripts\python.exe product_analysis_agent.py test/request.json

# Linux/Mac
.venv/bin/python product_analysis_agent.py test/request.json
```

Çıktı stdout'a JSON olarak yazılır. Dosyaya kaydetmek için:

```bash
.venv\Scripts\python.exe product_analysis_agent.py test/request.json > test/response.json
```

### Test Verileri

- `test/request.json` — 40 ürün, 10 sipariş, 3 şehir iklim verisi içeren örnek input
- `test/response.json` — Yukarıdaki input'un gerçek çıktısı
- `data/products.json` — Farmasi ürün kataloğu (40 ürün)

---

## 6. AWS Bedrock AgentCore Üzerinde Çağırma

### Python (boto3)

```python
import boto3
import json

client = boto3.client('bedrock-agentcore-runtime', region_name='us-west-2')

input_data = {
    "tenantId": "farmasi",
    "products": [...],
    "orderHistory": [...],
    "currentMonth": 2,
    "climateData": {...}
}

response = client.invoke_agent(
    agentId='product_analysis_agent_kiro-DbG83rES5F',
    sessionId='session-123',
    inputText=json.dumps(input_data)
)

result = json.loads(response['output'])
```

### AgentCore Sandbox (AWS Console)

AgentCore Sandbox'ta test ederken input şu formatta gönderilir:

```json
{"prompt": "{\"tenantId\":\"farmasi\",\"products\":[...],\"orderHistory\":[...],\"currentMonth\":2,\"climateData\":{...}}"}
```

Agent, hem doğrudan JSON hem de `{"prompt": "..."}` sarmalı formatını otomatik olarak destekler.

---

## 7. Üst Seviye Campaign Agent Entegrasyonu

Campaign Agent, Product Analysis Agent ve Customer Analysis Agent'ı alt ajan olarak çağırır ve sonuçlarını birleştirerek kampanya kararları üretir.

### 7.1 Mimari

```
┌─────────────────────────────────────────────────┐
│              Campaign Agent (Orchestrator)        │
│                                                   │
│  1. Input al (tenantId, customerId, products...) │
│  2. Product Analysis Agent'ı çağır               │
│  3. Customer Analysis Agent'ı çağır              │
│  4. Sonuçları birleştir                          │
│  5. Kampanya kararı üret (LLM ile)              │
│  6. Response dön                                  │
└──────────┬──────────────────┬─────────────────────┘
           │                  │
           ▼                  ▼
┌──────────────────┐ ┌──────────────────────┐
│ Product Analysis │ │ Customer Analysis    │
│ Agent            │ │ Agent                │
│                  │ │                      │
│ Input:           │ │ Input:               │
│  - products      │ │  - customerId        │
│  - orderHistory  │ │  - customer record   │
│  - climateData   │ │  - region info       │
│  - currentMonth  │ │  - currentSeason     │
│                  │ │                      │
│ Output:          │ │ Output:              │
│  ProductInsight  │ │  CustomerInsight     │
│  JSON            │ │  JSON                │
└──────────────────┘ └──────────────────────┘
```

### 7.2 Campaign Agent Akışı

```python
async def run_campaign_agent(request):
    """
    Campaign Agent ana akışı.
    Product ve Customer agent'larını çağırır, sonuçları LLM'e verir.
    """
    
    # ── ADIM 1: Alt agent'ları paralel çağır ──
    
    # Product Analysis Agent input'u hazırla
    product_input = {
        "tenantId": request["tenantId"],
        "products": request["products"],
        "orderHistory": request["orderHistory"],
        "currentMonth": request["currentMonth"],
        "climateData": request["climateData"]
    }
    
    # Customer Analysis Agent input'u hazırla
    customer_input = {
        "city": request["city"],
        "customerId": request.get("customerId"),  # opsiyonel
        "customer": request.get("customer"),
        "region": request["region"],
        "currentSeason": get_current_season(request["currentMonth"])
    }
    
    # Paralel çağrı (her iki agent bağımsız çalışır)
    product_insights, customer_insights = await asyncio.gather(
        invoke_product_agent(product_input),
        invoke_customer_agent(customer_input)
    )
    
    # ── ADIM 2: Sonuçları birleştir ──
    
    combined_context = {
        "productInsights": product_insights,
        "customerInsights": customer_insights,
        "tenantId": request["tenantId"],
        "currentMonth": request["currentMonth"]
    }
    
    # ── ADIM 3: LLM ile kampanya kararı üret ──
    
    campaign_decision = await generate_campaign_with_llm(combined_context)
    
    return campaign_decision
```

### 7.3 Product Agent Çağrısı (Detaylı)

```python
import boto3
import json

def invoke_product_agent(product_input: dict) -> dict:
    """
    Product Analysis Agent'ı çağırır.
    
    Args:
        product_input: {
            "tenantId": str,
            "products": list,
            "orderHistory": list,
            "currentMonth": int,
            "climateData": dict
        }
    
    Returns:
        ProductInsightJSON: {
            "heroProducts": [...],
            "slowMovers": [...],
            "newProducts": [...],
            "seasonalProducts": [...],
            "categoryInsights": {...},
            "priceSegmentAnalysis": {...},
            "inventorySummary": {...}
        }
    """
    client = boto3.client('bedrock-agentcore-runtime', region_name='us-west-2')
    
    response = client.invoke_agent(
        agentId='product_analysis_agent_kiro-DbG83rES5F',
        sessionId=f'campaign-{uuid.uuid4()}',
        inputText=json.dumps(product_input)
    )
    
    return json.loads(response['output'])
```

### 7.4 Customer Agent Çağrısı (Detaylı)

```python
def invoke_customer_agent(customer_input: dict) -> dict:
    """
    Customer Analysis Agent'ı çağırır.
    
    Args:
        customer_input: {
            "city": str,
            "customerId": str (opsiyonel),
            "customer": dict,
            "region": dict,
            "currentSeason": str
        }
    
    Returns:
        CustomerInsightJSON: {
            "customerId": str,
            "city": str,
            "ageSegment": str,
            "churnSegment": str,       # Aktif / Ilık / Riskli
            "valueSegment": str,       # HighValue / Standard
            "loyaltyTier": str,        # Platin / Altın / Gümüş / Bronz
            "affinityCategory": str,   # En çok ilgi duyduğu kategori
            "affinityType": str,       # Odaklı / Keşifçi
            "diversityProfile": str,   # Kaşif / Dengeli / Sadık
            "estimatedBudget": float,
            "missingRegulars": [...],  # Zamanı gelmiş düzenli ürünler
            "topProducts": [...]       # En çok aldığı ürünler
        }
    """
    client = boto3.client('bedrock-agentcore-runtime', region_name='us-west-2')
    
    response = client.invoke_agent(
        agentId='CUSTOMER_AGENT_ID',  # Deploy edildiğinde güncellenecek
        sessionId=f'campaign-{uuid.uuid4()}',
        inputText=json.dumps(customer_input)
    )
    
    return json.loads(response['output'])
```

### 7.5 Sonuçları Birleştirme — Kampanya Kararı

Campaign Agent, iki alt agent'ın çıktılarını birleştirerek şu eşleştirmeleri yapar:

```
Product Insight              +  Customer Insight           →  Kampanya Kararı
─────────────────────────────────────────────────────────────────────────────
heroProducts (Star)          +  affinityCategory match     →  PROMOTE (öne çıkar)
heroProducts (Rising/NEW)    +  diversityProfile=Kaşif     →  FEATURE (yeni ürün tanıt)
slowMovers (Excess)          +  estimatedBudget uygun      →  DISCOUNT / CLEARANCE
seasonalProducts (HIGH)      +  city/climate match         →  SEASONAL_PUSH
product.missingRegulars      +  customer.missingRegulars   →  REPLENISHMENT_NUDGE
heroProducts (Star)          +  churnSegment=Riskli        →  WIN_BACK + star ürün
slowMovers (BUNDLE)          +  loyaltyTier=Altın/Platin   →  LOYALTY_BUNDLE
```

### 7.6 LLM'e Verilecek Prompt Yapısı

```python
def build_campaign_prompt(product_insights, customer_insights):
    """
    LLM'e verilecek prompt'u oluşturur.
    İki agent'ın çıktılarını yapılandırılmış context olarak verir.
    """
    
    prompt = f"""
Sen bir kampanya stratejisti AI'sın. Aşağıdaki ürün ve müşteri analizlerini 
kullanarak kişiselleştirilmiş kampanya önerisi üret.

## Ürün Analizi (Product Analysis Agent Çıktısı)

### Hero Ürünler (Star + Rising)
{json.dumps(product_insights['heroProducts'][:5], indent=2, ensure_ascii=False)}

### Yavaş Hareket Eden Ürünler (Stok Baskısı)
{json.dumps(product_insights['slowMovers'][:5], indent=2, ensure_ascii=False)}

### Mevsimsel Ürünler
{json.dumps(product_insights['seasonalProducts'], indent=2, ensure_ascii=False)}

### Envanter Özeti
{json.dumps(product_insights['inventorySummary'], indent=2, ensure_ascii=False)}

## Müşteri Analizi (Customer Analysis Agent Çıktısı)

### Müşteri Profili
- Değer Segmenti: {customer_insights['valueSegment']}
- Sadakat: {customer_insights['loyaltyTier']}
- Kayıp Riski: {customer_insights['churnSegment']}
- Kategori Eğilimi: {customer_insights['affinityCategory']} ({customer_insights['affinityType']})
- Çeşitlilik: {customer_insights['diversityProfile']}
- Tahmini Bütçe: {customer_insights['estimatedBudget']} TL

### Zamanı Gelmiş Düzenli Ürünler
{json.dumps(customer_insights.get('missingRegulars', []), indent=2, ensure_ascii=False)}

## Görev

1. Müşterinin profiline uygun 2-3 kampanya önerisi üret
2. Her öneri için: hedef ürünler, indirim oranı, kampanya tipi, gerekçe
3. Ürün seçiminde stok durumu ve marj sağlığını dikkate al
4. Müşterinin bütçe limitini aşma
5. Kararlarını açıkla (explainability)
"""
    return prompt
```

---

## 8. Campaign Agent Tam Input/Output Örneği

### Campaign Agent Input

```json
{
  "tenantId": "farmasi",
  "customerId": "C-1001",
  "city": "Istanbul",
  "customer": {
    "customerId": "C-1001",
    "age": 32,
    "gender": "F",
    "city": "Istanbul",
    "registeredAt": "2025-04-15",
    "productHistory": [...]
  },
  "region": {
    "name": "Marmara",
    "climateType": "Metropol",
    "medianBasket": 85.50,
    "trend": "SKINCARE"
  },
  "products": [...],
  "orderHistory": [...],
  "currentMonth": 2,
  "climateData": {
    "Istanbul": {
      "avgTempC": 6.5,
      "humidityPct": 72,
      "rainfallMm": 85,
      "seasonTag": "winter"
    }
  }
}
```

### Campaign Agent Output (Beklenen)

```json
{
  "customerId": "C-1001",
  "campaigns": [
    {
      "campaignType": "PERSONALIZED_OFFER",
      "title": "Kış Bakım Rutinin Hazır",
      "products": [
        {
          "productId": "2001001",
          "productName": "Glow Boost Vitamin C Serum 30 ml",
          "originalPrice": 139.90,
          "discountedPrice": 118.90,
          "discountRate": 15,
          "reason": "Star ürün, SKINCARE kategorisinde yüksek eğilim, stok kritik seviyede — son fırsat"
        },
        {
          "productId": "2001013",
          "productName": "Kış Bakım Seti Dudak+El Kremi",
          "originalPrice": 74.90,
          "discountedPrice": 67.40,
          "discountRate": 10,
          "reason": "Mevsimsel ürün, İstanbul iklim koşullarına uygun, kış sezonu aktif"
        }
      ],
      "totalValue": 186.30,
      "reasoning": "Müşteri SKINCARE odaklı, Altın sadakat üyesi, aktif alıcı. Kış mevsiminde cilt bakım ürünleri öne çıkarıldı."
    },
    {
      "campaignType": "REPLENISHMENT_REMINDER",
      "title": "Düzenli Ürünlerin Bitmek Üzere",
      "products": [
        {
          "productId": "P-2001",
          "productName": "Dr. C. Tuna Tea Tree Face Wash",
          "reason": "Son alım 35 gün önce, ortalama alım döngüsü 30 gün — 5 gün gecikmiş"
        }
      ],
      "reasoning": "Müşterinin düzenli aldığı ürünün zamanı gelmiş, hatırlatma kampanyası."
    }
  ],
  "decisionTrace": {
    "productAgentUsed": true,
    "customerAgentUsed": true,
    "signalsUsed": ["categoryAffinity", "seasonalRelevance", "replenishment", "loyalty"],
    "budgetCheck": "186.30 TL < 205.00 TL tahmini bütçe — uygun"
  }
}
```

---

## 9. Gerçek Test Çıktısı (Farmasi — 40 Ürün)

Aşağıdaki sonuçlar `test/request.json` ile lokal çalıştırma sonucunda elde edilmiştir (2026-02-12):

### heroProducts (10 ürün)

| # | Ürün | Segment | Stok Günü | Trend | Aksiyon |
|---|------|---------|-----------|-------|---------|
| 1 | Glow Boost Vitamin C Serum | Star | 7.4 | 95 | RESTOCK |
| 2 | BB Krem Doğal Ton SPF25 | Rising | 1200 | 94 | FEATURE |
| 3 | Niacinamide Gözenek Tonik | Rising | 810 | 93 | FEATURE |
| 4 | Hyaluronic Acid Krem | Star | 8.3 | 91 | RESTOCK |
| 5 | Probiyotik Kapsül | Rising | 619 | 90 | FEATURE |
| 6 | Matte Lipstick Red Velvet | Star | 8.7 | 90 | RESTOCK |
| 7 | Collagen Peptide Ampul | Rising | 731 | 89 | FEATURE |
| 8 | Retinol Gece Kremi | Star | 6.8 | 88 | RESTOCK |
| 9 | Keratin Saç Maskesi | Star | 13.3 | 87 | RESTOCK |
| 10 | Prestige Erkek Parfümü | Star | 5.9 | 86 | RESTOCK |

### slowMovers (15 ürün)
Omega-3 (stockDays: 33750), Bebek Şampuanı (26100), Matcha Diş Macunu (9300) ve 12 diğer Underperformer ürün.

### newProducts (4 ürün)
BB Krem (trend:94), Niacinamide Tonik (93), Probiyotik (90), Collagen Ampul (89)

### seasonalProducts (2 ürün)
- Dr C Tuna Age Reversist Krem — Kış, 3 şehirde iklim eşleşmesi
- Kış Bakım Seti Dudak+El Kremi — Kış, 3 şehirde iklim eşleşmesi

### inventorySummary
- Toplam ürün: 40
- Toplam stok değeri: 582,098 TL
- Kritik stok: 9 ürün
- Fazla stok: 30 ürün
- Sağlıklı stok: 1 ürün

---

## 10. Dosya Yapısı

```
project/
├── product_analysis_agent.py          # Ana agent kodu
├── requirements.txt                    # Python bağımlılıkları
├── Dockerfile                          # Container build
├── .bedrock_agentcore.yaml            # AgentCore konfigürasyonu
├── agents/
│   ├── PRODUCT_ANALYSIS_AGENT.md      # Detaylı spec (segmentasyon tabloları)
│   ├── PRODUCT_ANALYSIS_AGENT_GUIDE.md # Bu doküman
│   └── CUSTOMER_ANALYSIS_AGENT.md     # Customer agent spec
├── product-analysis-agent-api.md      # API referans dokümanı
├── data/
│   └── products.json                  # Farmasi ürün kataloğu (40 ürün)
├── test/
│   ├── request.json                   # Örnek input (40 ürün + siparişler)
│   └── response.json                  # Örnek output
└── .kiro/specs/product-analysis-strands-agent/
    ├── requirements.md                # 15 gereksinim
    ├── design.md                      # 19 correctness property
    └── tasks.md                       # 19 implementasyon görevi
```

---

## 11. Hata Yönetimi

### Yaygın Hatalar

| Hata | Sebep | Çözüm |
|------|-------|-------|
| `Missing required field: tenantId` | Input'ta tenantId yok | tenantId ekle |
| `Products array cannot be empty` | Boş products dizisi | En az 1 ürün gönder |
| `Invalid currentMonth` | Ay 1-12 aralığında değil | Geçerli ay değeri gönder |
| `seasonalProducts: []` | climateData alan isimleri yanlış | `avgTempC`, `humidityPct`, `rainfallMm`, `seasonTag` kullan |
| `400 error (Sandbox)` | Input formatı yanlış | `{"prompt": "JSON_STRING"}` formatında gönder |

### Campaign Agent İçin Hata Stratejisi

```python
async def safe_invoke_product_agent(product_input):
    """Hata durumunda boş insight döndür, campaign agent çalışmaya devam etsin."""
    try:
        return await invoke_product_agent(product_input)
    except Exception as e:
        logger.error(f"Product agent hatası: {e}")
        return {
            "heroProducts": [],
            "slowMovers": [],
            "newProducts": [],
            "seasonalProducts": [],
            "categoryInsights": {},
            "priceSegmentAnalysis": {},
            "inventorySummary": {
                "totalProducts": 0,
                "totalStockValue": 0,
                "criticalStockProducts": 0,
                "excessStockProducts": 0,
                "healthyStockProducts": 0,
                "avgStockDays": 0,
                "inventoryTurnoverRate": 0
            }
        }
```

---

## 12. Önemli Notlar

1. **Paralel çağrı:** Product ve Customer agent'ları birbirinden bağımsızdır, paralel çağrılabilir
2. **Deterministik:** Aynı input her zaman aynı output'u üretir (ML/LLM yok)
3. **stockDays hesabı:** Son 90 günlük sipariş geçmişi kullanılır — sipariş yoksa stockDays = 999
4. **Rising önceliği:** NEW + trendScore > 85 olan ürünler Rising olur, Star olamaz
5. **climateData zorunlu alan isimleri:** `avgTempC`, `humidityPct`, `rainfallMm`, `seasonTag`
6. **Multi-tenant:** Her çağrıda tenantId zorunlu
7. **Redeployment:** Kod değişikliği sonrası `agentcore deploy` ile yeniden deploy gerekir

---

**Doküman Versiyonu:** 1.0
**Son Güncelleme:** 2026-02-12
**Agent Versiyonu:** product_analysis_agent_kiro v1.0
