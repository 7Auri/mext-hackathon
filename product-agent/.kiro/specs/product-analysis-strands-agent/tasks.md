# Implementation Plan: Product Analysis Strands Agent

## Overview

This implementation plan guides the development and deployment of a Product Analysis Strands Agent to Amazon Bedrock AgentCore Runtime. The agent will be implemented in Python using a model-driven architecture, deployed as a container to AWS Bedrock AgentCore, and tested with property-based testing. The implementation follows an incremental approach, building core analysis components first, then integrating them, and finally deploying to AWS.

## Tasks

- [x] 1. Set up project structure and dependencies
  - Create product_analysis_agent.py in the root directory
  - Activate uv virtual environment (.venv)
  - Install required dependencies: boto3, hypothesis (for property testing)
  - Create requirements.txt with pinned versions
  - _Requirements: 3.1, 3.2, 3.3_

- [ ] 2. Implement input validation
  - [x] 2.1 Create InputValidator class with validate method
    - Validate presence of tenantId, products, orderHistory, currentMonth, climateData
    - Validate data types for each field
    - Validate currentMonth is between 1-12
    - Validate products array is non-empty
    - Return tuple of (is_valid, error_message)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_
  
  - [ ]* 2.2 Write property test for input validation
    - **Property 19: Input Validation**
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7**
    - Generate random valid and invalid inputs
    - Verify error messages for missing fields
  
  - [ ]* 2.3 Write unit tests for input validation edge cases
    - Test missing tenantId
    - Test empty products array
    - Test invalid month values (0, 13, -1)
    - Test invalid data types
    - _Requirements: 6.6, 6.7_

- [ ] 3. Implement stock analysis
  - [x] 3.1 Create StockAnalyzer class
    - Implement calculate_daily_sales_rate method (aggregate sales from orderHistory, divide by 90)
    - Implement calculate_stock_days method (stock / dailySalesRate, or 999 if zero)
    - Implement classify_stock_segment method (Critical <15, Healthy 15-60, Excess >60)
    - Implement analyze method to process all products
    - _Requirements: 1.2, 1.3, 1.5, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_
  
  - [ ]* 3.2 Write property test for stock analysis calculation
    - **Property 1: Stock Analysis Calculation**
    - **Validates: Requirements 1.2, 1.3, 7.1, 7.2, 7.3**
    - Generate random products and order histories
    - Verify dailySalesRate = totalSales / 90
    - Verify stockDays = stock / dailySalesRate (or 999 if zero)
  
  - [ ]* 3.3 Write property test for stock segment classification
    - **Property 2: Stock Segment Classification**
    - **Validates: Requirements 1.5, 7.4, 7.5, 7.6**
    - Generate random stockDays values
    - Verify classification thresholds
  
  - [ ]* 3.4 Write property test for inventory pressure flag
    - **Property 3: Inventory Pressure Flag**
    - **Validates: Requirements 7.7**
    - Generate random stockDays values
    - Verify inventoryPressure = true when stockDays > 60
  
  - [ ]* 3.5 Write unit tests for stock analysis edge cases
    - Test zero sales (stockDays should be 999)
    - Test boundary values (stockDays = 15, 60)
    - Test negative values handling
    - _Requirements: 7.3_

