# Engage Patch Management Solution

This repository contains the CloudFormation templates and configuration files for the Engage Patch Management solution. The solution provides automated patching capabilities for AWS EC2 instances across multiple accounts and regions.

## Architecture Overview

The solution consists of several components:
1. **Main Template** - Deploys core resources in the audit/central account
2. **Spoke Templates** - Deploys resources in target accounts
3. **Maintenance Windows** - Configures patching schedules
4. **Notifications** - Handles pre and post patching notifications
5. **Utilities** - Additional components for snapshots, tagging, etc.

## Deployment Order

1. Deploy the main template in the audit/central account
2. Deploy spoke templates in target accounts
3. Deploy maintenance windows in target accounts
4. Deploy additional utilities as needed

## Prerequisites

1. SSM agent running on all instances to be patched
2. Artifact bucket created in audit account with proper bucket policy and required zip files uploaded
3. Config recorder enabled and recording EC2 instances and EC2 tags for pre and post events to work
4. SNS topics created for notifications (for snapshots, integrate with audit account using DynamoDB)
5. Proper IAM permissions for cross-account access

## Important Configuration Values

- **CustomPatchingPhaseTagKey**: Used for tagging instances with their patching phase (e.g., `patch.allcloud.io/:phase`). This key is defined in the spoke templates.
- **CustomPatchingTagValue**: Value for the patching phase tag (e.g., `dev`, `prod`, `sandbox`). This value is required in both spoke templates and maintenance window configurations.
- **Environment**: Used for creating maintenance windows (e.g., `dev_maintenance_window`). The same value should be used in maintenance window configurations.

## Components

Each folder in this repository contains a specific component of the solution. See the README.md file in each folder for detailed information about that component.