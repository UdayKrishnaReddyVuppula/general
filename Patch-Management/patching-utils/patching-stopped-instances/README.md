# Patching Stopped Instances

This folder contains templates for managing stopped instances during patching operations.

## Components

### lambda

Template for creating Lambda functions that start and stop instances during patching.

### lambda-assumed-role

Template for creating IAM roles that can be assumed by the Lambda functions.

### sns-to-slack

Template for creating SNS topics and Lambda functions for sending notifications to Slack.