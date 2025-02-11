# Use certificates to authenticate

Yes, you can configure your Terraform workflow to use the `source = github.com/org/repo` option directly without explicitly cloning the repository in the workflow. Terraform natively supports fetching modules from GitHub, including private repositories, as long as it has the necessary authentication.

Here’s how you can achieve this:

---

### 1. **Update Your Terraform Configuration**
In your Terraform configuration, reference the private module using the GitHub URL:

```hcl
module "example" {
  source = "github.com/your-org/your-private-repo?ref=main"
}
```

- Replace `your-org/your-private-repo` with the actual organization and repository name.
- The `ref` parameter specifies the branch, tag, or commit hash to use (e.g., `main`, `v1.0.0`, etc.).

---

### 2. **Generate a GitHub App Token**
As before, you’ll need a GitHub App token to authenticate Terraform with the private repository. Use the `actions/create-github-app-token` action to generate the token.

---

### 3. **Configure the Workflow**
Update your GitHub Actions workflow to pass the GitHub token to Terraform. Terraform will use this token to authenticate when fetching the private module.

Here’s an example workflow:

```yaml
name: Terraform Private Module Workflow

on:
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout this repository
        uses: actions/checkout@v3

      - name: Generate GitHub App Token
        id: generate-token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ secrets.GITHUB_APP_ID }}
          private-key: ${{ secrets.GITHUB_APP_PRIVATE_KEY }}

      - name: Initialize Terraform
        env:
          GITHUB_TOKEN: ${{ steps.generate-token.outputs.token }}
        run: |
          terraform init

      - name: Apply Terraform
        run: |
          terraform apply -auto-approve
```

---

### 4. **Explanation of the Workflow**
- **Generate GitHub App Token**: This step generates an installation access token for the GitHub App.
- **Initialize Terraform**: The `terraform init` command fetches the private module from GitHub. The `GITHUB_TOKEN` environment variable is automatically used by Terraform for authentication.
- **Apply Terraform**: The `terraform apply` command applies the configuration.

---

### 5. **How Terraform Authenticates with GitHub**
Terraform uses the `GITHUB_TOKEN` environment variable to authenticate with GitHub when fetching modules. This token is passed to Terraform in the workflow, and Terraform handles the rest.

---

### 6. **Advantages of This Approach**
- **No Manual Cloning**: You don’t need to explicitly clone the private repository in the workflow.
- **Native Terraform Support**: Terraform natively supports fetching modules from GitHub, making the configuration cleaner.
- **Secure Authentication**: The GitHub App token is used securely and only for the duration of the workflow.

---

### 7. **Optional: Use SSH for Authentication**
If you prefer to use SSH instead of a token, you can configure Terraform to use an SSH key for authentication. Update the module source to use the `git::` syntax:

```hcl
module "example" {
  source = "git::ssh://git@github.com/your-org/your-private-repo.git?ref=main"
}
```

Then, configure the workflow to use an SSH key stored in GitHub Secrets.

---

This approach is cleaner and leverages Terraform’s built-in support for GitHub modules, avoiding the need for manual cloning.