- [ ] 4. Implement performance segmentation
  - [x] 4.1 Create PerformanceSegmenter class
    - Implement classify_performance method (Rising, Star, Steady, Underperformer logic)
    - Implement calculate_margin_health method (margin calculation and EXCELLENT/GOOD/MODERATE/POOR classification)
    - Implement classify_price_segment method (BUDGET <=200, MID 201-500, PREMIUM >500)
    - Implement segment method to process all products
    - _Requirements: 1.4, 1.7, 1.8, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 13.1, 13.2, 13.3_
  
  - [ ]* 4.2 Write property test for performance segment classification
    - **Property 4: Performance Segment Classification**
    - **Validates: Requirements 1.4, 8.1, 8.2, 8.3, 8.4**
    - Generate random products with various trendScore, lifecycleStage, stockDays
    - Verify classification rules
  
  - [ ]* 4.3 Write property test for margin health calculation
    - **Property 5: Margin Health Calculation**
    - **Validates: Requirements 1.7, 8.5, 8.6, 8.7, 8.8, 8.9**
    - Generate random cost and basePrice values
    - Verify margin formula and health classification
  
  - [ ]* 4.4 Write property test for price segment classification
    - **Property 6: Price Segment Classification**
    - **Validates: Requirements 1.8, 13.1, 13.2, 13.3**
    - Generate random basePrice values
    - Verify segment classification thresholds
  
  - [ ]* 4.5 Write unit tests for performance segmentation edge cases
    - Test boundary values (trendScore = 60, 80, 85; stockDays = 30, 60)
    - Test NEW lifecycle with various trendScores
    - Test margin calculation with zero cost
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 5. Checkpoint - Ensure core analysis components work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement seasonal analysis
  - [x] 6.1 Create SeasonalAnalyzer class
    - Implement get_current_season method (month to season mapping)
    - Implement check_season_match method (isSeasonal and seasonCode logic)
    - Implement check_climate_rules method (evaluate HIGH_HUMIDITY, LOW_TEMP, HIGH_RAINFALL, SEASON_TAG)
    - Implement analyze method to process all products
    - _Requirements: 1.6, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_
  
  - [ ]* 6.2 Write property test for season determination
    - **Property 7: Season Determination**
    - **Validates: Requirements 9.1**
    - Generate random month values (1-12)
    - Verify season mapping (3-5: SPRING, 6-8: SUMMER, 9-11: FALL, 12/1-2: WINTER)
  
  - [ ]* 6.3 Write property test for seasonal relevance determination
    - **Property 8: Seasonal Relevance Determination**
    - **Validates: Requirements 1.6, 9.2, 9.3, 9.4, 9.6, 9.7, 9.8**
    - Generate random products with various seasonCode, isSeasonal, climate matches
    - Verify seasonMatch and seasonalRelevance logic
  
  - [ ]* 6.4 Write property test for climate rules evaluation
    - **Property 9: Climate Rules Evaluation**
    - **Validates: Requirements 9.5**
    - Generate random seasonalityRules and climateData
    - Verify rule evaluation for each rule type
  
  - [ ]* 6.5 Write unit tests for seasonal analysis edge cases
    - Test isSeasonal = false (should always match)
    - Test seasonCode = "all" (should always match)
    - Test empty seasonalityRules
    - Test empty climateData
    - _Requirements: 9.2, 9.5_

- [ ] 7. Implement recommendation engine
  - [x] 7.1 Create RecommendationEngine class
    - Implement recommend method with priority-based decision logic
    - Priority order: RESTOCK (Star+Critical), FEATURE (Rising), PROMOTE (Star+Healthy), SEASONAL_PUSH (HIGH+not Critical), CLEARANCE (Excess+DECLINING), BUNDLE (Excess+MODERATE), DISCOUNT (Underperformer), MAINTAIN (default)
    - Return tuple of (recommendedAction, urgencyLevel)
    - _Requirements: 1.9, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_
  
  - [ ]* 7.2 Write property test for recommendation generation
    - **Property 10: Recommendation Generation**
    - **Validates: Requirements 1.9, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8**
    - Generate random combinations of performanceSegment, stockSegment, seasonalRelevance, lifecycleStage, marginHealth
    - Verify recommendation follows priority logic
  
  - [ ]* 7.3 Write unit tests for recommendation edge cases
    - Test each priority condition explicitly
    - Test default MAINTAIN case
    - Test conflicting conditions (verify priority order)
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_

