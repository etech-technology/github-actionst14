# Notes


### 1. Introduce the objective

A push to `main` should automatically copy files from `website/` into Amazon S3.

### 2. Explain the trigger

```yaml
on:
  push:
    branches:
      - main
    paths:
      - "website/**"
  workflow_dispatch:
```

### 3. Explain permissions

```yaml
permissions:
  contents: read
  id-token: write
```

- `contents: read` allows checkout.
- `id-token: write` allows GitHub to request an OIDC token.

### 4. Explain job dependency

```yaml
deploy:
  needs: validate
```

Deployment only starts after validation succeeds.

### 5. Explain AWS authentication

GitHub provides an identity token. AWS validates it and issues temporary credentials for the IAM role.

### 6. Explain synchronization

```bash
aws s3 sync website/ "s3://${S3_BUCKET_NAME}" --delete
```

- Uploads new files.
- Updates changed files.
- Skips unchanged files.
- Deletes remote files removed locally.

### 7. Demonstrate a successful run

Modify the heading, commit, and push.

### 8. Demonstrate a failure

Temporarily change the `S3_BUCKET_NAME` repository variable to an invalid bucket. Rerun and inspect the logs. Restore the correct value afterward.

### Discussion questions

1. Why is OIDC safer than long-lived AWS keys?
2. What happens when validation fails?
3. Why is `--delete` useful and potentially dangerous?
4. Why is the IAM policy restricted to one bucket?
5. Why should production deployments use environment approvals?
