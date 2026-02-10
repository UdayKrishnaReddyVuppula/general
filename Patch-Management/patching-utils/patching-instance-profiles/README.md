# Patching Instance Profiles

This folder contains templates for managing instance profiles for patching.

## Components

### function

Template for creating a Lambda function that attaches instance profiles to EC2 instances.

#### Required Configuration Values

- **NamePrefix**: Prefix for resource names
- **SNSEnabled**: Whether to enable SNS notifications
- **SNSTopic**: ARN of the SNS topic for notifications
- **AutomationName**: Name of the automation for notifications
- **PatchInstanceS3ManagedPolicyName**: Name of the S3 managed policy
- **InstanceProfileName**: Name of the instance profile
- **PatchInstanceRoleName**: Name of the instance role

#### Resources Created

- Config rule for monitoring instance profiles
- Lambda function for attaching instance profiles
- IAM roles and policies
- EventBridge rule for monitoring compliance changes

### patch-instance-remediation-role

Template for creating IAM roles for patch remediation.

### roles

Template for creating IAM roles and instance profiles for patching.

## Deployment Instructions

### function

```yaml
stack_name: AllCloud-PatchMGMT-InstanceProfiles-Function
depends_on: AllCloud-PatchMGMT-InstanceProfiles
type: cloudformation
properties:
  cloudformation:
    template_name: template.yaml
params:
  NamePrefix: `NAME_PREFIX`
  SNSEnabled: "true"
  SNSTopic: `SNS_TOPIC_ARN`
  AutomationName: "SSMPolicies"
  PatchInstanceS3ManagedPolicyName: "PatchInstanceS3ManagedPolicy"
  InstanceProfileName: "`NAME_PREFIX`-PatchInstanceProfile"
  PatchInstanceRoleName: "`NAME_PREFIX`-PatchInstanceRole"
targets:
  - `TARGET_ACCOUNT_OR_OU`
regions:
  - `TARGET_REGION`
```

## How It Works

1. The Config rule monitors for EC2 instances without instance profiles
2. When an instance is found to be non-compliant, the EventBridge rule triggers the Lambda function
3. The Lambda function attaches the specified instance profile to the instance
4. If the instance already has an instance profile, the Lambda function ensures it has the required policies
5. If there's an error, a notification is sent to the SNS topic

## Notes

- The instance profile and role must be created before deploying this template
- The Lambda function requires permissions to attach instance profiles and policies
- The SNS topic must be created before deploying this template
- The PatchInstanceS3ManagedPolicy must be created before deploying this template