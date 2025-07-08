#!/bin/bash

# List of buckets
buckets=("bucketname-1" "bucketname-2")
region="us-west-2"

for bucket in "${buckets[@]}"; do
  echo "Cleaning bucket: $bucket"

  # Delete all object versions
  aws s3api list-object-versions --bucket "$bucket" --region "$region" --query 'Versions[].{Key: Key, VersionId: VersionId}' --output json > versions.json
  jq '{Objects: .}' versions.json > delete-versions.json
  aws s3api delete-objects --bucket "$bucket" --region "$region" --delete file://delete-versions.json

  # Delete all delete markers
  aws s3api list-object-versions --bucket "$bucket" --region "$region" --query 'DeleteMarkers[].{Key: Key, VersionId: VersionId}' --output json > deletemarkers.json
  jq '{Objects: .}' deletemarkers.json > delete-deletemarkers.json
  aws s3api delete-objects --bucket "$bucket" --region "$region" --delete file://delete-deletemarkers.json

  echo "Finished cleaning bucket: $bucket"
done

# Optional: delete the empty buckets
for bucket in "${buckets[@]}"; do
  aws s3 rb "s3://$bucket" --region "$region"
done

echo "✅ Cleanup completed"

