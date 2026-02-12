# Product Analysis Agent API Documentation

## Overview

The Product Analysis Agent is an AI-powered service deployed on Amazon Bedrock AgentCore Runtime that analyzes product data to generate actionable insights for campaign management. This document provides comprehensive integration guidance for both backend and frontend applications.

## Deployment Information

### Agent Details

- **Agent Name**: `product_analysis_agent_kiro`
- **Region**: `us-west-2`
- **AgentCore ARN**: `arn:aws:bedrock-agentcore:us-west-2:853548971581:runtime/product_analysis_agent_kiro-DbG83rES5F`
- **IAM Role ARN**: `arn:aws:iam::853548971581:role/AmazonBedrockAgentCoreSDKRuntime-us-west-2-27930069dd`
- **ECR Repository URI**: `853548971581.dkr.ecr.us-west-2.amazonaws.com/bedrock-agentcore-product_analysis_agent_kiro`
- **Memory ID**: `product_analysis_agent_kiro_mem-Ypo7PD3UlH`
- **Account**: `853548971581`

### Prerequisites

- AWS Account with Bedrock AgentCore access (us-west-2)
- IAM permissions for `bedrock-agentcore:InvokeRuntime`
- AWS SDK configured with appropriate credentials

## API Reference

### Input Schema

The agent accepts JSON input with the following structure:

```json
{
  "tenantId": "string",
  "products": [
    {
      "productId": "string",
      "productName": "string",
      "category": "string",
      "subcategory": "string",
      "brand": "string",
      "season": "string",
      "isSeasonal": boolean,
      "seasonCode": "string",
      "stock": number,
      "currentStock": number,
      "last30DaysSales": number,
      "cost": number,
      "unitCost": number,
      "basePrice": number,
      "unitPrice": number,
      "lifecycleStage": "string",
      "trendScore": number,
      "tags": ["string"],
      "seasonalityRules": [
        {
          "ruleType": "string",
          "threshold": number,
          "thresholdText": "string"
        }
      ]
    }
  ],
  "orderHistory": [
    {
      "orderId": "string",
      "orderDate": "string",
      "items": [
        {
          "productId": "string",
          "quantity": number
        }
      ]
    }
  ],
  "currentMonth": number,
  "climateData": {
    "cityName": {
      "humidityPct": number,
      "avgTempC": number,
      "rainfallMm": number,
      "seasonTag": "string"
    }
  }
}
```

#### Field Descriptions

**Required Fields:**
- `tenantId` (string): Tenant identifier for multi-tenancy support
- `products` (array): Array of product objects (minimum 1 product required)
- `orderHistory` (array): Historical order data (can be empty)
- `currentMonth` (number): Current month (1-12) for seasonal analysis
- `climateData` (object): Climate data by city (can be empty)

**Product Fields:**
- `lifecycleStage`: One of `NEW`, `GROWING`, `MATURE`, `DECLINING`
- `trendScore`: Integer 0-100 indicating product popularity
- `seasonCode`: One of `all`, `WINTER`, `SUMMER`, `SPRING`, `FALL`
- `seasonalityRules`: Array of climate-based rules for seasonal matching

### Output Schema

The agent returns comprehensive product insights in the following structure:

```json
{
  "heroProducts": [
    {
      "productId": "string",
      "productName": "string",
      "category": "string",
      "brand": "string",
      "performanceSegment": "string",
      "stockSegment": "string",
      "lifecycleStage": "string",
      "trendScore": number,
      "stockDays": number,
      "dailySalesRate": number,
      "inventoryPressure": boolean,
      "seasonalRelevance": "string",
      "seasonMatch": boolean,
      "priceSegment": "string",
      "marginHealth": "string",
      "recommendedAction": "string",
      "urgencyLevel": "string",
      "climateMatch": ["string"],
      "matchingCities": ["string"]
    }
  ],
  "slowMovers": [...],
  "newProducts": [...],
  "seasonalProducts": [
    {
      "productId": "string",
      "productName": "string",
      "seasonalRelevance": "string",
      "climateMatch": ["string"],
      "matchingCities": ["string"],
      "recommendedAction": "string"
    }
  ],
  "categoryInsights": {
    "categoryName": {
      "totalProducts": number,
      "avgTrendScore": number,
      "totalStock": number,
      "avgStockDays": number,
      "performanceRating": "string",
      "topPerformers": number,
      "underperformers": number
    }
  },
  "priceSegmentAnalysis": {
    "BUDGET": {
      "priceRange": "string",
      "productCount": number,
      "avgTrendScore": number,
      "stockHealth": "string"
    },
    "MID": {...},
    "PREMIUM": {...}
  },
  "inventorySummary": {
    "totalProducts": number,
    "totalStockValue": number,
    "criticalStockProducts": number,
    "excessStockProducts": number,
    "healthyStockProducts": number,
    "avgStockDays": number,
    "inventoryTurnoverRate": number
  }
}
```

#### Output Field Descriptions

**Product Segments:**
- `heroProducts`: Top 10 Star or Rising products sorted by trend score
- `slowMovers`: Top 15 Excess or Underperformer products sorted by stock days
- `newProducts`: All NEW lifecycle products sorted by trend score
- `seasonalProducts`: Top 10 HIGH seasonal relevance products

