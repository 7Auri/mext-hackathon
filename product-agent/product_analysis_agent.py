"""
Product Analysis Strands Agent

A Python-based AI agent for Amazon Bedrock AgentCore Runtime that analyzes
product data to generate actionable insights for campaign management.

This agent implements a model-driven architecture, leveraging AI capabilities
for planning, reasoning, tool calling, and self-reflection.
"""

import json
from typing import Dict, List, Tuple, Any


class InputValidator:
    """Validates input data structure and required fields."""
    
    def validate(self, input_data: dict) -> Tuple[bool, str]:
        """
        Validates input data structure.
        
        Args:
            input_data: Raw input dictionary
        
        Returns:
            Tuple of (is_valid, error_message)
        """
        # Validate tenantId presence and type
        if 'tenantId' not in input_data:
            return (False, "Missing required field: tenantId")
        if not isinstance(input_data['tenantId'], str) or not input_data['tenantId']:
            return (False, "Invalid data type for tenantId: expected non-empty string")
        
        # Validate products presence and type
        if 'products' not in input_data:
            return (False, "Missing required field: products")
        if not isinstance(input_data['products'], list):
            return (False, "Invalid data type for products: expected list")
        if len(input_data['products']) == 0:
            return (False, "Products array cannot be empty")
        
        # Validate orderHistory presence and type
        if 'orderHistory' not in input_data:
            return (False, "Missing required field: orderHistory")
        if not isinstance(input_data['orderHistory'], list):
            return (False, "Invalid data type for orderHistory: expected list")
        
        # Validate currentMonth presence and type
        if 'currentMonth' not in input_data:
            return (False, "Missing required field: currentMonth")
        if not isinstance(input_data['currentMonth'], int):
            return (False, "Invalid data type for currentMonth: expected int")
        if input_data['currentMonth'] < 1 or input_data['currentMonth'] > 12:
            return (False, f"Invalid currentMonth: must be between 1 and 12, got {input_data['currentMonth']}")
        
        # Validate climateData presence and type
        if 'climateData' not in input_data:
            return (False, "Missing required field: climateData")
        if not isinstance(input_data['climateData'], dict):
            return (False, "Invalid data type for climateData: expected dict")
        
        return (True, "")


class StockAnalyzer:
    """Calculates stock metrics and classifies stock segments."""

    def calculate_daily_sales_rate(self, product_id: str, order_history: list) -> float:
        """
        Calculate average daily sales over 90 days.

        Args:
            product_id: Product identifier
            order_history: List of order dictionaries

        Returns:
            Daily sales rate (total sales / 90)
        """
        total_sales = 0
        for order in order_history:
            if 'items' in order:
                for item in order['items']:
                    if item.get('productId') == product_id:
                        total_sales += item.get('quantity', 0)

        return total_sales / 90.0

    def calculate_stock_days(self, stock: int, daily_sales_rate: float) -> float:
        """
        Calculate days of inventory remaining.

        Args:
            stock: Current stock level
            daily_sales_rate: Average daily sales

        Returns:
            Stock days (999 if daily_sales_rate is zero)
        """
        if daily_sales_rate == 0:
            return 999.0
        return stock / daily_sales_rate

    def classify_stock_segment(self, stock_days: float) -> str:
        """
        Classify as Critical (<15), Healthy (15-60), or Excess (>60).

        Args:
            stock_days: Days of inventory remaining

        Returns:
            Stock segment classification
        """
        if stock_days < 15:
            return "Critical"
        elif stock_days <= 60:
            return "Healthy"
        else:
            return "Excess"

    def analyze(self, products: list, order_history: list) -> dict:
        """
        Analyzes stock levels for all products.

        Args:
            products: List of product dictionaries
            order_history: List of order dictionaries

        Returns:
            Dictionary mapping productId to stock metrics:
            {
                productId: {
                    dailySalesRate: float,
                    stockDays: float,
                    stockSegment: str,
                    inventoryPressure: bool
                }
            }
        """
        stock_metrics = {}

        for product in products:
            product_id = product.get('productId')
            stock = product.get('stock', 0)

            # Calculate daily sales rate
            daily_sales_rate = self.calculate_daily_sales_rate(product_id, order_history)

            # Calculate stock days
            stock_days = self.calculate_stock_days(stock, daily_sales_rate)

            # Classify stock segment
            stock_segment = self.classify_stock_segment(stock_days)

            # Set inventory pressure flag
            inventory_pressure = stock_days > 60

            stock_metrics[product_id] = {
                'dailySalesRate': daily_sales_rate,
                'stockDays': stock_days,
                'stockSegment': stock_segment,
                'inventoryPressure': inventory_pressure
            }

        return stock_metrics