- [ ] 8. Implement aggregation analyzers
  - [x] 8.1 Create CategoryAnalyzer class
    - Group products by category
    - Calculate totalProducts, avgTrendScore, totalStock, avgStockDays
    - Count topPerformers (Star or Rising) and underperformers
    - Determine performanceRating (STRONG >80, MODERATE 65-80, WEAK <=65)
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 8.2 Create PriceSegmentAnalyzer class
    - Group products by priceSegment
    - Calculate productCount, avgTrendScore
    - Calculate stockHealth (GOOD >70% Healthy, MODERATE 40-70%, POOR <40%)
    - _Requirements: 13.4, 13.5, 13.6, 13.7, 13.8, 13.9_
  
  - [ ]* 8.3 Write property test for category analysis aggregation
    - **Property 16: Category Analysis Aggregation**
    - **Validates: Requirements 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9**
    - Generate random product sets
    - Verify aggregation calculations and performanceRating thresholds
  
  - [ ]* 8.4 Write property test for price segment analysis aggregation
    - **Property 17: Price Segment Analysis Aggregation**
    - **Validates: Requirements 13.4, 13.5, 13.6, 13.7, 13.8, 13.9**
    - Generate random product sets
    - Verify aggregation calculations and stockHealth thresholds
  
  - [ ]* 8.5 Write unit tests for aggregation edge cases
    - Test empty categories
    - Test single product per category
    - Test all products in one price segment
    - _Requirements: 12.1, 13.4_

- [ ] 9. Implement output formatter
  - [x] 9.1 Create OutputFormatter class
    - Implement format method to structure ProductInsightJSON
    - Implement segmentation methods: filter and sort heroProducts (top 10 Star/Rising by trendScore), slowMovers (top 15 Excess/Underperformer by stockDays), newProducts (all NEW by trendScore), seasonalProducts (top 10 HIGH relevance)
    - Implement calculate_inventory_summary method (totalProducts, totalStockValue, critical/excess/healthy counts, avgStockDays, inventoryTurnoverRate)
    - _Requirements: 1.10, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7_
  
  - [ ]* 9.2 Write property test for output structure validation
    - **Property 11: Output Structure Validation**
    - **Validates: Requirements 1.10, 11.5, 11.6, 11.7**
    - Generate random analysis results
    - Verify all required output fields are present
  
  - [ ]* 9.3 Write property test for hero products segmentation
    - **Property 12: Hero Products Segmentation**
    - **Validates: Requirements 11.1**
    - Generate random product sets
    - Verify only Star/Rising products, sorted by trendScore, max 10
  
  - [ ]* 9.4 Write property test for slow movers segmentation
    - **Property 13: Slow Movers Segmentation**
    - **Validates: Requirements 11.2**
    - Generate random product sets
    - Verify only Excess/Underperformer products, sorted by stockDays, max 15
  
  - [ ]* 9.5 Write property test for new products segmentation
    - **Property 14: New Products Segmentation**
    - **Validates: Requirements 11.3**
    - Generate random product sets
    - Verify all NEW products, sorted by trendScore
  
  - [ ]* 9.6 Write property test for seasonal products segmentation
    - **Property 15: Seasonal Products Segmentation**
    - **Validates: Requirements 11.4**
    - Generate random product sets
    - Verify only HIGH seasonalRelevance products, max 10
  
  - [ ]* 9.7 Write property test for inventory summary calculation
    - **Property 18: Inventory Summary Calculation**
    - **Validates: Requirements 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7**
    - Generate random product sets
    - Verify all inventory metrics calculations
  
  - [ ]* 9.8 Write unit tests for output formatting edge cases
    - Test empty product sets
    - Test fewer than 10 hero products
    - Test no NEW products
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

- [x] 10. Checkpoint - Ensure all components work independently
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Implement agent orchestrator
  - [x] 11.1 Create AgentOrchestrator class
    - Implement execute method as main entry point
    - Coordinate execution: validate input → stock analysis → performance segmentation → seasonal analysis → recommendations → category/price analysis → output formatting
    - Integrate all analyzer components
    - Handle errors and return error responses in consistent format
    - _Requirements: 1.1, 1.10_
  
  - [ ]* 11.2 Write integration tests for end-to-end flow
    - Test complete input → output flow with realistic data
    - Verify all output sections are populated
    - Verify data consistency across sections
    - _Requirements: 1.1, 1.10_
  
  - [ ]* 11.3 Write unit tests for error handling
    - Test error response format
    - Test error propagation from components
    - Test graceful handling of partial failures
    - _Requirements: 6.7_