**Performance Segments:**
- `Star`: High trend score (>80) with low stock days (<30)
- `Rising`: NEW products with trend score >85
- `Steady`: Moderate trend score (60-80) with manageable stock (<60 days)
- `Underperformer`: Products not meeting other criteria

**Stock Segments:**
- `Critical`: Less than 15 days of inventory
- `Healthy`: 15-60 days of inventory
- `Excess`: More than 60 days of inventory

**Seasonal Relevance:**
- `HIGH`: Season matches and climate rules match
- `MEDIUM`: Season matches but no climate match
- `LOW`: Season does not match

**Recommended Actions:**
- `RESTOCK`: Critical stock on high-performing products
- `FEATURE`: Rising products to promote
- `PROMOTE`: Star products with healthy stock
- `SEASONAL_PUSH`: Seasonally relevant products
- `CLEARANCE`: Excess stock on declining products
- `BUNDLE`: Excess stock with moderate margins
- `DISCOUNT`: Underperforming products
- `MAINTAIN`: Default action for stable products

**Urgency Levels:**
- `CRITICAL`: Immediate action required
- `HIGH`: Action needed soon
- `MEDIUM`: Action recommended
- `LOW`: Monitor and maintain

## Integration Examples

### Python (Backend) - Using boto3

#### Installation

```bash
pip install boto3
```

#### Basic Invocation

```python
import boto3
import json

# Initialize Bedrock Agent Runtime client
client = boto3.client(
    'bedrock-agent-runtime',
    region_name='us-west-2'
)

# Prepare input data
input_data = {
    "tenantId": "farmasi",
    "products": [
        {
            "productId": "PROD001",
            "productName": "Premium Mascara",
            "category": "MAKEUP",
            "subcategory": "Mascara",
            "brand": "Farmasi",
            "season": "all",
            "isSeasonal": False,
            "seasonCode": "all",
            "stock": 450,
            "currentStock": 450,
            "last30DaysSales": 180,
            "cost": 45.00,
            "unitCost": 45.00,
            "basePrice": 89.90,
            "unitPrice": 89.90,
            "lifecycleStage": "MATURE",
            "trendScore": 85,
            "tags": ["mascara", "premium"],
            "seasonalityRules": []
        }
    ],
    "orderHistory": [
        {
            "orderId": "ORD001",
            "orderDate": "2024-01-15",
            "items": [
                {"productId": "PROD001", "quantity": 2}
            ]
        }
    ],
    "currentMonth": 3,
    "climateData": {
        "Istanbul": {
            "humidityPct": 72.5,
            "avgTempC": 12.3,
            "rainfallMm": 85.2,
            "seasonTag": "winter"
        }
    }
}

# Invoke the agent
try:
    response = client.invoke_agent(
        agentId='AGENT_ID',  # Replace with actual agent ID
        agentAliasId='ALIAS_ID',  # Replace with actual alias ID
        sessionId='session-123',  # Unique session identifier
        inputText=json.dumps(input_data)
    )
    
    # Process response
    result = json.loads(response['output'])
    print("Hero Products:", result['heroProducts'])
    print("Inventory Summary:", result['inventorySummary'])
    
except Exception as e:
    print(f"Error invoking agent: {e}")
```

#### Advanced Usage with Error Handling

```python
import boto3
import json
from typing import Dict, Any, Optional

class ProductAnalysisClient:
    """Client for interacting with Product Analysis Agent"""
    
    def __init__(self, agent_id: str, alias_id: str, region: str = 'us-west-2'):
        self.agent_id = agent_id
        self.alias_id = alias_id
        self.client = boto3.client('bedrock-agent-runtime', region_name=region)
    
    def analyze_products(self, input_data: Dict[str, Any], session_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Analyze products and return insights
        
        Args:
            input_data: Product analysis input data
            session_id: Optional session identifier
            
        Returns:
            Product insights dictionary
            
        Raises:
            ValueError: If input validation fails
            RuntimeError: If agent invocation fails
        """
        # Validate input
        self._validate_input(input_data)
        
        # Generate session ID if not provided
        if not session_id:
            import uuid
            session_id = str(uuid.uuid4())
        
        try:
            response = self.client.invoke_agent(
                agentId=self.agent_id,
                agentAliasId=self.alias_id,
                sessionId=session_id,
                inputText=json.dumps(input_data)
            )
            
            return json.loads(response['output'])
            
        except self.client.exceptions.ValidationException as e:
            raise ValueError(f"Input validation failed: {e}")
        except self.client.exceptions.ResourceNotFoundException as e:
            raise RuntimeError(f"Agent not found: {e}")
        except self.client.exceptions.ThrottlingException as e:
            raise RuntimeError(f"Request throttled: {e}")
        except Exception as e:
            raise RuntimeError(f"Agent invocation failed: {e}")
    
    def _validate_input(self, input_data: Dict[str, Any]) -> None:
        """Validate input data structure"""
        required_fields = ['tenantId', 'products', 'orderHistory', 'currentMonth', 'climateData']
        for field in required_fields:
            if field not in input_data:
                raise ValueError(f"Missing required field: {field}")
        
        if not isinstance(input_data['products'], list) or len(input_data['products']) == 0:
            raise ValueError("Products array must contain at least one product")
        
        if not (1 <= input_data['currentMonth'] <= 12):
            raise ValueError("currentMonth must be between 1 and 12")

# Usage example
client = ProductAnalysisClient(
    agent_id='AGENT_ID',
    alias_id='ALIAS_ID'
)

try:
    insights = client.analyze_products(input_data)
    print(f"Analyzed {insights['inventorySummary']['totalProducts']} products")
    print(f"Found {len(insights['heroProducts'])} hero products")
except ValueError as e:
    print(f"Invalid input: {e}")
except RuntimeError as e:
    print(f"Service error: {e}")
```