class PerformanceSegmenter:
    """Classifies products into performance segments."""
    
    def classify_performance(self, product: dict, stock_days: float) -> str:
        """
        Classify performance segment.
        
        Args:
            product: Product dictionary with lifecycleStage and trendScore
            stock_days: Days of inventory remaining
        
        Returns:
            Performance segment: Star, Rising, Steady, or Underperformer
        """
        lifecycle_stage = product.get('lifecycleStage', '')
        trend_score = product.get('trendScore', 0)
        
        # Rising: lifecycleStage == "NEW" AND trendScore > 85
        if lifecycle_stage == "NEW" and trend_score > 85:
            return "Rising"
        
        # Star: trendScore > 80 AND stockDays < 30
        if trend_score > 80 and stock_days < 30:
            return "Star"
        
        # Steady: 60 <= trendScore <= 80 AND stockDays < 60
        if 60 <= trend_score <= 80 and stock_days < 60:
            return "Steady"
        
        # Underperformer: otherwise
        return "Underperformer"
    
    def calculate_margin_health(self, cost: float, base_price: float) -> Tuple[float, str]:
        """
        Calculate margin percentage and health classification.
        
        Args:
            cost: Product cost
            base_price: Product base price
        
        Returns:
            Tuple of (margin percentage, margin health classification)
        """
        # Calculate margin: ((basePrice - cost) / basePrice) * 100
        if base_price == 0:
            return (0.0, "POOR")
        
        margin = ((base_price - cost) / base_price) * 100
        
        # Classify margin health
        if margin > 60:
            margin_health = "EXCELLENT"
        elif margin > 40:
            margin_health = "GOOD"
        elif margin > 25:
            margin_health = "MODERATE"
        else:
            margin_health = "POOR"
        
        return (margin, margin_health)
    
    def classify_price_segment(self, base_price: float) -> str:
        """
        Classify price segment.
        
        Args:
            base_price: Product base price
        
        Returns:
            Price segment: BUDGET, MID, or PREMIUM
        """
        if base_price <= 200:
            return "BUDGET"
        elif base_price <= 500:
            return "MID"
        else:
            return "PREMIUM"
    
    def segment(self, products: list, stock_metrics: dict) -> dict:
        """
        Segments products by performance.
        
        Args:
            products: List of product dictionaries
            stock_metrics: Stock analysis results from StockAnalyzer
        
        Returns:
            Dictionary mapping productId to performance metrics:
            {
                productId: {
                    performanceSegment: str,
                    marginHealth: str,
                    priceSegment: str,
                    margin: float
                }
            }
        """
        performance_metrics = {}
        
        for product in products:
            product_id = product.get('productId')
            
            # Get stock days from stock metrics
            stock_days = stock_metrics.get(product_id, {}).get('stockDays', 999)
            
            # Classify performance segment
            performance_segment = self.classify_performance(product, stock_days)
            
            # Calculate margin and margin health
            cost = product.get('cost', 0)
            base_price = product.get('basePrice', 0)
            margin, margin_health = self.calculate_margin_health(cost, base_price)
            
            # Classify price segment
            price_segment = self.classify_price_segment(base_price)
            
            performance_metrics[product_id] = {
                'performanceSegment': performance_segment,
                'marginHealth': margin_health,
                'priceSegment': price_segment,
                'margin': margin
            }
        
        return performance_metrics


