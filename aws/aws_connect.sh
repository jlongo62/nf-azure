CREDS_FILE="$HOME/secrets/terraform-credentials.json"
PROFILE="terraform"
REGION="us-east-2"

ACCESS_KEY_ID="$(jq -r '.access_key' "$CREDS_FILE")"
SECRET_ACCESS_KEY="$(jq -r '.secret_access_key' "$CREDS_FILE")"

test -n "$ACCESS_KEY_ID" &&
test "$ACCESS_KEY_ID" != "null" &&
test -n "$SECRET_ACCESS_KEY" &&
test "$SECRET_ACCESS_KEY" != "null" ||
{ echo "Missing access_key or secret_access_key in $CREDS_FILE"; return; }

aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile "$PROFILE"
aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile "$PROFILE"
aws configure set region "$REGION" --profile "$PROFILE"
aws configure set output json --profile "$PROFILE"

aws sts get-caller-identity --profile terraform

export AWS_PROFILE=terraform
export AWS_REGION=us-east-2

# unset ACCESS_KEY_ID SECRET_ACCESS_KEY
# chmod 700 ~/.aws
# chmod 600 ~/.aws/credentials ~/.aws/config