### JavaScript/TypeScript (Frontend)

#### Installation

```bash
npm install @aws-sdk/client-bedrock-agent-runtime
```

#### Basic Invocation (TypeScript)

```typescript
import { 
  BedrockAgentRuntimeClient, 
  InvokeAgentCommand 
} from "@aws-sdk/client-bedrock-agent-runtime";

// Types
interface ProductAnalysisInput {
  tenantId: string;
  products: Product[];
  orderHistory: Order[];
  currentMonth: number;
  climateData: Record<string, ClimateData>;
}

interface Product {
  productId: string;
  productName: string;
  category: string;
  subcategory: string;
  brand: string;
  season: string;
  isSeasonal: boolean;
  seasonCode: string;
  stock: number;
  currentStock: number;
  last30DaysSales: number;
  cost: number;
  unitCost: number;
  basePrice: number;
  unitPrice: number;
  lifecycleStage: string;
  trendScore: number;
  tags: string[];
  seasonalityRules: SeasonalityRule[];
}

interface Order {
  orderId: string;
  orderDate: string;
  items: OrderItem[];
}

interface OrderItem {
  productId: string;
  quantity: number;
}

interface ClimateData {
  humidityPct: number;
  avgTempC: number;
  rainfallMm: number;
  seasonTag: string;
}

interface SeasonalityRule {
  ruleType: string;
  threshold: number;
  thresholdText: string;
}

interface ProductInsights {
  heroProducts: ProductDetail[];
  slowMovers: ProductDetail[];
  newProducts: ProductDetail[];
  seasonalProducts: SeasonalProduct[];
  categoryInsights: Record<string, CategoryInsight>;
  priceSegmentAnalysis: Record<string, PriceSegmentAnalysis>;
  inventorySummary: InventorySummary;
}

// Initialize client
const client = new BedrockAgentRuntimeClient({
  region: "us-west-2",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

// Analyze products
async function analyzeProducts(
  inputData: ProductAnalysisInput
): Promise<ProductInsights> {
  const command = new InvokeAgentCommand({
    agentId: "AGENT_ID", // Replace with actual agent ID
    agentAliasId: "ALIAS_ID", // Replace with actual alias ID
    sessionId: `session-${Date.now()}`,
    inputText: JSON.stringify(inputData),
  });

  try {
    const response = await client.send(command);
    return JSON.parse(response.output as string);
  } catch (error) {
    console.error("Error invoking agent:", error);
    throw error;
  }
}

// Usage example
const inputData: ProductAnalysisInput = {
  tenantId: "farmasi",
  products: [
    {
      productId: "PROD001",
      productName: "Premium Mascara",
      category: "MAKEUP",
      subcategory: "Mascara",
      brand: "Farmasi",
      season: "all",
      isSeasonal: false,
      seasonCode: "all",
      stock: 450,
      currentStock: 450,
      last30DaysSales: 180,
      cost: 45.0,
      unitCost: 45.0,
      basePrice: 89.9,
      unitPrice: 89.9,
      lifecycleStage: "MATURE",
      trendScore: 85,
      tags: ["mascara", "premium"],
      seasonalityRules: [],
    },
  ],
  orderHistory: [],
  currentMonth: 3,
  climateData: {},
};

analyzeProducts(inputData)
  .then((insights) => {
    console.log("Hero Products:", insights.heroProducts);
    console.log("Inventory Summary:", insights.inventorySummary);
  })
  .catch((error) => {
    console.error("Analysis failed:", error);
  });
```

#### React Hook Example