class SeasonalAnalyzer:
    """Determines seasonal relevance and climate matching."""
    
    def get_current_season(self, month: int) -> str:
        """
        Determine season from month.
        
        Args:
            month: Month number (1-12)
        
        Returns:
            Season string: SPRING, SUMMER, FALL, or WINTER
        """
        if month in [3, 4, 5]:
            return "SPRING"
        elif month in [6, 7, 8]:
            return "SUMMER"
        elif month in [9, 10, 11]:
            return "FALL"
        else:  # 12, 1, 2
            return "WINTER"
    
    def check_season_match(self, product: dict, current_season: str) -> bool:
        """
        Check if product season matches current season.
        
        Args:
            product: Product dictionary with isSeasonal and seasonCode fields
            current_season: Current season string
        
        Returns:
            True if product matches season, False otherwise
        """
        # Non-seasonal products always match
        if not product.get("isSeasonal", False):
            return True
        
        # Check if product's season code matches current season
        season_code = product.get("seasonCode", "all")
        if season_code == "all":
            return True
        
        return season_code == current_season
    
    def check_climate_rules(self, product: dict, climate_data: dict) -> tuple:
        """
        Check climate rules and return matching rule types and cities.
        
        Args:
            product: Product dictionary with seasonalityRules field
            climate_data: Climate data by city
        
        Returns:
            Tuple of (matching_rule_types, matching_cities)
        """
        matching_rule_types = []
        matching_cities = []
        
        seasonality_rules = product.get("seasonalityRules", [])
        
        for rule in seasonality_rules:
            rule_type = rule.get("ruleType")
            threshold = rule.get("threshold", 0)
            
            for city, climate in climate_data.items():
                matched = False
                
                if rule_type == "HIGH_HUMIDITY":
                    if climate.get("humidityPct", 0) >= threshold:
                        matched = True
                elif rule_type == "LOW_TEMP":
                    if climate.get("avgTempC", 100) <= threshold:
                        matched = True
                elif rule_type == "HIGH_RAINFALL":
                    if climate.get("rainfallMm", 0) >= threshold:
                        matched = True
                elif rule_type == "SEASON_TAG":
                    # For SEASON_TAG, threshold is not used, check seasonTag directly
                    threshold_text = rule.get("thresholdText", "")
                    if climate.get("seasonTag", "") == threshold_text:
                        matched = True
                
                if matched:
                    if rule_type not in matching_rule_types:
                        matching_rule_types.append(rule_type)
                    if city not in matching_cities:
                        matching_cities.append(city)
        
        return matching_rule_types, matching_cities
    
    def analyze(self, products: list, current_month: int, climate_data: dict) -> dict:
        """
        Analyzes seasonal relevance for products.
        
        Args:
            products: List of product dictionaries
            current_month: Current month (1-12)
            climate_data: Climate data by city
        
        Returns:
            Dictionary mapping productId to seasonal metrics:
            {
                productId: {
                    seasonMatch: bool,
                    climateMatch: list[str],
                    matchingCities: list[str],
                    seasonalRelevance: str  # HIGH, MEDIUM, LOW
                }
            }
        """
        seasonal_metrics = {}
        current_season = self.get_current_season(current_month)
        
        for product in products:
            product_id = product.get("productId")
            
            # Check season match
            season_match = self.check_season_match(product, current_season)
            
            # Check climate rules
            climate_match, matching_cities = self.check_climate_rules(product, climate_data)
            
            # Determine seasonal relevance
            if season_match and len(climate_match) > 0:
                seasonal_relevance = "HIGH"
            elif season_match and len(climate_match) == 0:
                seasonal_relevance = "MEDIUM"
            else:
                seasonal_relevance = "LOW"
            
            seasonal_metrics[product_id] = {
                "seasonMatch": season_match,
                "climateMatch": climate_match,
                "matchingCities": matching_cities,
                "seasonalRelevance": seasonal_relevance
            }
        
        return seasonal_metrics


