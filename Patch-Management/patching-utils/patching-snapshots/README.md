# Patching Snapshots

This folder contains templates for creating EBS snapshots before patching operations.

## Components

### sandbox-maintainance-window-snapshot

Template for creating snapshots before the sandbox maintenance window runs.

#### Required Configuration Values

- **CustomPatchingTagValue**: Value for the patching phase tag (e.g., "sandbox")

#### Resources Created

- SNS topic for notifications
- Lambda function for creating snapshots
- IAM roles and policies

## Deployment Instructions

```yaml
stack_name: AllCloud-patching-snapshot
type: cloudformation
properties:
  cloudformation:
    template_name: template.yml
params:
  CustomPatchingTagValue: "`PATCHING_TAG_VALUE`"
targets:
  - `TARGET_ACCOUNT_OR_OU`
regions:
  - `TARGET_REGION`
```

## How It Works

1. The Lambda function is triggered by the maintenance window
2. It looks for instances with the specified CustomPatchingTagValue tag
3. It creates snapshots of all EBS volumes attached to these instances
4. It sends a notification to the SNS topic with details of the snapshots created

## Notes

- The Lambda function is invoked by the maintenance window task
- The SNS topic is created by the template
- The snapshots are tagged with information about the patching operation
- The Lambda function requires permissions to create snapshots and send notifications
- **Important**: The snapshot lambda policy may need to be updated in the CloudFormation template based on your specific requirements
- For integration with the audit account, consider using DynamoDB with the SNS topic