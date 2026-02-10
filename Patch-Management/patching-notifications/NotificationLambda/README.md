# Notification Lambda

This folder contains templates for creating a Lambda function that sends notifications about patching operations.

## Components

### template.yaml

Template for creating a Lambda function that sends notifications about patching operations.

#### Required Configuration Values

- **NamePrefix**: Prefix for resource names
- **AlertsEmail**: Email address for alerts
- **OrgID**: AWS Organization ID
- **AthenaOutputBucket**: S3 bucket for Athena query results
- **KMSKeyForS3**: ARN of the KMS key for S3 encryption
- **CustomPatchingTagKey**: Tag key used for identifying patching phase

#### Resources Created

- Lambda function for sending notifications
- IAM roles and policies
- Lambda layer for croniter dependency
- EventsRuleCreator role for cross-account access

## Deployment Instructions

```yaml
stack_name: AllCloud-PatchMGMT-patchNotification-Central
type: cloudformation
properties:
  cloudformation:
    template_name: template.yaml
params:
  NamePrefix: `NAME_PREFIX`
  AlertsEmail: `ALERTS_EMAIL`
  OrgID: `AWS_ORGANIZATION_ID`
  AthenaOutputBucket: `ATHENA_OUTPUT_BUCKET`
  KMSKeyForS3: `KMS_KEY_ARN`
  CustomPatchingTagKey: `PATCHING_TAG_KEY`
targets:
  - <AUDIT_ACCOUNT>
regions:
  - global_main-region
```

## How It Works

1. The Lambda function is triggered by EventBridge rules created by the pre-post-events templates
2. For pre-patching notifications, the Lambda function:
   - Gets the list of instances that will be patched
   - Sends a notification to the SNS topic with details of the upcoming patching operation
3. For post-patching notifications, the Lambda function:
   - Gets the list of instances that were patched
   - Queries Athena for non-compliant resources
   - Sends a notification to the SNS topic with details of the completed patching operation and any non-compliant resources

## Notes

- The S3 buckets must be created before deploying this template
- The Lambda function requires permissions to query Athena and access S3 buckets
- The SNS topic must be created before deploying this template
- The CustomPatchingTagKey should match the value used in the patching-core spoke templates