```typescript
import { useState, useCallback } from 'react';
import { BedrockAgentRuntimeClient, InvokeAgentCommand } from '@aws-sdk/client-bedrock-agent-runtime';

export function useProductAnalysis() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [insights, setInsights] = useState<ProductInsights | null>(null);

  const client = new BedrockAgentRuntimeClient({
    region: 'us-west-2',
    credentials: {
      accessKeyId: process.env.REACT_APP_AWS_ACCESS_KEY_ID!,
      secretAccessKey: process.env.REACT_APP_AWS_SECRET_ACCESS_KEY!,
    },
  });

  const analyzeProducts = useCallback(async (inputData: ProductAnalysisInput) => {
    setLoading(true);
    setError(null);

    try {
      const command = new InvokeAgentCommand({
        agentId: process.env.REACT_APP_AGENT_ID!,
        agentAliasId: process.env.REACT_APP_ALIAS_ID!,
        sessionId: `session-${Date.now()}`,
        inputText: JSON.stringify(inputData),
      });

      const response = await client.send(command);
      const result = JSON.parse(response.output as string);
      setInsights(result);
      return result;
    } catch (err) {
      const error = err as Error;
      setError(error);
      throw error;
    } finally {
      setLoading(false);
    }
  }, [client]);

  return { analyzeProducts, loading, error, insights };
}

// Component usage
function ProductAnalysisComponent() {
  const { analyzeProducts, loading, error, insights } = useProductAnalysis();

  const handleAnalyze = async () => {
    const inputData = {
      tenantId: 'farmasi',
      products: [...],
      orderHistory: [...],
      currentMonth: 3,
      climateData: {},
    };

    try {
      await analyzeProducts(inputData);
    } catch (err) {
      console.error('Analysis failed:', err);
    }
  };

  return (
    <div>
      <button onClick={handleAnalyze} disabled={loading}>
        {loading ? 'Analyzing...' : 'Analyze Products'}
      </button>
      
      {error && <div className="error">Error: {error.message}</div>}
      
      {insights && (
        <div>
          <h2>Hero Products: {insights.heroProducts.length}</h2>
          <h2>Total Products: {insights.inventorySummary.totalProducts}</h2>
        </div>
      )}
    </div>
  );
}
```

## Complete Example Input

```json
{
  "tenantId": "farmasi",
  "products": [
    {
      "productId": "TEST001",
      "productName": "Premium Mascara Ultra Black",
      "category": "MAKEUP",
      "subcategory": "Mascara",
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
      "trendScore": 85,
      "tags": ["mascara", "premium", "bestseller"],
      "seasonalityRules": []
    },
    {
      "productId": "TEST002",
      "productName": "New Launch Serum",
      "category": "SKINCARE",
      "subcategory": "Serum",
      "brand": "Farmasi",
      "season": "all",
      "isSeasonal": false,
      "seasonCode": "all",
      "stock": 200,
      "currentStock": 200,
      "last30DaysSales": 95,
      "cost": 60.00,
      "unitCost": 60.00,
      "basePrice": 149.90,
      "unitPrice": 149.90,
      "lifecycleStage": "NEW",
      "trendScore": 92,
      "tags": ["serum", "new", "anti-aging"],
      "seasonalityRules": []
    }
  ],
  "orderHistory": [
    {
      "orderId": "ORD001",
      "orderDate": "2024-01-15",
      "items": [
        {"productId": "TEST001", "quantity": 2},
        {"productId": "TEST002", "quantity": 3}
      ]
    }
  ],
  "currentMonth": 3,
  "climateData": {
    "Istanbul": {
      "humidityPct": 72.5,
      "avgTempC": 12.3,
      "rainfallMm": 85.2,
      "seasonTag": "winter"
    }
  }
}
```

## Complete Example Output

```json
{
  "heroProducts": [
    {
      "productId": "TEST002",
      "productName": "New Launch Serum",
      "category": "SKINCARE",
      "brand": "Farmasi",
      "performanceSegment": "Rising",
      "stockSegment": "Excess",
      "lifecycleStage": "NEW",
      "trendScore": 92,
      "stockDays": 3000.0,
      "dailySalesRate": 0.067,
      "inventoryPressure": true,
      "seasonalRelevance": "MEDIUM",
      "seasonMatch": true,
      "priceSegment": "BUDGET",
      "marginHealth": "GOOD",
      "recommendedAction": "FEATURE",
      "urgencyLevel": "HIGH",
      "climateMatch": [],
      "matchingCities": []
    }
  ],
  "slowMovers": [
    {
      "productId": "TEST001",
      "productName": "Premium Mascara Ultra Black",
      "category": "MAKEUP",
      "brand": "Farmasi",
      "performanceSegment": "Underperformer",
      "stockSegment": "Excess",
      "lifecycleStage": "MATURE",
      "trendScore": 85,
      "stockDays": 3115.38,
      "dailySalesRate": 0.144,
      "inventoryPressure": true,
      "seasonalRelevance": "MEDIUM",
      "seasonMatch": true,
      "priceSegment": "BUDGET",
      "marginHealth": "GOOD",
      "recommendedAction": "DISCOUNT",
      "urgencyLevel": "MEDIUM",
      "climateMatch": [],
      "matchingCities": []
    }
  ],
  "newProducts": [
    {
      "productId": "TEST002",
      "productName": "New Launch Serum",
      "category": "SKINCARE",
      "brand": "Farmasi",
      "performanceSegment": "Rising",
      "stockSegment": "Excess",
      "lifecycleStage": "NEW",
      "trendScore": 92,
      "stockDays": 3000.0,
      "dailySalesRate": 0.067,
      "inventoryPressure": true,
      "seasonalRelevance": "MEDIUM",
      "seasonMatch": true,
      "priceSegment": "BUDGET",
      "marginHealth": "GOOD",
      "recommendedAction": "FEATURE",
      "urgencyLevel": "HIGH",
      "climateMatch": [],
      "matchingCities": []
    }
  ],
  "seasonalProducts": [],
  "categoryInsights": {
    "MAKEUP": {
      "totalProducts": 1,
      "avgTrendScore": 85.0,
      "totalStock": 450,
      "avgStockDays": 3115.38,
      "performanceRating": "STRONG",
      "topPerformers": 0,
      "underperformers": 1
    },
    "SKINCARE": {
      "totalProducts": 1,
      "avgTrendScore": 92.0,
      "totalStock": 200,
      "avgStockDays": 3000.0,
      "performanceRating": "STRONG",
      "topPerformers": 1,
      "underperformers": 0
    }
  },
  "priceSegmentAnalysis": {
    "BUDGET": {
      "priceRange": "0-200 TL",
      "productCount": 2,
      "avgTrendScore": 88.5,
      "stockHealth": "POOR"
    },
    "MID": {
      "priceRange": "200-500 TL",
      "productCount": 0,
      "avgTrendScore": 0,
      "stockHealth": "GOOD"
    },
    "PREMIUM": {
      "priceRange": "500+ TL",
      "productCount": 0,
      "avgTrendScore": 0,
      "stockHealth": "GOOD"
    }
  },
  "inventorySummary": {
    "totalProducts": 2,
    "totalStockValue": 32250.0,
    "criticalStockProducts": 0,
    "excessStockProducts": 2,
    "healthyStockProducts": 0,
    "avgStockDays": 3057.69,
    "inventoryTurnoverRate": 0.12
  }
}
```

