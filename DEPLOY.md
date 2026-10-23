# Deploying resume.johnathancloudspace.com

Hosting: S3 bucket `resume.johnathancloudspace.com` (static website, us-east-1) behind CloudFront
distribution `EEIE83V7L9F3H`. AWS account 194959907772.

Upload only the files the page uses. Do not sync the whole folder: an earlier sync put `.git/`,
`infra/` and `Cloudresume/infra/` (including `terraform.tfstate`) in the public bucket.

```bash
aws sts get-caller-identity                      # confirm account 194959907772
aws s3 cp index.html  s3://resume.johnathancloudspace.com/index.html  --content-type text/html
aws s3 cp robots.txt  s3://resume.johnathancloudspace.com/robots.txt
aws s3 cp sitemap.xml s3://resume.johnathancloudspace.com/sitemap.xml
aws s3 sync css    s3://resume.johnathancloudspace.com/css
aws s3 sync assets s3://resume.johnathancloudspace.com/assets
aws cloudfront create-invalidation --distribution-id EEIE83V7L9F3H --paths "/*"
```

One-time cleanup of files that should not be public (needs approval, it deletes objects):

```bash
aws s3 rm s3://resume.johnathancloudspace.com/.git/ --recursive
aws s3 rm s3://resume.johnathancloudspace.com/infra/ --recursive
aws s3 rm s3://resume.johnathancloudspace.com/Cloudresume/ --recursive
aws s3 rm s3://resume.johnathancloudspace.com/.DS_Store
```

The visitor counter calls a Lambda function URL defined in `infra/` (Terraform).
