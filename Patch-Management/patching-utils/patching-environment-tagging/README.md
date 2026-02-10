# Patching Environment Tagging

This folder contains templates for automatically tagging resources with environment tags.

## Components

### sandbox

Template for tagging resources in the sandbox environment.

#### Required Configuration Values

- **NamePrefix**: Prefix for resource names
- **Environment**: Environment name (e.g., "Dev", "Prod")
- **SNSTopic**: ARN of the SNS topic for notifications
- **AutomationName**: Name of the automation for notifications

#### Resources Created

- Lambda function for tagging resources
- IAM roles and policies
- EventBridge rule for monitoring resource creation

## Deployment Instructions

```yaml
stack_name: resource-env-tagging-`ENVIRONMENT`
type: cloudformation
properties:
  cloudformation:
    template_name: template.yaml
params:
  NamePrefix: `NAME_PREFIX`
  Environment: `ENVIRONMENT`
  SNSTopic: `SNS_TOPIC_ARN`
  AutomationName: "EnvironmentTagging"
targets:
  - `TARGET_ACCOUNT_OR_OU`
regions:
  - `TARGET_REGION`
```

## How It Works

1. The EventBridge rule monitors for EC2 instance creation, RDS cluster creation, and RDS instance creation events
2. When a resource is created, the Lambda function is triggered
3. The Lambda function adds an "environment" tag to the resource with the specified Environment value
4. If there's an error, a notification is sent to the SNS topic

## Notes

- The Lambda function only tags resources that don't already have an "environment" tag
- The Lambda function requires permissions to tag EC2 instances and RDS resources
- The SNS topic must be created before deploying this template
- The Environment value should match the patching phase value used in other templates