# Patching Inspector Reports

This folder contains templates for creating Inspector reports on patching compliance.

## Components

### template.yml

Template for creating Inspector reports on patching compliance.

#### Required Configuration Values

- **NamePrefix**: Prefix for resource names
- **DevSchedule**: Cron expression for Dev environment reports
- **ProdSchedule**: Cron expression for Prod environment reports
- **SNSTopic**: ARN of the SNS topic for notifications
- **AutomationName**: Name of the automation for notifications
- **BucketName**: S3 bucket for storing reports
- **ReferenceBucketName**: S3 bucket containing reference data
- **ReferenceObjectKey**: Object key for reference data

#### Resources Created

- KMS key for encrypting reports
- Lambda function for generating reports
- IAM roles and policies
- EventBridge rules for scheduling reports

## Deployment Instructions

```yaml
stack_name: AllCloud-PatchMGMT-Inspector-Reports
type: cloudformation
properties:
  cloudformation:
    template_name: template.yml
params:
  NamePrefix: `NAME_PREFIX`
  DevSchedule: "0 10 ? * THU *"
  ProdSchedule: "0 11 ? * THU#4 *"
  SNSTopic: `SNS_TOPIC_ARN`
  AutomationName: "InspectorReports"
  BucketName: `REPORTS_BUCKET_NAME`
  ReferenceBucketName: `REFERENCE_BUCKET_NAME`
  ReferenceObjectKey: `REFERENCE_OBJECT_KEY`
targets:
  - <AUDIT_ACCOUNT>
regions:
  - global_main-region
```

## How It Works

1. The EventBridge rules trigger the Lambda function on the specified schedules
2. The Lambda function creates an Inspector report for the specified environment
3. The report is stored in the specified S3 bucket
4. The Lambda function processes the report to extract relevant information
5. The processed report is stored in the specified S3 bucket
6. If there's an error, a notification is sent to the SNS topic

## Notes

- The S3 buckets must be created before deploying this template
- The Lambda function requires permissions to create Inspector reports and access S3 buckets
- The SNS topic must be created before deploying this template
- The reference data should be a CSV file with account IDs and names