class CategoryAnalyzer:
    """Aggregates metrics by product category."""
    
    def analyze(self, products: list, performance_metrics: dict, stock_metrics: dict) -> dict:
        """
        Analyzes performance by category.

        Args:
            products: List of product dictionaries
            performance_metrics: Performance segmentation results
            stock_metrics: Stock analysis results

        Returns:
            Dictionary mapping category to aggregated metrics:
            {
                category: {
                    totalProducts: int,
                    avgTrendScore: float,
                    totalStock: int,
                    avgStockDays: float,
                    performanceRating: str,  # STRONG, MODERATE, WEAK
                    topPerformers: int,
                    underperformers: int
                }
            }
        """
        category_data = {}

        # Group products by category
        for product in products:
            category = product.get('category', 'Unknown')

            if category not in category_data:
                category_data[category] = {
                    'products': [],
                    'trendScores': [],
                    'stocks': [],
                    'stockDays': [],
                    'topPerformers': 0,
                    'underperformers': 0
                }

            # Add product data
            category_data[category]['products'].append(product)
            category_data[category]['trendScores'].append(product.get('trendScore', 0))
            category_data[category]['stocks'].append(product.get('stock', 0))

            # Get stock days
            product_id = product.get('productId')
            stock_days = stock_metrics.get(product_id, {}).get('stockDays', 0)
            category_data[category]['stockDays'].append(stock_days)

            # Count top performers and underperformers
            performance_segment = performance_metrics.get(product_id, {}).get('performanceSegment', '')
            if performance_segment in ['Star', 'Rising']:
                category_data[category]['topPerformers'] += 1
            elif performance_segment == 'Underperformer':
                category_data[category]['underperformers'] += 1

        # Calculate aggregated metrics for each category
        result = {}
        for category, data in category_data.items():
            total_products = len(data['products'])
            avg_trend_score = sum(data['trendScores']) / total_products if total_products > 0 else 0
            total_stock = sum(data['stocks'])
            avg_stock_days = sum(data['stockDays']) / total_products if total_products > 0 else 0

            # Determine performance rating
            if avg_trend_score > 80:
                performance_rating = 'STRONG'
            elif avg_trend_score > 65:
                performance_rating = 'MODERATE'
            else:
                performance_rating = 'WEAK'

            result[category] = {
                'totalProducts': total_products,
                'avgTrendScore': round(avg_trend_score, 2),
                'totalStock': total_stock,
                'avgStockDays': round(avg_stock_days, 2),
                'performanceRating': performance_rating,
                'topPerformers': data['topPerformers'],
                'underperformers': data['underperformers']
            }

        return result



class PriceSegmentAnalyzer:
    """Aggregates metrics by price segment."""
    
    def analyze(self, products: list, performance_metrics: dict, stock_metrics: dict) -> dict:
        """
        Analyzes performance by price segment.

        Args:
            products: List of product dictionaries
            performance_metrics: Performance segmentation results
            stock_metrics: Stock analysis results

        Returns:
            Dictionary with price segment analysis:
            {
                BUDGET: {
                    priceRange: str,
                    productCount: int,
                    avgTrendScore: float,
                    stockHealth: str  # GOOD, MODERATE, POOR
                },
                MID: {...},
                PREMIUM: {...}
            }
        """
        # Initialize segments
        segments = {
            "BUDGET": {"priceRange": "0-200 TL", "products": []},
            "MID": {"priceRange": "200-500 TL", "products": []},
            "PREMIUM": {"priceRange": "500+ TL", "products": []}
        }

        # Group products by price segment
        for product in products:
            product_id = product["productId"]
            perf_metrics = performance_metrics.get(product_id, {})
            price_segment = perf_metrics.get("priceSegment")

            if price_segment in segments:
                segments[price_segment]["products"].append({
                    "productId": product_id,
                    "trendScore": product.get("trendScore", 0),
                    "stockSegment": stock_metrics.get(product_id, {}).get("stockSegment", "")
                })

        # Calculate metrics for each segment
        result = {}
        for segment_name, segment_data in segments.items():
            products_in_segment = segment_data["products"]
            product_count = len(products_in_segment)

            if product_count == 0:
                # No products in this segment
                result[segment_name] = {
                    "priceRange": segment_data["priceRange"],
                    "productCount": 0,
                    "avgTrendScore": 0.0,
                    "stockHealth": "GOOD"  # Default for empty segment
                }
            else:
                # Calculate avgTrendScore
                total_trend_score = sum(p["trendScore"] for p in products_in_segment)
                avg_trend_score = total_trend_score / product_count

                # Calculate stockHealth based on proportion of Healthy stock products
                healthy_count = sum(1 for p in products_in_segment if p["stockSegment"] == "Healthy")
                healthy_proportion = healthy_count / product_count

                # Determine stockHealth
                if healthy_proportion > 0.70:
                    stock_health = "GOOD"
                elif healthy_proportion >= 0.40:
                    stock_health = "MODERATE"
                else:
                    stock_health = "POOR"

                result[segment_name] = {
                    "priceRange": segment_data["priceRange"],
                    "productCount": product_count,
                    "avgTrendScore": round(avg_trend_score, 2),
                    "stockHealth": stock_health
                }

        return result



