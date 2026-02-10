# Pre and Post Patching Events

This folder contains templates for creating EventBridge rules that trigger notifications before and after patching operations.

## Components

### sandbox-pre-post-notification

Template for creating EventBridge rules for the sandbox environment.

#### Required Configuration Values

- **PhaseName**: Name of the patching phase (e.g., "sandbox_maintenance_window")
- **LambdaTargetArn**: ARN of the notification Lambda function
- **ActualMWCron**: Cron expression used by the actual maintenance window
- **PreSchedule**: Cron expression for the pre-patch notification
- **PostSchedule**: Cron expression for the post-patch notification
- **WindowNames**: JSON array of maintenance window names
- **SNSArn**: ARN of the SNS topic for notifications
- **AwsAccounts**: Comma-separated list of AWS account IDs

#### Resources Created

- EventBridge rule for pre-patching notifications
- EventBridge rule for post-patching notifications
- Targets for the notification Lambda function

## Deployment Instructions

```yaml
stack_name: `ENVIRONMENT`-rules
type: cloudformation
properties:
  cloudformation:
    template_name: template.yaml
params:
  PhaseName: `ENVIRONMENT`_maintenance_window
  LambdaTargetArn: `NOTIFICATION_LAMBDA_ARN`
  ActualMWCron: "cron(0 20 ? * Sun#3 *)"
  PreSchedule: "cron(0 20 ? * Sun#2 *)"
  PostSchedule: "cron(0 23 ? * Mon#4 *)"
  WindowNames: '["ENVIRONMENT_maintenance_window"]'
  SNSArn: `SNS_TOPIC_ARN`
  AwsAccounts: "`SPOKE_ACCOUNT_IDS`"
targets:
  - <AUDIT_ACCOUNT>
regions:
  - global_main-region
```

## How It Works

1. The pre-patching EventBridge rule triggers the notification Lambda function before the maintenance window starts
2. The Lambda function sends a notification to the SNS topic with details of the upcoming patching operation
3. The post-patching EventBridge rule triggers the notification Lambda function after the maintenance window ends
4. The Lambda function sends a notification to the SNS topic with details of the completed patching operation

## Notes

- The notification Lambda function must be created before deploying this template
- The SNS topic must be created before deploying this template
- The cron expressions should be valid and aligned with the maintenance window schedule
- The WindowNames parameter should be a valid JSON array string
- The AwsAccounts parameter should be a comma-separated list of AWS account IDs