## Error Responses

The agent returns structured error responses for various failure scenarios:

### Missing Required Field

```json
{
  "error": {
    "code": "MISSING_FIELD",
    "message": "Missing required field: tenantId",
    "field": "tenantId"
  }
}
```

### Invalid Data Type

```json
{
  "error": {
    "code": "INVALID_TYPE",
    "message": "Invalid data type for currentMonth: expected number, got string",
    "field": "currentMonth",
    "details": {
      "expected": "number",
      "received": "string"
    }
  }
}
```

### Invalid Month Value

```json
{
  "error": {
    "code": "INVALID_VALUE",
    "message": "Invalid currentMonth: must be between 1 and 12, got 13",
    "field": "currentMonth",
    "details": {
      "value": 13,
      "validRange": "1-12"
    }
  }
}
```

### Empty Products Array

```json
{
  "error": {
    "code": "EMPTY_ARRAY",
    "message": "Products array cannot be empty",
    "field": "products"
  }
}
```

### Missing Product Field

```json
{
  "error": {
    "code": "MISSING_PRODUCT_FIELD",
    "message": "Product TEST001 missing required field: trendScore",
    "field": "trendScore",
    "details": {
      "productId": "TEST001"
    }
  }
}
```

### Service Unavailable

```json
{
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "Failed to invoke AI model: Service temporarily unavailable"
  }
}
```

### Permission Denied

```json
{
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "Insufficient permissions: bedrock:InvokeAgent"
  }
}
```

### Request Timeout

```json
{
  "error": {
    "code": "TIMEOUT",
    "message": "Request timeout: processing exceeded maximum duration"
  }
}
```

## Error Handling Best Practices

### Python Error Handling

```python
from typing import Dict, Any
import boto3
from botocore.exceptions import ClientError

def analyze_with_retry(client, input_data: Dict[str, Any], max_retries: int = 3) -> Dict[str, Any]:
    """Analyze products with automatic retry logic"""
    
    for attempt in range(max_retries):
        try:
            response = client.invoke_agent(
                agentId='AGENT_ID',
                agentAliasId='ALIAS_ID',
                sessionId=f'session-{attempt}',
                inputText=json.dumps(input_data)
            )
            return json.loads(response['output'])
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            
            if error_code == 'ThrottlingException':
                # Exponential backoff
                wait_time = 2 ** attempt
                print(f"Throttled, waiting {wait_time}s before retry...")
                time.sleep(wait_time)
                continue
                
            elif error_code == 'ValidationException':
                # Don't retry validation errors
                print(f"Validation error: {e}")
                raise
                
            elif error_code == 'ResourceNotFoundException':
                # Don't retry if agent not found
                print(f"Agent not found: {e}")
                raise
                
            else:
                # Retry other errors
                if attempt < max_retries - 1:
                    print(f"Error on attempt {attempt + 1}, retrying...")
                    continue
                raise
    
    raise RuntimeError(f"Failed after {max_retries} attempts")
```

### TypeScript Error Handling