class RecommendationEngine:
    """Generates recommended actions based on analysis results."""
    
    def recommend(self, product: dict, performance_metrics: dict,
                  stock_metrics: dict, seasonal_metrics: dict) -> Tuple[str, str]:
        """
        Generates recommended action and urgency level.

        Args:
            product: Product dictionary
            performance_metrics: Performance segmentation for product
            stock_metrics: Stock analysis for product
            seasonal_metrics: Seasonal analysis for product

        Returns:
            Tuple of (recommendedAction, urgencyLevel)

        Decision Logic (priority order):
        1. Star + Critical stock → RESTOCK, CRITICAL
        2. Rising → FEATURE, HIGH
        3. Star + Healthy stock → PROMOTE, HIGH
        4. HIGH seasonal relevance + not Critical → SEASONAL_PUSH, MEDIUM
        5. Excess + DECLINING → CLEARANCE, CRITICAL
        6. Excess + MODERATE margin → BUNDLE, HIGH
        7. Underperformer → DISCOUNT, MEDIUM
        8. Default → MAINTAIN, LOW
        """
        performance_segment = performance_metrics.get("performanceSegment", "")
        stock_segment = stock_metrics.get("stockSegment", "")
        seasonal_relevance = seasonal_metrics.get("seasonalRelevance", "")
        lifecycle_stage = product.get("lifecycleStage", "")
        margin_health = performance_metrics.get("marginHealth", "")

        # Priority 1: Star + Critical stock → RESTOCK, CRITICAL
        if performance_segment == "Star" and stock_segment == "Critical":
            return ("RESTOCK", "CRITICAL")

        # Priority 2: Rising → FEATURE, HIGH
        if performance_segment == "Rising":
            return ("FEATURE", "HIGH")

        # Priority 3: Star + Healthy stock → PROMOTE, HIGH
        if performance_segment == "Star" and stock_segment == "Healthy":
            return ("PROMOTE", "HIGH")

        # Priority 4: HIGH seasonal relevance + not Critical → SEASONAL_PUSH, MEDIUM
        if seasonal_relevance == "HIGH" and stock_segment != "Critical":
            return ("SEASONAL_PUSH", "MEDIUM")

        # Priority 5: Excess + DECLINING → CLEARANCE, CRITICAL
        if stock_segment == "Excess" and lifecycle_stage == "DECLINING":
            return ("CLEARANCE", "CRITICAL")

        # Priority 6: Excess + MODERATE margin → BUNDLE, HIGH
        if stock_segment == "Excess" and margin_health == "MODERATE":
            return ("BUNDLE", "HIGH")

        # Priority 7: Underperformer → DISCOUNT, MEDIUM
        if performance_segment == "Underperformer":
            return ("DISCOUNT", "MEDIUM")

        # Priority 8: Default → MAINTAIN, LOW
        return ("MAINTAIN", "LOW")



