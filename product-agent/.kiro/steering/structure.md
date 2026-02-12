# Project Structure

## Overview

Campaign Intelligence System - AI destekli kampanya yönetim platformu.

## Directory Organization

```
.
├── .kiro/              # Kiro configuration
│   └── steering/       # AI assistant guidance
├── .vscode/            # VSCode settings
├── ARCHITECTURE.md     # Sistem mimarisi (detaylı)
└── dokuman.txt         # Orijinal doküman (referans)
```

## Veri Katmanları

### 1. Raw Transactional
- order, cart, product tabloları
- Ham işlem verileri

### 2. Profile & Signals
- customer_budget_profile
- customer_loyalty_profile
- customer_category_affinity
- customer_replenishment_profile
- customer_variety_profile
- geo_climate_monthly

### 3. Decision Trace
- ai_generation_run
- ai_decision_log
- campaign_proposal
- campaign_evaluation

## Naming Conventions

### Database
- snake_case tablo ve kolon isimleri
- uuid primary key'ler
- tenant_id her tabloda (multi-tenancy)
- created_at, updated_at timestamp alanları

### Code
- Teknoloji stack belirlendikçe güncellenecek
