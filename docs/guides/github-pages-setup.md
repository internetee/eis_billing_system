# GitHub Pages Setup Guide

This guide explains how to configure GitHub Pages for automatic API documentation deployment.

## Prerequisites

- Admin access to the GitHub repository
- Repository must be public or organization must have GitHub Pages enabled for private repos

## Setup Steps

### 1. Enable GitHub Pages

1. Go to repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Save the changes

### 2. Workflow Configuration

The workflow file `.github/workflows/deploy-docs.yml` is already configured and will:

- Trigger on every push to `master`/`main` branch
- Generate static Apipie documentation
- Deploy to GitHub Pages automatically

### 3. First Deployment

After enabling GitHub Pages and pushing the workflow file:

1. Push changes to `master`/`main` branch
2. Go to **Actions** tab in GitHub
3. Wait for "Deploy API Documentation" workflow to complete
4. Documentation will be available at: `https://internetee.github.io/eis_billing_system/`

## Manual Trigger

You can manually trigger documentation deployment:

1. Go to **Actions** tab
2. Select "Deploy API Documentation" workflow
3. Click **Run workflow** button
4. Select the branch and click **Run workflow**

## Accessing Documentation

Once deployed, the API documentation will be available at:

**Public URL**: https://internetee.github.io/eis_billing_system/

## Troubleshooting

### Workflow Fails

If the deployment workflow fails:

1. Check **Actions** tab for error messages
2. Ensure PostgreSQL service starts correctly
3. Verify all dependencies are installed
4. Check that `apipie:static` rake task runs successfully locally

### Documentation Not Updating

If documentation doesn't update after push:

1. Check workflow status in **Actions** tab
2. Verify changes were pushed to `master`/`main` branch
3. Clear browser cache and hard refresh
4. Wait a few minutes for GitHub Pages CDN to update

### 404 Error on GitHub Pages URL

1. Ensure GitHub Pages is enabled in repository settings
2. Verify workflow completed successfully
3. Check that files were uploaded in workflow logs
4. Confirm repository visibility (public or private with Pages enabled)

## Local Testing

To test documentation generation locally before pushing:

```bash
# Generate static documentation
bundle exec rake apipie:static

# View generated files
open public/apipie/index.html
```

## Updating Documentation

Documentation is automatically updated on every push to `master`/`main`. To update:

1. Make changes to API controller documentation (using Apipie DSL)
2. Commit and push changes
3. GitHub Actions will automatically regenerate and deploy

Example of adding API documentation:

```ruby
# app/controllers/api/v1/example_controller.rb
api! 'Description of the endpoint'
param :field_name, String, required: true, desc: 'Field description'
def action_name
  # controller logic
end
```

## Security Note

The GitHub Pages documentation is publicly accessible. Ensure:

- No sensitive information in API examples
- No production credentials in code comments
- No internal infrastructure details exposed

For sensitive documentation, use the local `/apipie` endpoint with authentication.
