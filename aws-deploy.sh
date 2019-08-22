#!/bin/bash
# Super simple skript to build the website, upload it to s3 and invalidate the cloudfront cache
echo "Building"
hugo

echo "Uploading"
aws s3 sync ./public s3://lrau-page

echo "Refreshing Cloudfront Cache"
aws cloudfront create-invalidation --distribution-id E35M7KA9RKX114 --paths '/*'