class OutputFormatter:
    """Formats analysis results into ProductInsightJSON structure."""

    def format(self, products: list, all_metrics: dict) -> dict:
        """
        Formats all analysis results into final output structure.

        Args:
            products: List of product dictionaries
            all_metrics: Combined metrics from all analyzers containing:
                - stock_metrics: Stock analysis results
                - performance_metrics: Performance segmentation results
                - seasonal_metrics: Seasonal analysis results
                - recommendation_metrics: Recommendation results
                - category_insights: Category analysis results
                - price_segment_analysis: Price segment analysis results

        Returns:
            ProductInsightJSON dictionary with:
            - heroProducts (top 10 Star/Rising by trendScore)
            - slowMovers (top 15 Excess/Underperformer by stockDays)
            - newProducts (all NEW by trendScore)
            - seasonalProducts (top 10 HIGH relevance)
            - categoryInsights
            - priceSegmentAnalysis
            - inventorySummary
        """
        stock_metrics = all_metrics.get('stock_metrics', {})
        performance_metrics = all_metrics.get('performance_metrics', {})
        seasonal_metrics = all_metrics.get('seasonal_metrics', {})
        recommendation_metrics = all_metrics.get('recommendation_metrics', {})

        # Build enriched product list with all metrics
        enriched_products = []
        for product in products:
            product_id = product['productId']
            stock_data = stock_metrics.get(product_id, {})
            perf_data = performance_metrics.get(product_id, {})
            seasonal_data = seasonal_metrics.get(product_id, {})
            rec_data = recommendation_metrics.get(product_id, {})

            enriched = {
                'productId': product_id,
                'productName': product.get('productName', ''),
                'category': product.get('category', 'Unknown'),
                'brand': product.get('brand', ''),
                'performanceSegment': perf_data.get('performanceSegment', 'Underperformer'),
                'stockSegment': stock_data.get('stockSegment', 'Healthy'),
                'lifecycleStage': product.get('lifecycleStage', 'MATURE'),
                'trendScore': product.get('trendScore', 0),
                'stockDays': stock_data.get('stockDays', 999),
                'dailySalesRate': stock_data.get('dailySalesRate', 0),
                'inventoryPressure': stock_data.get('inventoryPressure', False),
                'seasonalRelevance': seasonal_data.get('seasonalRelevance', 'LOW'),
                'seasonMatch': seasonal_data.get('seasonMatch', False),
                'priceSegment': perf_data.get('priceSegment', 'BUDGET'),
                'marginHealth': perf_data.get('marginHealth', 'POOR'),
                'recommendedAction': rec_data.get('recommendedAction', 'MAINTAIN'),
                'urgencyLevel': rec_data.get('urgencyLevel', 'LOW'),
                'climateMatch': seasonal_data.get('climateMatch', []),
                'matchingCities': seasonal_data.get('matchingCities', [])
            }
            enriched_products.append(enriched)

        # Segment products
        hero_products = self._get_hero_products(enriched_products)
        slow_movers = self._get_slow_movers(enriched_products)
        new_products = self._get_new_products(enriched_products)
        seasonal_products = self._get_seasonal_products(enriched_products)

        # Calculate inventory summary
        inventory_summary = self.calculate_inventory_summary(products, stock_metrics)

        return {
            'heroProducts': hero_products,
            'slowMovers': slow_movers,
            'newProducts': new_products,
            'seasonalProducts': seasonal_products,
            'categoryInsights': all_metrics.get('category_insights', {}),
            'priceSegmentAnalysis': all_metrics.get('price_segment_analysis', {}),
            'inventorySummary': inventory_summary
        }

    def _get_hero_products(self, enriched_products: list) -> list:
        """
        Get top 10 Star or Rising products sorted by trendScore descending.

        Args:
            enriched_products: List of enriched product dictionaries

        Returns:
            List of top 10 hero products
        """
        # Filter Star or Rising products
        heroes = [
            p for p in enriched_products
            if p['performanceSegment'] in ['Star', 'Rising']
        ]

        # Sort by trendScore descending
        heroes.sort(key=lambda x: x['trendScore'], reverse=True)

        # Return top 10
        return heroes[:10]

    def _get_slow_movers(self, enriched_products: list) -> list:
        """
        Get top 15 Excess or Underperformer products sorted by stockDays descending.

        Args:
            enriched_products: List of enriched product dictionaries

        Returns:
            List of top 15 slow movers
        """
        # Filter Excess stock or Underperformer products
        slow = [
            p for p in enriched_products
            if p['stockSegment'] == 'Excess' or p['performanceSegment'] == 'Underperformer'
        ]

        # Sort by stockDays descending
        slow.sort(key=lambda x: x['stockDays'], reverse=True)

        # Return top 15
        return slow[:15]

    def _get_new_products(self, enriched_products: list) -> list:
        """
        Get all NEW lifecycle products sorted by trendScore descending.

        Args:
            enriched_products: List of enriched product dictionaries

        Returns:
            List of all NEW products sorted by trendScore
        """
        # Filter NEW lifecycle products
        new = [
            p for p in enriched_products
            if p['lifecycleStage'] == 'NEW'
        ]

        # Sort by trendScore descending
        new.sort(key=lambda x: x['trendScore'], reverse=True)

        return new

    def _get_seasonal_products(self, enriched_products: list) -> list:
        """
        Get top 10 HIGH seasonalRelevance products.

        Args:
            enriched_products: List of enriched product dictionaries

        Returns:
            List of top 10 seasonal products with simplified structure
        """
        # Filter HIGH seasonal relevance products
        seasonal = [
            p for p in enriched_products
            if p['seasonalRelevance'] == 'HIGH'
        ]

        # Sort by trendScore descending (for consistency)
        seasonal.sort(key=lambda x: x['trendScore'], reverse=True)

        # Return top 10 with simplified structure
        result = []
        for p in seasonal[:10]:
            result.append({
                'productId': p['productId'],
                'productName': p['productName'],
                'seasonalRelevance': p['seasonalRelevance'],
                'climateMatch': p['climateMatch'],
                'matchingCities': p['matchingCities'],
                'recommendedAction': p['recommendedAction']
            })

        return result

    def calculate_inventory_summary(self, products: list, stock_metrics: dict) -> dict:
        """
        Calculate overall inventory metrics.

        Args:
            products: List of product dictionaries
            stock_metrics: Stock analysis results

        Returns:
            Dictionary with inventory summary:
            - totalProducts: count of all products
            - totalStockValue: sum of (stock * cost)
            - criticalStockProducts: count of Critical stock
            - excessStockProducts: count of Excess stock
            - healthyStockProducts: count of Healthy stock
            - avgStockDays: average stockDays across all products
            - inventoryTurnoverRate: 365 / avgStockDays
        """
        if not products:
            return {
                'totalProducts': 0,
                'totalStockValue': 0.0,
                'criticalStockProducts': 0,
                'excessStockProducts': 0,
                'healthyStockProducts': 0,
                'avgStockDays': 0.0,
                'inventoryTurnoverRate': 0.0
            }

        total_products = len(products)
        total_stock_value = 0.0
        critical_count = 0
        excess_count = 0
        healthy_count = 0
        total_stock_days = 0.0

        for product in products:
            product_id = product['productId']
            stock = product.get('stock', 0)
            cost = product.get('cost', 0)

            # Calculate stock value
            total_stock_value += stock * cost

            # Get stock metrics
            stock_data = stock_metrics.get(product_id, {})
            stock_segment = stock_data.get('stockSegment', 'Healthy')
            stock_days = stock_data.get('stockDays', 999)

            # Count by segment
            if stock_segment == 'Critical':
                critical_count += 1
            elif stock_segment == 'Excess':
                excess_count += 1
            elif stock_segment == 'Healthy':
                healthy_count += 1

            # Accumulate stock days
            total_stock_days += stock_days

        # Calculate averages
        avg_stock_days = total_stock_days / total_products if total_products > 0 else 0.0
        inventory_turnover_rate = 365 / avg_stock_days if avg_stock_days > 0 else 0.0

        return {
            'totalProducts': total_products,
            'totalStockValue': round(total_stock_value, 2),
            'criticalStockProducts': critical_count,
            'excessStockProducts': excess_count,
            'healthyStockProducts': healthy_count,
            'avgStockDays': round(avg_stock_days, 2),
            'inventoryTurnoverRate': round(inventory_turnover_rate, 2)
        }