- [ ] 12. Implement model-driven architecture integration
  - [~] 12.1 Add AI model integration for planning and reasoning
    - Use boto3 to invoke Bedrock foundation model
    - Implement planning logic for workflow coordination
    - Implement reasoning logic for segmentation decisions
    - Implement tool calling for analysis function execution
    - Implement self-reflection for output validation
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [ ]* 12.2 Write integration tests for model-driven behavior
    - Test agent can plan analysis workflow
    - Test agent can reason about segmentation
    - Test agent can call analysis tools
    - Test agent can validate its own output
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 13. Create test data and validation
  - [x] 13.1 Create test input data files
    - Create test_input_valid.json with realistic product data
    - Create test_input_invalid.json with various error cases
    - Use data/products.json as reference for structure
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 13.2 Create expected output data files
    - Create test_output_expected.json with expected analysis results
    - Document expected values for each test scenario
    - _Requirements: 1.10_
  
  - [ ]* 13.3 Write validation tests comparing actual vs expected output
    - Load test input and expected output
    - Run agent and compare results
    - Verify numerical accuracy (within tolerance)
    - _Requirements: 1.10_

- [x] 14. Checkpoint - Ensure complete agent works end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [x] 15. Prepare for AWS deployment
  - [x] 15.1 Create Dockerfile for agent containerization
    - Base image: python:3.11-slim
    - Copy product_analysis_agent.py and dependencies
    - Install requirements
    - Set entrypoint for agent execution
    - _Requirements: 4.5_
  
  - [x] 15.2 Create deployment configuration
    - Document AWS profile: workshop-profile
    - Document region: us-east-1
    - Document agent name: product_analysis_agent_kiro
    - _Requirements: 4.1, 4.2, 4.5_
  
  - [x] 15.3 Create deployment script
    - Script to run agentcore configure, launch, and invoke
    - Include error handling and status checks
    - _Requirements: 4.3, 4.4, 4.5, 4.6_

- [ ] 16. Deploy to AWS Bedrock AgentCore Runtime
  - [x] 16.1 Run agentcore configure
    - Execute: agentcore configure --profile workshop-profile --region us-east-1
    - Verify IAM Role creation
    - Verify ECR repository creation
    - Capture IAM Role ARN and ECR URI
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 16.2 Run agentcore launch
    - Execute: agentcore launch --name product_analysis_agent_kiro --profile workshop-profile --region us-east-1
    - Verify agent deployment to AgentCore Runtime
    - Capture AgentCore ARN
    - _Requirements: 4.5_
  
  - [x] 16.3 Run agentcore invoke for testing

- [x] 17. Create API documentation
  - [x] 17.1 Generate product-analysis-agent-api.md
    - Include AgentCore ARN from deployment
    - Include IAM Role ARN from deployment
    - Include ECR Repository URI from deployment
    - Include example input JSON format
    - Include example output JSON format
    - Include Python code example for invoking agent via boto3
    - Include JavaScript/TypeScript code example for frontend integration
    - Include error response examples
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_
  
  - [ ]* 17.2 Validate API documentation completeness
    - Verify all required sections are present
    - Verify code examples are syntactically correct
    - Verify ARNs and URIs are valid
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

- [x] 18. Clean up temporary files
  - [x] 18.1 Identify temporary test files
    - List all test data files created during development
    - List any temporary scripts or logs
    - _Requirements: 15.1_
  
  - [x] 18.2 Delete temporary files
    - Remove temporary test files
    - Preserve production code and documentation
    - Preserve test_input_valid.json and test_output_expected.json for reference
    - _Requirements: 15.2, 15.3_

- [ ] 19. Final checkpoint - Verify deployment and documentation
  - Ensure agent is deployed and accessible
  - Ensure API documentation is complete
  - Ensure all tests pass
  - Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional property-based and unit tests that can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties with minimum 100 iterations
- Unit tests validate specific examples and edge cases
- The agent uses a model-driven approach leveraging AI for planning, reasoning, tool calling, and self-reflection
- All development must be done in the uv virtual environment (.venv)
- Deployment uses workshop-profile AWS configuration in us-east-1 region
- The implementation follows the PRODUCT_ANALYSIS_AGENT.md specification exactly
