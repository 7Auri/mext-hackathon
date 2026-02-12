# Cross-Account IAM Yapılandırması

Product Analysis Agent'a farklı bir AWS hesabından erişim sağlamak için gereken IAM policy'leri.

## Senaryo

- **Agent sahibi hesap:** 853548971581 (us-west-2)
- **Kampanya agent hesabı:** KAMPANYA_HESAP_ID (değiştirilecek)

## Kurulum

### Adım 1: Agent Sahibi Hesapta (853548971581)

Yeni bir IAM Role oluştur veya mevcut role'e trust policy ekle:

```bash
# Yeni cross-account role oluştur
aws iam create-role \
  --role-name ProductAgentCrossAccountRole \
  --assume-role-policy-document file://iam/cross-account-trust-policy.json \
  --region us-west-2

# Invoke iznini ekle
aws iam put-role-policy \
  --role-name ProductAgentCrossAccountRole \
  --policy-name InvokeProductAgent \
  --policy-document file://iam/cross-account-invoke-policy.json
```

### Adım 2: Kampanya Agent Hesabında (KAMPANYA_HESAP_ID)

Kampanya agent'ın IAM role'üne şu izni ekle:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::853548971581:role/ProductAgentCrossAccountRole"
    }
  ]
}
```

### Adım 3: Kampanya Agent Kodunda Kullanım

```python
import boto3

# 1. STS ile cross-account role assume et
sts_client = boto3.client('sts')
assumed_role = sts_client.assume_role(
    RoleArn='arn:aws:iam::853548971581:role/ProductAgentCrossAccountRole',
    RoleSessionName='campaign-agent-session',
    ExternalId='campaign-agent-access'
)

credentials = assumed_role['Credentials']

# 2. Geçici credentials ile agent'ı çağır
agentcore_client = boto3.client(
    'bedrock-agentcore-runtime',
    region_name='us-west-2',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken']
)

# 3. Product Analysis Agent'ı invoke et
response = agentcore_client.invoke_agent(
    agentId='product_analysis_agent_kiro-DbG83rES5F',
    sessionId='campaign-session-123',
    inputText=json.dumps(product_input)
)

result = json.loads(response['output'])
```

## Önemli

- `KAMPANYA_HESAP_ID` değerini gerçek AWS hesap ID'si ile değiştirin
- ExternalId güvenlik için kullanılır, her iki tarafta da aynı olmalı
- Geçici credentials 1 saat geçerlidir (varsayılan)
- Production'da credentials'ı cache'leyin ve expire olmadan önce yenileyin
