#!/bin/bash
# List all quota names for a service
# Usage: ./list_quotas.sh <service-code>

SERVICE_CODE=$1

if [ -z "$SERVICE_CODE" ]; then
    echo "Usage: $0 <service-code>"
    echo "Example: $0 vpc"
    echo ""
    echo "Common service codes:"
    echo "  vpc, ec2, rds, lambda, ecs, fargate, elasticloadbalancing"
    exit 1
fi

echo "Quota names for service: $SERVICE_CODE"
echo "---"

aws service-quotas list-service-quotas \
    --service-code "$SERVICE_CODE" \
    --query 'Quotas[].[QuotaName,QuotaCode,Value,Adjustable]' \
    --output table
