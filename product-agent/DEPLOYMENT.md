# Deployment Configuration

## AWS Settings

| Setting | Value |
|---------|-------|
| AWS Profile | `workshop-profile` |
| Region | `us-east-1` |
| Agent Name | `product_analysis_agent_kiro` |

## Prerequisites

- AWS CLI configured with `workshop-profile`
- AgentCore CLI installed
- Docker installed (for containerization)
- Python 3.11+

## Deployment Steps

### 1. Configure AgentCore

```bash
agentcore configure --profile workshop-profile --region us-east-1
```

This creates:
- IAM Role for agent execution
- ECR repository for container images

### 2. Launch Agent

```bash
agentcore launch --name product_analysis_agent_kiro --profile workshop-profile --region us-east-1
```

### 3. Invoke Agent (Test)

```bash
agentcore invoke --arn <AGENT_ARN> --input test_input_valid.json --profile workshop-profile
```

## Post-Deployment

After deployment, update `product-analysis-agent-api.md` with:
- AgentCore ARN
- IAM Role ARN
- ECR Repository URI