```typescript
import { 
  BedrockAgentRuntimeClient, 
  InvokeAgentCommand,
  ThrottlingException,
  ValidationException,
  ResourceNotFoundException
} from "@aws-sdk/client-bedrock-agent-runtime";

async function analyzeWithRetry(
  client: BedrockAgentRuntimeClient,
  inputData: ProductAnalysisInput,
  maxRetries: number = 3
): Promise<ProductInsights> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const command = new InvokeAgentCommand({
        agentId: "AGENT_ID",
        agentAliasId: "ALIAS_ID",
        sessionId: `session-${attempt}`,
        inputText: JSON.stringify(inputData),
      });

      const response = await client.send(command);
      return JSON.parse(response.output as string);
      
    } catch (error) {
      if (error instanceof ThrottlingException) {
        // Exponential backoff
        const waitTime = Math.pow(2, attempt) * 1000;
        console.log(`Throttled, waiting ${waitTime}ms before retry...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
        continue;
        
      } else if (error instanceof ValidationException) {
        // Don't retry validation errors
        console.error("Validation error:", error);
        throw error;
        
      } else if (error instanceof ResourceNotFoundException) {
        // Don't retry if agent not found
        console.error("Agent not found:", error);
        throw error;
        
      } else {
        // Retry other errors
        if (attempt < maxRetries - 1) {
          console.log(`Error on attempt ${attempt + 1}, retrying...`);
          continue;
        }
        throw error;
      }
    }
  }
  
  throw new Error(`Failed after ${maxRetries} attempts`);
}
```

## Performance Considerations

### Request Size Limits

- Maximum input size: 25 KB
- Maximum products per request: ~100 products (depending on product data size)
- Maximum order history items: ~500 orders

For larger datasets, consider:
1. Batching products into multiple requests
2. Filtering order history to recent transactions only
3. Compressing data before sending

### Response Time

- Typical response time: 2-5 seconds
- Factors affecting performance:
  - Number of products analyzed
  - Size of order history
  - Complexity of seasonal rules
  - AI model processing time

### Rate Limits

- Default: 10 requests per second per account
- Burst: 20 requests per second
- Contact AWS support to increase limits if needed

### Caching Strategy

Consider caching results for:
- Static product catalogs (cache for 1 hour)
- Seasonal analysis (cache until month changes)
- Category insights (cache for 30 minutes)

```python
from functools import lru_cache
import hashlib
import json

@lru_cache(maxsize=100)
def get_cached_analysis(input_hash: str) -> Dict[str, Any]:
    """Cache analysis results based on input hash"""
    # Implementation depends on your caching strategy
    pass

def analyze_with_cache(input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze with caching"""
    # Create hash of input data
    input_str = json.dumps(input_data, sort_keys=True)
    input_hash = hashlib.md5(input_str.encode()).hexdigest()
    
    # Try to get from cache
    cached = get_cached_analysis(input_hash)
    if cached:
        return cached
    
    # If not cached, analyze and cache result
    result = analyze_products(input_data)
    get_cached_analysis.cache_info()  # Store in cache
    return result
```

## Security Best Practices

### IAM Permissions

Minimum required IAM policy for invoking the agent:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeAgent"
      ],
      "Resource": [
        "arn:aws:bedrock-agentcore:us-west-2:853548971581:runtime/product_analysis_agent_kiro-DbG83rES5F"
      ]
    }
  ]
}
```

### Credential Management

**Never hardcode credentials in your application code.**

#### Backend (Python)

Use AWS credentials from environment variables or IAM roles:

```python
# Use environment variables
import os
os.environ['AWS_ACCESS_KEY_ID'] = 'your-access-key'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'your-secret-key'

# Or use IAM role (recommended for EC2/Lambda)
client = boto3.client('bedrock-agentcore-runtime', region_name='us-west-2')
```

#### Frontend (JavaScript/TypeScript)

Use AWS Cognito or temporary credentials:

```typescript
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-provider-cognito-identity";

const client = new BedrockAgentRuntimeClient({
  region: "us-west-2",
  credentials: fromCognitoIdentityPool({
    client: new CognitoIdentityClient({ region: "us-west-2" }),
    identityPoolId: "us-west-2:IDENTITY_POOL_ID",
  }),
});
```

### Data Privacy

- **Tenant Isolation**: Always include `tenantId` to ensure data isolation
- **PII Handling**: Avoid sending personally identifiable information
- **Data Encryption**: All data is encrypted in transit (TLS 1.2+)
- **Audit Logging**: Enable CloudTrail for API call auditing

### Input Validation

Always validate input data before sending to the agent:

```python
def validate_input(data: Dict[str, Any]) -> None:
    """Validate input data for security"""
    
    # Check for SQL injection patterns
    dangerous_patterns = ["DROP", "DELETE", "UPDATE", "INSERT", "--", ";"]
    for field in ['tenantId', 'productName', 'category']:
        if any(pattern in str(data.get(field, '')).upper() for pattern in dangerous_patterns):
            raise ValueError(f"Potentially dangerous input detected in {field}")
    
    # Validate numeric ranges
    if not (1 <= data.get('currentMonth', 0) <= 12):
        raise ValueError("Invalid month value")
    
    # Validate array sizes
    if len(data.get('products', [])) > 100:
        raise ValueError("Too many products (max 100)")
```

## Monitoring and Logging

### CloudWatch Metrics

Monitor agent performance with CloudWatch:

```python
import boto3

cloudwatch = boto3.client('cloudwatch', region_name='us-west-2')

def log_invocation_metrics(duration: float, success: bool):
    """Log custom metrics to CloudWatch"""
    cloudwatch.put_metric_data(
        Namespace='ProductAnalysisAgent',
        MetricData=[
            {
                'MetricName': 'InvocationDuration',
                'Value': duration,
                'Unit': 'Seconds'
            },
            {
                'MetricName': 'InvocationSuccess',
                'Value': 1 if success else 0,
                'Unit': 'Count'
            }
        ]
    )
```

### Application Logging

```python
import logging
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def analyze_with_logging(input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze products with comprehensive logging"""
    start_time = time.time()
    
    logger.info(f"Starting analysis for tenant: {input_data.get('tenantId')}")
    logger.info(f"Product count: {len(input_data.get('products', []))}")
    
    try:
        result = analyze_products(input_data)
        duration = time.time() - start_time
        
        logger.info(f"Analysis completed in {duration:.2f}s")
        logger.info(f"Hero products found: {len(result.get('heroProducts', []))}")
        logger.info(f"Slow movers found: {len(result.get('slowMovers', []))}")
        
        log_invocation_metrics(duration, True)
        return result
        
    except Exception as e:
        duration = time.time() - start_time
        logger.error(f"Analysis failed after {duration:.2f}s: {e}")
        log_invocation_metrics(duration, False)
        raise
```

### Key Metrics to Monitor

- **Invocation Count**: Total number of agent invocations
- **Success Rate**: Percentage of successful invocations
- **Response Time**: Average and P99 response times
- **Error Rate**: Percentage of failed invocations
- **Throttling Rate**: Number of throttled requests

## Troubleshooting

### Common Issues

#### Issue: "Agent not found" error

**Solution**: Verify the agent ID and alias ID are correct:

```bash
aws bedrock-agent list-agents --region us-west-2 --profile workshop-profile
```

#### Issue: "Insufficient permissions" error

**Solution**: Check IAM policy includes `bedrock:InvokeAgent` permission for the specific agent ARN.

#### Issue: Slow response times

**Possible causes**:
- Large product catalog (>50 products)
- Extensive order history (>200 orders)
- Complex seasonal rules

**Solutions**:
- Reduce product count per request
- Filter order history to last 90 days only
- Simplify seasonal rules

#### Issue: Validation errors

**Solution**: Validate input structure matches schema exactly. Common mistakes:
- Missing required fields
- Wrong data types (string instead of number)
- Invalid enum values (e.g., lifecycleStage not in [NEW, GROWING, MATURE, DECLINING])

### Debug Mode

Enable debug logging for detailed troubleshooting:

```python
import logging

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)
boto3.set_stream_logger('', logging.DEBUG)
```

```typescript
// Enable debug logging in AWS SDK
import { Logger } from "@aws-sdk/types";

