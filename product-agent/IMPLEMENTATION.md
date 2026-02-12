# 🛠️ Implementation Guide
## Campaign Intelligence System - Adım Adım Uygulama Kılavuzu

---

## 📋 İçindekiler

1. [Proje Kurulumu](#1-proje-kurulumu)
2. [Database Setup](#2-database-setup)
3. [Backend Implementation](#3-backend-implementation)
4. [AI Agent Pipeline](#4-ai-agent-pipeline)
5. [Batch Jobs](#5-batch-jobs)
6. [API Endpoints](#6-api-endpoints)
7. [Frontend Implementation](#7-frontend-implementation)
8. [Testing & Deployment](#8-testing--deployment)

---

## 1. Proje Kurulumu

### 1.1 Teknoloji Stack Seçimi

**Önerilen Stack:**
```
Backend:  Node.js + NestJS (TypeScript)
Database: PostgreSQL 15+
Cache:    Redis 7+
AI/ML:    LangChain + OpenAI API
Queue:    BullMQ (Redis-based)
```

**Alternatif Stack:**
```
Backend:  Python + FastAPI
Database: PostgreSQL 15+
Cache:    Redis 7+
AI/ML:    LangChain + Anthropic Claude
Queue:    Celery + Redis
```

### 1.2 Proje Yapısı (NestJS)

```
campaign-intelligence/
├── src/
│   ├── modules/
│   │   ├── tenant/
│   │   ├── customer/
│   │   ├── product/
│   │   ├── campaign/
│   │   ├── profile/          # Profile calculation
│   │   ├── ai-agent/         # AI orchestration
│   │   └── analytics/
│   ├── common/
│   │   ├── database/
│   │   ├── dto/
│   │   └── utils/
│   └── main.ts
├── prisma/
│   └── schema.prisma
├── test/
└── package.json
```


### 1.3 Başlangıç Komutları

```bash
# Proje oluştur
npm i -g @nestjs/cli
nest new campaign-intelligence
cd campaign-intelligence

# Gerekli paketler
npm install @prisma/client prisma
npm install @nestjs/config @nestjs/bull bull
npm install langchain openai
npm install redis ioredis
npm install class-validator class-transformer

# Dev dependencies
npm install -D @types/node typescript ts-node
```

---

## 2. Database Setup

### 2.1 Prisma Schema Oluşturma

**prisma/schema.prisma** dosyasını oluştur:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Tenant
model Tenant {
  id         String   @id @default(uuid())
  name       String
  createdAt  DateTime @default(now()) @map("created_at")
  
  customers  Customer[]
  products   Product[]
  campaigns  Campaign[]
  cities     City[]
  
  @@map("tenant")
}

// City & Climate
model City {
  id          String   @id @default(uuid()) @map("city_id")
  tenantId    String   @map("tenant_id")
  countryCode String   @map("country_code") @db.Char(2)
  name        String
  regionCode  String?  @map("region_code")
  latitude    Decimal? @db.Decimal(9, 6)
  longitude   Decimal? @db.Decimal(9, 6)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id])
  customers   Customer[]
  climateData GeoClimateMonthly[]
  
  @@map("city")
}

model GeoClimateMonthly {
  id          String   @id @default(uuid()) @map("climate_id")
  tenantId    String   @map("tenant_id")
  cityId      String   @map("city_id")
  month       Int
  avgTempC    Decimal? @map("avg_temp_c") @db.Decimal(5, 2)
  rainfallMm  Decimal? @map("rainfall_mm") @db.Decimal(8, 2)
  humidityPct Decimal? @map("humidity_pct") @db.Decimal(5, 2)
  seasonTag   String?  @map("season_tag")
  
  city        City     @relation(fields: [cityId], references: [id])
  
  @@unique([cityId, month])
  @@map("geo_climate_monthly")
}

// Customer
model Customer {
  id        String    @id @default(uuid()) @map("customer_id")
  tenantId  String    @map("tenant_id")
  email     String?
  phone     String?
  birthDate DateTime? @map("birth_date") @db.Date
  gender    String?
  cityId    String?   @map("city_id")
  isActive  Boolean   @default(true) @map("is_active")
  createdAt DateTime  @default(now()) @map("created_at")
  
  tenant    Tenant    @relation(fields: [tenantId], references: [id])
  city      City?     @relation(fields: [cityId], references: [id])
  
  orders    Order[]
  carts     Cart[]
  budgetProfile       CustomerBudgetProfile?
  loyaltyProfile      CustomerLoyaltyProfile?
  categoryAffinities  CustomerCategoryAffinity[]
  replenishmentProfiles CustomerReplenishmentProfile[]
  varietyProfile      CustomerVarietyProfile?
  
  @@map("customer")
}

// Profile Tables
model CustomerBudgetProfile {
  tenantId              String   @map("tenant_id")
  customerId            String   @map("customer_id")
  predictedMonthlyBudget Decimal? @map("predicted_monthly_budget") @db.Decimal(18, 2)
  budgetTier            String?  @map("budget_tier")
  avgOrderValue         Decimal? @map("avg_order_value") @db.Decimal(18, 2)
  spendLast30           Decimal? @map("spend_last_30") @db.Decimal(18, 2)
  spendLast90           Decimal? @map("spend_last_90") @db.Decimal(18, 2)
  priceSensitivityScore Decimal? @map("price_sensitivity_score") @db.Decimal(5, 2)
  updatedAt             DateTime @updatedAt @map("updated_at")
  
  customer              Customer @relation(fields: [customerId], references: [id])
  
  @@id([tenantId, customerId])
  @@map("customer_budget_profile")
}

model CustomerLoyaltyProfile {
  tenantId         String   @map("tenant_id")
  customerId       String   @map("customer_id")
  loyaltyTier      String   @map("loyalty_tier")
  loyaltyScore     Decimal? @map("loyalty_score") @db.Decimal(5, 2)
  lifetimeOrders   Int      @map("lifetime_orders")
  lifetimeSpent    Decimal  @map("lifetime_spent") @db.Decimal(18, 2)
  daysSinceLastOrder Int?   @map("days_since_last_order")
  rewardMultiplier Decimal? @map("reward_multiplier") @db.Decimal(5, 2)
  updatedAt        DateTime @updatedAt @map("updated_at")
  
  customer         Customer @relation(fields: [customerId], references: [id])
  
  @@id([tenantId, customerId])
  @@map("customer_loyalty_profile")
}

model CustomerCategoryAffinity {
  tenantId        String   @map("tenant_id")
  customerId      String   @map("customer_id")
  categoryId      String   @map("category_id")
  affinityScore   Decimal? @map("affinity_score") @db.Decimal(5, 2)
  ordersCount     Int      @map("orders_count")
  spendTotal      Decimal  @map("spend_total") @db.Decimal(18, 2)
  lastPurchasedAt DateTime? @map("last_purchased_at")
  updatedAt       DateTime @updatedAt @map("updated_at")
  
  customer        Customer @relation(fields: [customerId], references: [id])
  category        Category @relation(fields: [categoryId], references: [id])
  
  @@id([tenantId, customerId, categoryId])
  @@map("customer_category_affinity")
}

model CustomerReplenishmentProfile {
  tenantId                  String    @map("tenant_id")
  customerId                String    @map("customer_id")
  productId                 String    @map("product_id")
  replenishmentCycleDays    Int?      @map("replenishment_cycle_days")
  isRecurring               Boolean   @map("is_recurring")
  lastPurchasedAt           DateTime? @map("last_purchased_at")
  previousPurchasedAt       DateTime? @map("previous_purchased_at")
  currentCycleStart         DateTime? @map("current_cycle_start") @db.Date
  currentCycleEnd           DateTime? @map("current_cycle_end") @db.Date
  purchasedInCurrentCycle   Boolean   @map("purchased_in_current_cycle")
  nextExpectedPurchaseAt    DateTime? @map("next_expected_purchase_at")
  confidenceScore           Decimal?  @map("confidence_score") @db.Decimal(5, 2)
  updatedAt                 DateTime  @updatedAt @map("updated_at")
  
  customer                  Customer  @relation(fields: [customerId], references: [id])
  product                   Product   @relation(fields: [productId], references: [id])
  
  @@id([tenantId, customerId, productId])
  @@map("customer_replenishment_profile")
}

model CustomerVarietyProfile {
  tenantId          String   @map("tenant_id")
  customerId        String   @map("customer_id")
  varietyIndex      Decimal? @map("variety_index") @db.Decimal(5, 2)
  repeatRatio       Decimal? @map("repeat_ratio") @db.Decimal(5, 2)
  uniqueSkuLast90   Int?     @map("unique_sku_last_90")
  totalItemsLast90  Int?     @map("total_items_last_90")
  explorerType      String?  @map("explorer_type")
  updatedAt         DateTime @updatedAt @map("updated_at")
  
  customer          Customer @relation(fields: [customerId], references: [id])
  
  @@id([tenantId, customerId])
  @@map("customer_variety_profile")
}
```

### 2.2 Migration Çalıştırma

```bash
# .env dosyası oluştur
DATABASE_URL="postgresql://user:password@localhost:5432/campaign_db"

# Prisma migration
npx prisma migrate dev --name init
npx prisma generate
```


### 2.3 Seed Data Oluşturma

**prisma/seed.ts** dosyası:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Tenant oluştur
  const tenant = await prisma.tenant.create({
    data: {
      name: 'Demo E-commerce',
    },
  });

  // Şehirler
  const istanbul = await prisma.city.create({
    data: {
      tenantId: tenant.id,
      countryCode: 'TR',
      name: 'İstanbul',
      regionCode: 'MARMARA',
      latitude: 41.0082,
      longitude: 28.9784,
    },
  });

  // İklim verileri (Ocak-Aralık)
  const climateData = [
    { month: 1, avgTempC: 6, rainfallMm: 105, seasonTag: 'WINTER' },
    { month: 2, avgTempC: 7, rainfallMm: 78, seasonTag: 'WINTER' },
    { month: 3, avgTempC: 9, rainfallMm: 71, seasonTag: 'SPRING' },
    // ... diğer aylar
    { month: 12, avgTempC: 8, rainfallMm: 125, seasonTag: 'WINTER' },
  ];

  for (const data of climateData) {
    await prisma.geoClimateMonthly.create({
      data: {
        tenantId: tenant.id,
        cityId: istanbul.id,
        ...data,
        humidityPct: 75,
      },
    });
  }

  console.log('Seed completed!');
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
```

```bash
# Seed çalıştır
npx prisma db seed
```

---

## 3. Backend Implementation

### 3.1 Profile Service Oluşturma

**src/modules/profile/profile.service.ts**:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/database/prisma.service';

@Injectable()
export class ProfileService {
  constructor(private prisma: PrismaService) {}

  // Budget Profile Hesaplama
  async calculateBudgetProfile(customerId: string) {
    // Son 90 günlük siparişleri al
    const orders = await this.prisma.order.findMany({
      where: {
        customerId,
        createdAt: {
          gte: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000),
        },
      },
      include: { items: true },
    });

    const spendLast90 = orders.reduce((sum, order) => 
      sum + order.items.reduce((s, item) => s + item.price * item.quantity, 0), 0
    );

    const spendLast30 = orders
      .filter(o => o.createdAt >= new Date(Date.now() - 30 * 24 * 60 * 60 * 1000))
      .reduce((sum, order) => 
        sum + order.items.reduce((s, item) => s + item.price * item.quantity, 0), 0
      );

    const avgOrderValue = orders.length > 0 ? spendLast90 / orders.length : 0;
    const predictedMonthlyBudget = spendLast90 / 3; // 3 aylık ortalama

    // Budget tier belirleme
    let budgetTier = 'LOW';
    if (predictedMonthlyBudget > 2000) budgetTier = 'PREMIUM';
    else if (predictedMonthlyBudget > 1000) budgetTier = 'HIGH';
    else if (predictedMonthlyBudget > 500) budgetTier = 'MID';

    // Kaydet
    return await this.prisma.customerBudgetProfile.upsert({
      where: {
        tenantId_customerId: {
          tenantId: (await this.prisma.customer.findUnique({ 
            where: { id: customerId } 
          })).tenantId,
          customerId,
        },
      },
      create: {
        tenantId: (await this.prisma.customer.findUnique({ 
          where: { id: customerId } 
        })).tenantId,
        customerId,
        predictedMonthlyBudget,
        budgetTier,
        avgOrderValue,
        spendLast30,
        spendLast90,
        priceSensitivityScore: 50, // Placeholder
      },
      update: {
        predictedMonthlyBudget,
        budgetTier,
        avgOrderValue,
        spendLast30,
        spendLast90,
      },
    });
  }

  // Loyalty Profile Hesaplama
  async calculateLoyaltyProfile(customerId: string) {
    const customer = await this.prisma.customer.findUnique({
      where: { id: customerId },
      include: { orders: true },
    });

    const lifetimeOrders = customer.orders.length;
    const lifetimeSpent = customer.orders.reduce((sum, order) => 
      sum + order.totalAmount, 0
    );

    const lastOrder = customer.orders.sort((a, b) => 
      b.createdAt.getTime() - a.createdAt.getTime()
    )[0];

    const daysSinceLastOrder = lastOrder 
      ? Math.floor((Date.now() - lastOrder.createdAt.getTime()) / (1000 * 60 * 60 * 24))
      : null;

    // Loyalty tier belirleme
    let loyaltyTier = 'NEW';
    let rewardMultiplier = 1.0;

    if (lifetimeOrders >= 20 && lifetimeSpent >= 10000) {
      loyaltyTier = 'PLATINUM';
      rewardMultiplier = 2.0;
    } else if (lifetimeOrders >= 10 && lifetimeSpent >= 5000) {
      loyaltyTier = 'GOLD';
      rewardMultiplier = 1.5;
    } else if (lifetimeOrders >= 5 && lifetimeSpent >= 2000) {
      loyaltyTier = 'SILVER';
      rewardMultiplier = 1.2;
    } else if (lifetimeOrders >= 2) {
      loyaltyTier = 'BRONZE';
      rewardMultiplier = 1.1;
    }

    const loyaltyScore = Math.min(100, (lifetimeOrders * 5) + (lifetimeSpent / 100));

    return await this.prisma.customerLoyaltyProfile.upsert({
      where: {
        tenantId_customerId: {
          tenantId: customer.tenantId,
          customerId,
        },
      },
      create: {
        tenantId: customer.tenantId,
        customerId,
        loyaltyTier,
        loyaltyScore,
        lifetimeOrders,
        lifetimeSpent,
        daysSinceLastOrder,
        rewardMultiplier,
      },
      update: {
        loyaltyTier,
        loyaltyScore,
        lifetimeOrders,
        lifetimeSpent,
        daysSinceLastOrder,
        rewardMultiplier,
      },
    });
  }

  // Tüm profilleri hesapla
  async calculateAllProfiles(customerId: string) {
    await Promise.all([
      this.calculateBudgetProfile(customerId),
      this.calculateLoyaltyProfile(customerId),
      // Diğer profiller...
    ]);
  }
}
```


---

## 4. AI Agent Pipeline

### 4.1 Customer Signals DTO

**src/modules/ai-agent/dto/customer-signals.dto.ts**:

```typescript
export class CustomerSignalsDto {
  customerId: string;
  
  // Budget
  budgetTier: string;
  predictedMonthlyBudget: number;
  avgOrderValue: number;
  priceSensitivityScore: number;
  
  // Loyalty
  loyaltyTier: string;
  loyaltyScore: number;
  rewardMultiplier: number;
  lifetimeOrders: number;
  lifetimeSpent: number;
  
  // Category Affinity (top 3)
  topCategories: Array<{
    categoryId: string;
    categoryName: string;
    affinityScore: number;
    spendTotal: number;
  }>;
  
  // Replenishment
  replenishmentGaps: Array<{
    productId: string;
    productName: string;
    daysSinceExpected: number;
    cycleDays: number;
  }>;
  
  // Variety
  explorerType: string;
  varietyIndex: number;
  repeatRatio: number;
  
  // Geo/Climate
  city: {
    name: string;
    currentMonth: number;
    avgTempC: number;
    rainfallMm: number;
    seasonTag: string;
  };
  
  // Current Cart (if any)
  cart?: {
    itemCount: number;
    totalAmount: number;
    items: Array<{
      productId: string;
      productName: string;
      quantity: number;
      price: number;
    }>;
  };
}
```

### 4.2 Signal Collection Service

**src/modules/ai-agent/signal-collector.service.ts**:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/database/prisma.service';
import { CustomerSignalsDto } from './dto/customer-signals.dto';

@Injectable()
export class SignalCollectorService {
  constructor(private prisma: PrismaService) {}

  async collectCustomerSignals(customerId: string, cartId?: string): Promise<CustomerSignalsDto> {
    const customer = await this.prisma.customer.findUnique({
      where: { id: customerId },
      include: {
        budgetProfile: true,
        loyaltyProfile: true,
        categoryAffinities: {
          orderBy: { affinityScore: 'desc' },
          take: 3,
          include: { category: true },
        },
        replenishmentProfiles: {
          where: { purchasedInCurrentCycle: false },
          include: { product: true },
        },
        varietyProfile: true,
        city: {
          include: {
            climateData: {
              where: { month: new Date().getMonth() + 1 },
            },
          },
        },
      },
    });

    const signals: CustomerSignalsDto = {
      customerId,
      
      // Budget
      budgetTier: customer.budgetProfile?.budgetTier || 'UNKNOWN',
      predictedMonthlyBudget: Number(customer.budgetProfile?.predictedMonthlyBudget || 0),
      avgOrderValue: Number(customer.budgetProfile?.avgOrderValue || 0),
      priceSensitivityScore: Number(customer.budgetProfile?.priceSensitivityScore || 50),
      
      // Loyalty
      loyaltyTier: customer.loyaltyProfile?.loyaltyTier || 'NEW',
      loyaltyScore: Number(customer.loyaltyProfile?.loyaltyScore || 0),
      rewardMultiplier: Number(customer.loyaltyProfile?.rewardMultiplier || 1.0),
      lifetimeOrders: customer.loyaltyProfile?.lifetimeOrders || 0,
      lifetimeSpent: Number(customer.loyaltyProfile?.lifetimeSpent || 0),
      
      // Category Affinity
      topCategories: customer.categoryAffinities.map(ca => ({
        categoryId: ca.categoryId,
        categoryName: ca.category.name,
        affinityScore: Number(ca.affinityScore),
        spendTotal: Number(ca.spendTotal),
      })),
      
      // Replenishment Gaps
      replenishmentGaps: customer.replenishmentProfiles
        .filter(rp => rp.nextExpectedPurchaseAt && rp.nextExpectedPurchaseAt < new Date())
        .map(rp => ({
          productId: rp.productId,
          productName: rp.product.name,
          daysSinceExpected: Math.floor(
            (Date.now() - rp.nextExpectedPurchaseAt.getTime()) / (1000 * 60 * 60 * 24)
          ),
          cycleDays: rp.replenishmentCycleDays,
        })),
      
      // Variety
      explorerType: customer.varietyProfile?.explorerType || 'BALANCED',
      varietyIndex: Number(customer.varietyProfile?.varietyIndex || 50),
      repeatRatio: Number(customer.varietyProfile?.repeatRatio || 50),
      
      // Geo/Climate
      city: customer.city ? {
        name: customer.city.name,
        currentMonth: new Date().getMonth() + 1,
        avgTempC: Number(customer.city.climateData[0]?.avgTempC || 0),
        rainfallMm: Number(customer.city.climateData[0]?.rainfallMm || 0),
        seasonTag: customer.city.climateData[0]?.seasonTag || 'UNKNOWN',
      } : null,
    };

    // Cart bilgisi varsa ekle
    if (cartId) {
      const cart = await this.prisma.cart.findUnique({
        where: { id: cartId },
        include: {
          items: {
            include: { product: true },
          },
        },
      });

      if (cart) {
        signals.cart = {
          itemCount: cart.items.length,
          totalAmount: Number(cart.totalAmount),
          items: cart.items.map(item => ({
            productId: item.productId,
            productName: item.product.name,
            quantity: item.quantity,
            price: Number(item.price),
          })),
        };
      }
    }

    return signals;
  }
}
```


### 4.3 AI Agent Service (LangChain)

**src/modules/ai-agent/ai-agent.service.ts**:

```typescript
import { Injectable } from '@nestjs/common';
import { ChatOpenAI } from 'langchain/chat_models/openai';
import { HumanMessage, SystemMessage } from 'langchain/schema';
import { CustomerSignalsDto } from './dto/customer-signals.dto';

@Injectable()
export class AIAgentService {
  private llm: ChatOpenAI;

  constructor() {
    this.llm = new ChatOpenAI({
      modelName: 'gpt-4',
      temperature: 0.7,
      openAIApiKey: process.env.OPENAI_API_KEY,
    });
  }

  async generatePersonalizedCampaign(signals: CustomerSignalsDto) {
    const systemPrompt = `You are a Campaign Strategist AI for an e-commerce platform.
Your goal is to create personalized campaign offers based on customer signals.

Consider these 6 key dimensions:
1. Budget: Customer's spending capacity and price sensitivity
2. Loyalty: Reward tier and lifetime value
3. Category Affinity: Preferred product categories
4. Replenishment: Products due for restock
5. Variety: Explorer vs Repeat buyer behavior
6. Geo/Seasonal: Location and climate-based relevance

Output format (JSON):
{
  "campaignType": "BUNDLE|THRESHOLD|GIFT|DISCOUNT",
  "title": "Campaign title",
  "description": "User-friendly description",
  "targetAmount": number (if threshold),
  "discountPercent": number (if discount),
  "reasoning": {
    "budget": "explanation",
    "loyalty": "explanation",
    "category": "explanation",
    "replenishment": "explanation",
    "variety": "explanation",
    "seasonal": "explanation"
  },
  "recommendedProducts": [
    {
      "reason": "why this product",
      "priority": "HIGH|MEDIUM|LOW"
    }
  ],
  "confidence": number (0-100),
  "expectedImpact": "description"
}`;

    const userPrompt = `Generate a personalized campaign for this customer:

CUSTOMER SIGNALS:
${JSON.stringify(signals, null, 2)}

Create the most relevant campaign offer considering all 6 dimensions.`;

    const response = await this.llm.call([
      new SystemMessage(systemPrompt),
      new HumanMessage(userPrompt),
    ]);

    return JSON.parse(response.content);
  }

  async generateCompanyCampaign(goal: string, constraints: any, target: any) {
    const systemPrompt = `You are a Campaign Orchestrator AI.
Generate 3-5 campaign proposals for company-level campaigns.

Consider:
- Strategic goal (STOCK_CLEARANCE, AOV_INCREASE, LOYALTY_REWARD, etc.)
- Budget constraints
- Target audience
- Seasonal relevance
- Profit margins

Output format (JSON):
{
  "proposals": [
    {
      "name": "Campaign name",
      "type": "BUNDLE|THRESHOLD|GIFT",
      "targetProfile": {
        "budgetTier": "LOW|MID|HIGH|PREMIUM",
        "loyaltyTier": "NEW|BRONZE|SILVER|GOLD|PLATINUM",
        "ageRange": [min, max],
        "cities": ["city1", "city2"]
      },
      "productSelection": {
        "include": ["criteria"],
        "exclude": ["criteria"]
      },
      "expectedROI": number,
      "risk": "LOW|MEDIUM|HIGH",
      "reasoning": "detailed explanation",
      "confidence": number (0-100)
    }
  ]
}`;

    const userPrompt = `Generate campaign proposals:

GOAL: ${goal}
CONSTRAINTS: ${JSON.stringify(constraints, null, 2)}
TARGET: ${JSON.stringify(target, null, 2)}

Provide 3-5 diverse proposals.`;

    const response = await this.llm.call([
      new SystemMessage(systemPrompt),
      new HumanMessage(userPrompt),
    ]);

    return JSON.parse(response.content);
  }
}
```

---

## 5. Batch Jobs

### 5.1 Profile Calculation Job

**src/modules/profile/jobs/profile-calculation.processor.ts**:

```typescript
import { Processor, Process } from '@nestjs/bull';
import { Job } from 'bull';
import { ProfileService } from '../profile.service';
import { PrismaService } from '../../common/database/prisma.service';

@Processor('profile-calculation')
export class ProfileCalculationProcessor {
  constructor(
    private profileService: ProfileService,
    private prisma: PrismaService,
  ) {}

  @Process('calculate-all-customers')
  async handleCalculateAllCustomers(job: Job) {
    const { tenantId } = job.data;

    const customers = await this.prisma.customer.findMany({
      where: { tenantId, isActive: true },
      select: { id: true },
    });

    let processed = 0;
    for (const customer of customers) {
      try {
        await this.profileService.calculateAllProfiles(customer.id);
        processed++;
        await job.progress((processed / customers.length) * 100);
      } catch (error) {
        console.error(`Error processing customer ${customer.id}:`, error);
      }
    }

    return { processed, total: customers.length };
  }

  @Process('calculate-single-customer')
  async handleCalculateSingleCustomer(job: Job) {
    const { customerId } = job.data;
    await this.profileService.calculateAllProfiles(customerId);
    return { customerId, status: 'completed' };
  }
}
```

### 5.2 Job Scheduler

**src/modules/profile/profile-scheduler.service.ts**:

```typescript
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { PrismaService } from '../common/database/prisma.service';

@Injectable()
export class ProfileSchedulerService {
  constructor(
    @InjectQueue('profile-calculation') private profileQueue: Queue,
    private prisma: PrismaService,
  ) {}

  // Her gün gece 2'de tüm profilleri güncelle
  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async scheduleDailyProfileUpdate() {
    const tenants = await this.prisma.tenant.findMany();

    for (const tenant of tenants) {
      await this.profileQueue.add('calculate-all-customers', {
        tenantId: tenant.id,
      });
    }
  }

  // Manuel tetikleme
  async triggerProfileCalculation(customerId: string) {
    await this.profileQueue.add('calculate-single-customer', {
      customerId,
    });
  }
}
```


---

## 6. API Endpoints

### 6.1 Campaign Controller

**src/modules/campaign/campaign.controller.ts**:

```typescript
import { Controller, Post, Get, Body, Param, Query } from '@nestjs/common';
import { AIAgentService } from '../ai-agent/ai-agent.service';
import { SignalCollectorService } from '../ai-agent/signal-collector.service';

@Controller('campaigns')
export class CampaignController {
  constructor(
    private aiAgentService: AIAgentService,
    private signalCollector: SignalCollectorService,
  ) {}

  // Admin: Kampanya önerisi oluştur
  @Post('generate/company')
  async generateCompanyCampaign(@Body() dto: {
    goal: string;
    constraints: any;
    target: any;
  }) {
    return await this.aiAgentService.generateCompanyCampaign(
      dto.goal,
      dto.constraints,
      dto.target,
    );
  }

  // Customer: Kişiselleştirilmiş kampanya
  @Post('generate/personal')
  async generatePersonalCampaign(@Body() dto: {
    customerId: string;
    cartId?: string;
  }) {
    // Sinyalleri topla
    const signals = await this.signalCollector.collectCustomerSignals(
      dto.customerId,
      dto.cartId,
    );

    // AI ile kampanya üret
    const campaign = await this.aiAgentService.generatePersonalizedCampaign(signals);

    // Decision log kaydet
    // ... (implementation)

    return {
      signals,
      campaign,
    };
  }

  // Customer: Yakın olduğu kampanyalar
  @Get('near/:customerId')
  async getNearCampaigns(@Param('customerId') customerId: string) {
    // Aktif kampanyaları değerlendir
    // Gap hesapla
    // ... (implementation)
    
    return {
      nearCampaigns: [],
    };
  }

  // Customer: Decision trace görüntüle
  @Get('decision-trace/:customerId')
  async getDecisionTrace(@Param('customerId') customerId: string) {
    const signals = await this.signalCollector.collectCustomerSignals(customerId);
    
    return {
      customerId,
      signals,
      visualizations: {
        budgetGauge: {
          current: signals.predictedMonthlyBudget,
          tier: signals.budgetTier,
        },
        loyaltyProgress: {
          current: signals.loyaltyTier,
          score: signals.loyaltyScore,
          multiplier: signals.rewardMultiplier,
        },
        categoryChart: signals.topCategories,
        replenishmentList: signals.replenishmentGaps,
        varietyType: signals.explorerType,
        climateInfo: signals.city,
      },
    };
  }
}
```

### 6.2 Profile Controller

**src/modules/profile/profile.controller.ts**:

```typescript
import { Controller, Post, Get, Param } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { ProfileSchedulerService } from './profile-scheduler.service';

@Controller('profiles')
export class ProfileController {
  constructor(
    private profileService: ProfileService,
    private schedulerService: ProfileSchedulerService,
  ) {}

  // Profil hesapla (manuel)
  @Post('calculate/:customerId')
  async calculateProfile(@Param('customerId') customerId: string) {
    await this.schedulerService.triggerProfileCalculation(customerId);
    return { status: 'queued', customerId };
  }

  // Profil görüntüle
  @Get(':customerId')
  async getProfile(@Param('customerId') customerId: string) {
    // Tüm profilleri getir
    // ... (implementation)
    
    return {
      budget: {},
      loyalty: {},
      categoryAffinity: [],
      replenishment: [],
      variety: {},
    };
  }
}
```

---

## 7. Frontend Implementation

### 7.1 Decision Trace Component (React)

**components/DecisionTrace.tsx**:

```typescript
import React, { useEffect, useState } from 'react';
import { Card, Progress, Badge, List } from 'antd';

interface DecisionTraceProps {
  customerId: string;
}

export const DecisionTrace: React.FC<DecisionTraceProps> = ({ customerId }) => {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch(`/api/campaigns/decision-trace/${customerId}`)
      .then(res => res.json())
      .then(setData);
  }, [customerId]);

  if (!data) return <div>Loading...</div>;

  const { visualizations } = data;

  return (
    <div className="decision-trace">
      <h2>AI Karar Profili</h2>

      {/* Budget */}
      <Card title="💰 Budget Profili">
        <div>
          <Badge status="processing" text={visualizations.budgetGauge.tier} />
          <p>Aylık Tahmin: {visualizations.budgetGauge.current} TL</p>
          <Progress 
            percent={40} 
            status="active"
            format={() => `${visualizations.budgetGauge.tier}`}
          />
        </div>
      </Card>

      {/* Loyalty */}
      <Card title="🏆 Sadakat">
        <div>
          <Badge status="success" text={visualizations.loyaltyProgress.current} />
          <p>Skor: {visualizations.loyaltyProgress.score}/100</p>
          <p>Çarpan: {visualizations.loyaltyProgress.multiplier}x</p>
        </div>
      </Card>

      {/* Category Affinity */}
      <Card title="🛍️ Kategori Eğilimi">
        <List
          dataSource={visualizations.categoryChart}
          renderItem={item => (
            <List.Item>
              <div style={{ width: '100%' }}>
                <div>{item.categoryName}</div>
                <Progress percent={item.affinityScore} />
              </div>
            </List.Item>
          )}
        />
      </Card>

      {/* Replenishment */}
      <Card title="🔄 Dönemsel Ürünler">
        <List
          dataSource={visualizations.replenishmentList}
          renderItem={item => (
            <List.Item>
              <Badge status="warning" />
              {item.productName} ({item.daysSinceExpected} gün geçti)
            </List.Item>
          )}
        />
      </Card>

      {/* Variety */}
      <Card title="🎲 Alışveriş Tipi">
        <Badge 
          status={visualizations.varietyType === 'EXPLORER' ? 'processing' : 'default'}
          text={visualizations.varietyType}
        />
      </Card>

      {/* Climate */}
      <Card title="🌍 Konum & İklim">
        <p>Şehir: {visualizations.climateInfo?.name}</p>
        <p>Mevsim: {visualizations.climateInfo?.seasonTag}</p>
        <p>Yağış: {visualizations.climateInfo?.rainfallMm}mm</p>
        <p>Sıcaklık: {visualizations.climateInfo?.avgTempC}°C</p>
      </Card>
    </div>
  );
};
```

