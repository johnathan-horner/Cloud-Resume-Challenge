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

## Protection (done 2026-10-23)

- `.git/`, `infra/`, `Cloudresume/`, `.github/`, dotfiles and every stored version of them were
  permanently deleted from the bucket.
- The bucket policy has a `DenyHiddenAndStateFiles` statement that denies reading or uploading any
  key starting with a dot or containing `/.`, and any `*.tfstate`, `*.tfstate.*`, `*.tfvars`,
  `*.tfplan`, `*.log` or `logs/*` key. A sync that includes them now fails instead of publishing them.
  The same statement is on the portfolio and root-domain buckets.

## Terraform state

State is in the private bucket `jhorner-terraform-state-194959907772` (public access blocked,
versioned, encrypted, TLS only) at `cloud-resume/terraform.tfstate`, with S3-native locking
(`use_lockfile = true`). Run `terraform init` in `infra/` to use it. Local state files are ignored
by git.

The visitor counter calls a Lambda function URL defined in `infra/` (Terraform).