const logger: Logger = {
  debug: (...content) => console.debug(...content),
  info: (...content) => console.info(...content),
  warn: (...content) => console.warn(...content),
  error: (...content) => console.error(...content),
};

const client = new BedrockAgentRuntimeClient({
  region: "us-west-2",
  logger: logger,
});
```

## Testing

### Unit Testing

```python
import unittest
from unittest.mock import Mock, patch
import json

class TestProductAnalysisClient(unittest.TestCase):
    def setUp(self):
        self.client = ProductAnalysisClient(
            agent_id='test-agent-id',
            alias_id='test-alias-id'
        )
    
    @patch('boto3.client')
    def test_successful_analysis(self, mock_boto_client):
        """Test successful product analysis"""
        # Mock response
        mock_response = {
            'output': json.dumps({
                'heroProducts': [],
                'slowMovers': [],
                'newProducts': [],
                'seasonalProducts': [],
                'categoryInsights': {},
                'priceSegmentAnalysis': {},
                'inventorySummary': {
                    'totalProducts': 1,
                    'totalStockValue': 1000.0
                }
            })
        }
        mock_boto_client.return_value.invoke_agent.return_value = mock_response
        
        # Test input
        input_data = {
            'tenantId': 'test',
            'products': [{'productId': 'P1', 'trendScore': 85}],
            'orderHistory': [],
            'currentMonth': 3,
            'climateData': {}
        }
        
        # Execute
        result = self.client.analyze_products(input_data)
        
        # Assert
        self.assertEqual(result['inventorySummary']['totalProducts'], 1)
    
    def test_missing_tenant_id(self):
        """Test validation error for missing tenantId"""
        input_data = {
            'products': [],
            'orderHistory': [],
            'currentMonth': 3,
            'climateData': {}
        }
        
        with self.assertRaises(ValueError) as context:
            self.client.analyze_products(input_data)
        
        self.assertIn('tenantId', str(context.exception))

if __name__ == '__main__':
    unittest.main()
```

### Integration Testing

```python
import pytest
import json

@pytest.fixture
def sample_input():
    """Sample input data for testing"""
    return {
        'tenantId': 'farmasi',
        'products': [
            {
                'productId': 'TEST001',
                'productName': 'Test Product',
                'category': 'MAKEUP',
                'subcategory': 'Mascara',
                'brand': 'Farmasi',
                'season': 'all',
                'isSeasonal': False,
                'seasonCode': 'all',
                'stock': 100,
                'currentStock': 100,
                'last30DaysSales': 50,
                'cost': 10.0,
                'unitCost': 10.0,
                'basePrice': 20.0,
                'unitPrice': 20.0,
                'lifecycleStage': 'MATURE',
                'trendScore': 75,
                'tags': ['test'],
                'seasonalityRules': []
            }
        ],
        'orderHistory': [],
        'currentMonth': 3,
        'climateData': {}
    }

@pytest.mark.integration
def test_end_to_end_analysis(sample_input):
    """Test complete end-to-end analysis flow"""
    client = ProductAnalysisClient(
        agent_id=os.getenv('AGENT_ID'),
        alias_id=os.getenv('ALIAS_ID')
    )
    
    result = client.analyze_products(sample_input)
    
    # Verify output structure
    assert 'heroProducts' in result
    assert 'slowMovers' in result
    assert 'newProducts' in result
    assert 'seasonalProducts' in result
    assert 'categoryInsights' in result
    assert 'priceSegmentAnalysis' in result
    assert 'inventorySummary' in result
    
    # Verify inventory summary
    assert result['inventorySummary']['totalProducts'] == 1
    assert result['inventorySummary']['totalStockValue'] > 0
