#!/usr/bin/env bash
set -e -o pipefail

# This script is used to get all the accounts in the organization and then get the account id for the account name and create a block in `~/.aws/credentials` file for the account.

# Make sure AWS_PROFILE is set, exit if not set
if [ -z "$AWS_PROFILE" ]; then
  echo "AWS_PROFILE is not set. Please set the AWS_PROFILE environment variable to the profile you want to use."
  exit 1
fi

# check for the required tools to be installed
for tool in jq aws; do
  if ! command -v $tool &> /dev/null; then
    echo "$tool is required but it's not installed. Please install $tool."
    exit 1
  fi
done

# Get the account id for the AWS_PROFILE
root_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

# Get the account alias for the AWS_PROFILE
root_account_alias=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)

# create a temporary file to store the account ids
temp_file=$(mktemp)
temp_file2=$(mktemp)
temp_file3=$(mktemp)

# cleanup the temp file on exit
trap 'rm -f $temp_file $temp_file2 $temp_file3' EXIT

# replace $FROM with $TO in the account name
FROM=${1:-""}
TO=${2:-""}
ROLE=${3:-"allcloud-admins"}

# if this is a Mac use md5 instead of md5sum
if [[ $(uname) == "Darwin" ]]; then
  alias md5sum="md5"
fi

# loop through all the accounts in the organization until the next token is null
next_token=""

while true; do
  # get the accounts in the organization
  # if the next token is not null, then pass the next token to get the next set of accounts
  if [[ $next_token ]]; then
    aws organizations list-accounts --max-results 20 --next-token "$next_token" > "$temp_file"
  else
    aws organizations list-accounts --max-results 20 > "$temp_file"
  fi

  # loop through the accounts and get the account id for the account name
  while read -r account_id account_name; do
    [[ $account_id == "$root_account_id" ]] && continue
    # lower case account name before replacing
    account_name=${account_name,,}
    # replace $FROM in the account name with $TO
    [[ "$FROM" ]] && account_name=${account_name//$FROM/$TO}
    # lower case account name after replacing
    account_name=${account_name,,}
    # replace spaces with dashes
    account_name=${account_name// /-}
    # ensure the account is prefixed with $TO
    [[ $account_name == "$TO"* ]] || account_name="$TO-$account_name"

    echo "Found Account Name: $account_name, Account Id: $account_id"
    echo "$account_name=$account_id" >> "$temp_file2"

    # echo "$account_name=$account_id" >> $temp_file
  done < <(jq -r '.Accounts[] | "\(.Id) \(.Name)"' "$temp_file")

  # get the next token
  next_token=$(jq -r '.NextToken' "$temp_file")

  # break the loop if the next token is null
  if [ -z "$next_token" ] || [ "$next_token" == "null" ]; then
    break
  fi
done

# backup the credentials file, just in case
cp ~/.aws/credentials ~/.aws/credentials.bak

# add the parent account block to the credentials file
{ echo "#####################################################" ;
  echo "# Start of $AWS_PROFILE account blocks";
  echo "#####################################################";
  echo "[$AWS_PROFILE]";
  echo "aws_account_id = $root_account_id";
  echo "# region = eu-central-1";
  [[ $root_account_alias != "None" ]] && echo "aws_account_alias = $root_account_alias";
  echo "";
} >> "$temp_file3"

# sort the accounts by account name and loop
sort "$temp_file2" | while read -r line; do
    account_name=$(echo "$line" | cut -d'=' -f1)
    account_id=$(echo "$line" | cut -d'=' -f2)


    { echo "[$account_name]";
    echo "role_arn = arn:aws:iam::$account_id:role/${ROLE}";
    echo "source_profile = $AWS_PROFILE";
    # create a HEX color code for the account based on the account_id
    echo "color = $(echo "$account_id" | md5sum | cut -c1-6)";
    echo ""; } >> "$temp_file3"

    # check if the account block already exists in the credentials file
    if grep -q "\[$account_name\]" ~/.aws/credentials; then
      echo "Account block for $account_name already exists in the credentials file. Skipping..."
      continue
    fi
    { echo "[$account_name]";
    echo "role_arn = arn:aws:iam::$account_id:role/${ROLE}";
    echo "source_profile = $AWS_PROFILE";
    # create a HEX color code for the account based on the account_id
    echo "color = $(echo "$account_id" | md5sum | cut -c1-6)";
    echo ""; } >> ~/.aws/credentials

done

if [[ -z "$temp_file3" ]]; then
  echo "No accounts found in the organization."
  exit 1
fi
# on Mac, copy the contents of the temp file to the clipboard
if [[ $(uname) == "Darwin" ]]; then
  pbcopy < "$temp_file3"
  echo "Account blocks created and copied to clipboard. Paste it to your AWS Switch Role extension."
else
  echo "Account blocks created. Copy and paste the following to your AWS Switch Role extension:"
  cat "$temp_file3"
fi