class AgentOrchestrator:
    """Coordinates the overall analysis workflow."""
    
    def __init__(self):
        self.validator = InputValidator()
        self.stock_analyzer = StockAnalyzer()
        self.performance_segmenter = PerformanceSegmenter()
        self.seasonal_analyzer = SeasonalAnalyzer()
        self.category_analyzer = CategoryAnalyzer()
        self.price_segment_analyzer = PriceSegmentAnalyzer()
        self.recommendation_engine = RecommendationEngine()
        self.output_formatter = OutputFormatter()
    
    def execute(self, input_data: dict) -> dict:
        """
        Main entry point for agent execution.
        
        Args:
            input_data: Dictionary containing tenantId, products, orderHistory,
                       currentMonth, climateData
        
        Returns:
            ProductInsightJSON with all analysis results
        """
        try:
            # Step 1: Validate input
            is_valid, error_message = self.validator.validate(input_data)
            if not is_valid:
                return {
                    'error': {
                        'code': 'VALIDATION_ERROR',
                        'message': error_message
                    }
                }
            
            # Extract input data
            products = input_data['products']
            order_history = input_data['orderHistory']
            current_month = input_data['currentMonth']
            climate_data = input_data['climateData']
            
            # Step 2: Run stock analysis
            stock_metrics = self.stock_analyzer.analyze(products, order_history)
            
            # Step 3: Run performance segmentation
            performance_metrics = self.performance_segmenter.segment(products, stock_metrics)
            
            # Step 4: Run seasonal analysis
            seasonal_metrics = self.seasonal_analyzer.analyze(products, current_month, climate_data)
            
            # Step 5: Run recommendation engine for each product
            recommendation_metrics = {}
            for product in products:
                product_id = product['productId']
                perf_data = performance_metrics.get(product_id, {})
                stock_data = stock_metrics.get(product_id, {})
                seasonal_data = seasonal_metrics.get(product_id, {})
                
                recommended_action, urgency_level = self.recommendation_engine.recommend(
                    product, perf_data, stock_data, seasonal_data
                )
                
                recommendation_metrics[product_id] = {
                    'recommendedAction': recommended_action,
                    'urgencyLevel': urgency_level
                }
            
            # Step 6: Run category analysis
            category_insights = self.category_analyzer.analyze(products, performance_metrics, stock_metrics)
            
            # Step 7: Run price segment analysis
            price_segment_analysis = self.price_segment_analyzer.analyze(products, performance_metrics, stock_metrics)
            
            # Step 8: Format output
            all_metrics = {
                'stock_metrics': stock_metrics,
                'performance_metrics': performance_metrics,
                'seasonal_metrics': seasonal_metrics,
                'recommendation_metrics': recommendation_metrics,
                'category_insights': category_insights,
                'price_segment_analysis': price_segment_analysis
            }
            
            result = self.output_formatter.format(products, all_metrics)
            
            return result
            
        except KeyError as e:
            return {
                'error': {
                    'code': 'MISSING_FIELD',
                    'message': f'Missing required field: {str(e)}',
                    'field': str(e)
                }
            }
        except Exception as e:
            return {
                'error': {
                    'code': 'INTERNAL_ERROR',
                    'message': str(e),
                    'details': {'type': type(e).__name__}
                }
            }