```

## Deployment Guide

### Prerequisites

1. AWS CLI configured with workshop-profile
2. Docker installed (for containerization)
3. Python 3.11+ with uv package manager
4. AWS Bedrock AgentCore CLI tools

### Deployment Steps

#### 1. Configure AgentCore

```bash
agentcore configure --region us-west-2
```

This creates:
- IAM Role for agent execution
- ECR repository for container images

#### 2. Build and Deploy Agent

```bash
# Deploy using agentcore CLI (handles build, push, and launch)
agentcore deploy --name product_analysis_agent_kiro --region us-west-2
```

#### 3. Test Deployment

```bash
# Invoke agent with test input
agentcore invoke --name product_analysis_agent_kiro --payload '{"tenantId":"test","products":[...],"orderHistory":[],"currentMonth":3,"climateData":{}}'
```

#### 4. Update API Documentation

After successful deployment, update this document with actual ARNs:
- Replace `ACCOUNT_ID` with your AWS account ID
- Replace `AGENT_ID` with the deployed agent ID
- Replace `ALIAS_ID` with the agent alias ID

### Environment Variables

Set these environment variables for your application:

```bash
# Backend (Python)
export AWS_REGION=us-west-2
export AGENT_ARN=arn:aws:bedrock-agentcore:us-west-2:853548971581:runtime/product_analysis_agent_kiro-DbG83rES5F
export AWS_PROFILE=workshop-profile

# Frontend (JavaScript/TypeScript)
REACT_APP_AWS_REGION=us-west-2
REACT_APP_AGENT_ARN=arn:aws:bedrock-agentcore:us-west-2:853548971581:runtime/product_analysis_agent_kiro-DbG83rES5F
```

## API Versioning

### Current Version: v1.0

The Product Analysis Agent API follows semantic versioning. Breaking changes will result in a new major version.

### Version History

- **v1.0** (Current): Initial release with core analysis features
  - Stock analysis and segmentation
  - Performance segmentation
  - Seasonal analysis
  - Category and price segment analytics
  - Recommendation engine

### Future Versions

Planned features for future releases:
- **v1.1**: Enhanced seasonal rules with weather forecasting
- **v1.2**: Multi-language support for product names
- **v1.3**: Real-time inventory updates
- **v2.0**: Customer-level campaign recommendations integration

## Support and Resources

### Documentation

- **Requirements**: `.kiro/specs/product-analysis-strands-agent/requirements.md`
- **Design**: `.kiro/specs/product-analysis-strands-agent/design.md`
- **Implementation Plan**: `.kiro/specs/product-analysis-strands-agent/tasks.md`
- **Agent Specification**: `agents/PRODUCT_ANALYSIS_AGENT.md`

### AWS Resources

- [Amazon Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Bedrock Agent Runtime API Reference](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_Operations_Agents_for_Amazon_Bedrock_Runtime.html)
- [AWS SDK for Python (Boto3)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [AWS SDK for JavaScript](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)

### Contact

For technical support or questions:
- Create an issue in the project repository
- Contact the development team
- Review the troubleshooting section above

## Changelog

### 2026-02-12 - v1.0 Initial Release

**Features:**
- Complete product analysis pipeline
- Stock analysis with Critical/Healthy/Excess classification
- Performance segmentation (Star/Rising/Steady/Underperformer)
- Seasonal relevance analysis with climate matching
- Category and price segment analytics
- Actionable recommendations with urgency levels
- Comprehensive error handling
- Multi-tenant support

**API Endpoints:**
- Agent invocation via Bedrock AgentCore Runtime

**Documentation:**
- Complete API reference
- Python and TypeScript integration examples
- Error handling best practices
- Security guidelines
- Performance optimization tips

---

## Quick Reference

### Minimum Required Input

```json
{
  "tenantId": "string",
  "products": [{"productId": "string", "trendScore": 0, "stock": 0, "cost": 0, "basePrice": 0, "lifecycleStage": "MATURE"}],
  "orderHistory": [],
  "currentMonth": 1,
  "climateData": {}
}
```

### Key Output Fields

- `heroProducts`: Top performers to promote
- `slowMovers`: Products needing attention
- `inventorySummary.criticalStockProducts`: Urgent restocking needed
- `categoryInsights`: Category-level performance
- `recommendedAction`: Suggested campaign action per product

### Common Actions

| Action | When to Use |
|--------|-------------|
| RESTOCK | Critical stock on high performers |
| FEATURE | New rising products |
| PROMOTE | Star products with healthy stock |
| SEASONAL_PUSH | Seasonally relevant products |
| CLEARANCE | Excess declining products |
| BUNDLE | Excess moderate margin products |
| DISCOUNT | Underperforming products |
| MAINTAIN | Stable products |

---

**Document Version**: 1.0  
**Last Updated**: 2026-02-12  
**Agent Version**: product_analysis_agent_kiro v1.0