try:
    from bedrock_agentcore import BedrockAgentCoreApp
    app = BedrockAgentCoreApp()

    @app.entrypoint
    def invoke(payload):
        """AgentCore Runtime entrypoint for product analysis."""
        orchestrator = AgentOrchestrator()
        
        # Handle Sandbox format: {"prompt": "...json string..."}
        if isinstance(payload, dict) and 'prompt' in payload and len(payload) == 1:
            prompt_value = payload['prompt']
            if isinstance(prompt_value, str):
                # Try to extract JSON from the prompt string
                try:
                    parsed = json.loads(prompt_value)
                    if isinstance(parsed, dict) and 'tenantId' in parsed:
                        payload = parsed
                except (json.JSONDecodeError, ValueError):
                    # Try to find JSON object within the text
                    import re
                    match = re.search(r'\{.*\}', prompt_value, re.DOTALL)
                    if match:
                        try:
                            parsed = json.loads(match.group())
                            if isinstance(parsed, dict) and 'tenantId' in parsed:
                                payload = parsed
                        except (json.JSONDecodeError, ValueError):
                            pass
        
        result = orchestrator.execute(payload)
        return result

except ImportError:
    app = None


def lambda_handler(event, context):
    """AWS Lambda handler (fallback for non-AgentCore environments)."""
    orchestrator = AgentOrchestrator()
    result = orchestrator.execute(event)
    return {'statusCode': 200, 'body': json.dumps(result)}


if __name__ == "__main__":
    if app:
        app.run()
    else:
        # Local testing fallback
        import sys
        input_file = sys.argv[1] if len(sys.argv) > 1 else 'test_input_valid.json'
        with open(input_file, 'r') as f:
            test_input = json.load(f)
        orchestrator = AgentOrchestrator()
        result = orchestrator.execute(test_input)
        print(json.dumps(result, indent=2))
