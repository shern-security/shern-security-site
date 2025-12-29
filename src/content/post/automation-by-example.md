---
publishDate: 2024-09-14T00:00:00Z
title: 'Automation by Example: Teaching Through Real Code'
excerpt: How I teach security automation through working examples. A real GitHub repository showing Entra ID automation with Terraform, enabling teams to self-service while security maintains control.
image: https://images.unsplash.com/photo-1555949963-aa79dcee981c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80
category: Security Automation
tags:
  - automation
  - entra-id
  - terraform
  - github-actions
  - infrastructure-as-code
  - access-management
metadata:
  canonical: https://shernsecurity.com/automation-by-example
---

## The Problem: Manual Identity Management Doesn't Scale

Every security team faces the same bottleneck:

- **Creating security groups** - 2-3 days per request
- **Assigning app access** - Manual ticket workflow
- **Managing access packages** - Spreadsheet tracking
- **Reviewing permissions** - Quarterly manual audits
- **Onboarding applications** - Weeks of back-and-forth

These tasks consume hundreds of hours while introducing human error and inconsistency.

The traditional response? **Hire more people.** 

The better way? **Automation by example.**

## The Philosophy: Security Gets Out of the Way While Staying in Control

Instead of becoming a bottleneck, security teams should **enable others to move fast securely**. 

The best way to teach automation? **Show them working code they can fork, copy, and adapt.**

### Old Way
- Security team does all the work
- Manual ticket queues
- Weeks of waiting for access
- "Security says no"
- No visibility into pending requests

### New Way (Automation by Example)
- Teams submit Pull Requests
- Automated validation runs
- Security approves or rejects
- Changes auto-deploy on merge
- "Security enables yes"

## Real Example: Entra Automation Repository

This is how I specifically teach automation. I created a **working GitHub repository** that manages Entra ID (Azure AD) through Terraform and GitHub Actions.

The repository enables teams to self-service:
- **Security Groups** - Create and manage group memberships
- **Access Packages** - Automate entitlement management with approval workflows
- **App Registrations** - Enable dev teams to register apps with security oversight
- **Conditional Access Policies** - Enforce security policies as code

**Repository Structure:**
```
entra-automation/
├── README.md                      # Complete documentation
├── ENTRA_RESOURCES.md            # All available resource types
├── WORKFLOW_EXPLANATION.md       # CI/CD pipeline guide
├── presentation.md               # Marp slides for training
├── access_package_solution.tf    # Working example
└── .github/
    └── workflows/
        └── terraform.yml         # Automated pipeline
```

This approach allows security teams to **get out of the way while staying in control** - dev teams move faster through pull requests and automation, while security maintains review and approval gates.

## Teaching Concepts: Terraform + GitHub Actions

The first lesson is understanding the tools:

### What is Terraform?

**Terraform is a configuration language.** It works by:

1. **Define Configuration** - Write what you want (groups, policies, apps)
2. **Run Plan** - Shows exactly what will change
3. **Apply Plan** - Commits changes to the environment
4. **Track State** - Detects drift and shows unexpected changes

**Critical Concept:** A resource should only be changed by Terraform. If you manage a Conditional Access Policy in Terraform, don't change it manually in the portal - Terraform will overwrite manual changes.

### What is GitHub Actions?

GitHub Actions provides the automation pipeline:

1. **Developer** submits Pull Request
2. **Terraform Plan** runs automatically
3. **Security Team** reviews the plan in PR comments
4. **Approval Gate** - designated approvers must approve
5. **Terraform Apply** deploys changes automatically
6. **Audit Trail** - all changes tracked in Git history

## Architecture: How the Pieces Connect

Here's how Entra automation enables self-service with security control:

```
┌─────────────────────────────────────────────────────────────┐
│                    Developer Workflow                        │
└─────────────────────────────────────────────────────────────┘
   1. Fork Repository
   2. Create Branch
   3. Make Changes to .tf files
   4. Commit & Push
   5. Create Pull Request
                    ↓
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Pipeline (Automated)             │
├─────────────────────────────────────────────────────────────┤
│  → Checkout Code                                             │
│  → Terraform Init                                            │
│  → Terraform Validate (syntax check)                         │
│  → Terraform Plan (shows what will change)                   │
│  → Post Plan to PR Comments                                  │
│                                                              │
│  ⏸  APPROVAL GATE (Security Team Reviews Plan)              │
│                                                              │
│  → Terraform Apply (only after approval)                     │
│  → Update Entra ID                                           │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│                  Entra ID (Azure AD)                         │
├─────────────────────────────────────────────────────────────┤
│  • Security Groups Created                                   │
│  • Access Packages Configured                                │
│  • App Registrations Updated                                 │
│  • Conditional Access Policies Enforced                      │
└─────────────────────────────────────────────────────────────┘
```

**Key Benefit:** Developers move fast through PRs. Security maintains control through approval gates.

## Real Example 1: Access Package with App Roles

This is a complete working example from the repository showing how to enable self-service app access.

### The Business Problem

A development team builds an internal application. They need to:
- Let users request access themselves
- Assign different permission levels (Reader, Contributor, Admin)
- Require manager approval
- Automatically expire access after 90 days
- Remove access when employees leave

**Manual Process:** IT team processes tickets, manually assigns access, tracks spreadsheets. Takes 3-5 days per request.

**Automated Solution:** Access Package with Terraform.

### Understanding App Registrations

Before diving into code, understand what an App Registration is:

**App Registration** - How you register an application with Entra ID so it can:
- **Authenticate Users** - Sign in with Entra ID credentials
- **Request Permissions** - Define needed Microsoft Graph API access
- **Receive Tokens** - Get access/ID tokens for authenticated users
- **Define Roles** - Create custom roles (Reader, Contributor, Admin)

**Key Components:**
- **Client ID** - Unique identifier for your application (public)
- **Client Secret** - Credentials proving app identity (like a password)
- **Redirect URIs** - Where Entra ID sends users after authentication
- **App Roles** - Custom roles defined in app manifest, assigned to users/groups

### The Architecture

Here's how Access Packages enable self-service app role assignment:

```
┌──────────────────────────────────────────────────────────────┐
│  App Registration (defines app + roles in manifest)          │
│  • Reader Role                                                │
│  • Contributor Role                                           │
│  • Admin Role                                                 │
└────────────────────┬─────────────────────────────────────────┘
                     │ Groups assigned to specific roles
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼───┐   ┌───▼────┐  ┌───▼────┐
   │ Group  │   │ Group  │  │ Group  │
   │ Reader │   │ Contrib│  │ Admin  │
   └────▲───┘   └───▲────┘  └───▲────┘
        │            │            │
        └────────────┴────────────┘
                     │
                     │ Groups added as resources
        ┌────────────▼─────────────────┐
        │  Access Package               │
        │  • Contains all 3 groups      │
        │  • Requires approval          │
        │  • 90-day expiration          │
        │  • Self-service portal        │
        └───────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │ User requests access via       │
        │ myaccess.microsoft.com         │
        └────────────────────────────────┘
```

**The Flow:**
1. Create App Registration with roles in manifest
2. Create Entra ID Groups (one per role)
3. Assign Groups to App Registration with role mapping
4. Create Access Package containing the groups
5. Users request access via My Access portal
6. Approval required from designated approvers
7. User automatically added to group = gets role
8. Access expires after 90 days, automatically removed

### The Terraform Code

Here's the actual working example from `access_package_solution.tf`:

```hcl
# Configure the Entra ID provider
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

# Get current tenant information
data "azuread_client_config" "current" {}

# Create Security Group for Reader role
resource "azuread_group" "app_readers" {
  display_name     = "App-MyApplication-Readers"
  description      = "Reader access to MyApplication"
  security_enabled = true
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# Create Security Group for Contributor role
resource "azuread_group" "app_contributors" {
  display_name     = "App-MyApplication-Contributors"
  description      = "Contributor access to MyApplication"
  security_enabled = true
}

# Create Security Group for Admin role
resource "azuread_group" "app_admins" {
  display_name     = "App-MyApplication-Admins"
  description      = "Admin access to MyApplication"
  security_enabled = true
}

# Reference existing App Registration
# (App Registration created separately with app roles defined in manifest)
data "azuread_application" "my_app" {
  display_name = "MyApplication"
}

data "azuread_service_principal" "my_app" {
  application_id = data.azuread_application.my_app.application_id
}

# Assign Reader Group to App Registration with Reader role
resource "azuread_app_role_assignment" "readers" {
  principal_object_id = azuread_group.app_readers.object_id
  resource_object_id  = data.azuread_service_principal.my_app.object_id
  app_role_id         = "00000000-0000-0000-0000-000000000001"  # Reader role ID
}

# Assign Contributor Group to App Registration
resource "azuread_app_role_assignment" "contributors" {
  principal_object_id = azuread_group.app_contributors.object_id
  resource_object_id  = data.azuread_service_principal.my_app.object_id
  app_role_id         = "00000000-0000-0000-0000-000000000002"  # Contributor role ID
}

# Assign Admin Group to App Registration
resource "azuread_app_role_assignment" "admins" {
  principal_object_id = azuread_group.app_admins.object_id
  resource_object_id  = data.azuread_service_principal.my_app.object_id
  app_role_id         = "00000000-0000-0000-0000-000000000003"  # Admin role ID
}

# Create Access Package Catalog
resource "azuread_access_package_catalog" "app_catalog" {
  display_name = "MyApplication Access"
  description  = "Catalog for MyApplication access packages"
}

# Add groups to catalog as resources
resource "azuread_access_package_resource_catalog_association" "reader_group" {
  catalog_id             = azuread_access_package_catalog.app_catalog.id
  resource_origin_id     = azuread_group.app_readers.object_id
  resource_origin_system = "AadGroup"
}

resource "azuread_access_package_resource_catalog_association" "contributor_group" {
  catalog_id             = azuread_access_package_catalog.app_catalog.id
  resource_origin_id     = azuread_group.app_contributors.object_id
  resource_origin_system = "AadGroup"
}

resource "azuread_access_package_resource_catalog_association" "admin_group" {
  catalog_id             = azuread_access_package_catalog.app_catalog.id
  resource_origin_id     = azuread_group.app_admins.object_id
  resource_origin_system = "AadGroup"
}

# Create Access Package
resource "azuread_access_package" "my_app" {
  catalog_id   = azuread_access_package_catalog.app_catalog.id
  display_name = "MyApplication Access"
  description  = "Request access to MyApplication with appropriate role"
}

# Configure Assignment Policy (approval, duration, etc.)
resource "azuread_access_package_assignment_policy" "my_app_policy" {
  access_package_id = azuread_access_package.my_app.id
  display_name      = "MyApplication Standard Access Policy"
  description       = "Policy for requesting MyApplication access"
  duration_in_days  = 90
  
  # Who can request
  requestor_settings {
    scope_type = "AllExistingDirectoryMemberUsers"
  }
  
  # Approval settings
  approval_settings {
    approval_required = true
    
    approval_stage {
      approval_stage_time_out_in_days = 14
      
      primary_approver {
        object_id    = "manager-group-id"  # Manager approval
        subject_type = "groupMembers"
      }
    }
  }
  
  # Assignment review (periodic recertification)
  assignment_review_settings {
    enabled                        = true
    review_frequency               = "quarterly"
    duration_in_days               = 7
    review_type                    = "Self"
    access_review_timeout_behavior = "keepAccess"
  }
}
```

**What This Enables:**
- ✅ Users self-service request access via portal
- ✅ Manager approval required automatically
- ✅ Access expires after 90 days
- ✅ Quarterly recertification reviews
- ✅ Group membership = app role (automatic)
- ✅ All changes tracked in Git
- ✅ Full audit trail

### Making Changes via Pull Request

When a developer needs to add a new app or modify access:

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourorg/entra-automation.git
   cd entra-automation
   ```

2. **Create branch**
   ```bash
   git checkout -b add-new-app
   ```

3. **Make changes** - Copy `access_package_solution.tf`, modify for new app

4. **Commit and push**
   ```bash
   git commit -m "Add access package for FinanceApp"
   git push origin add-new-app
   ```

5. **Create Pull Request** - GitHub Actions automatically runs `terraform plan`

6. **Security reviews plan** - PR comments show exactly what will change

7. **Approval** - Designated approver clicks "Approve"

8. **Auto-deploy** - Terraform apply runs automatically, creates everything

**Time:** 15 minutes vs. 3-5 days manual process.

## Real Example 2: Conditional Access Policy as Code

Another powerful example: managing Conditional Access Policies through Terraform.

### The Challenge

Conditional Access Policies control:
- Who can access what applications
- From which locations/devices
- With which authentication requirements (MFA, compliant device, etc.)

**Manual Process:** Created in Azure Portal, easy to misconfigure, no version history, hard to replicate across environments.

### Terraform Solution

```hcl
# Conditional Access Policy: Require MFA for admins
resource "azuread_conditional_access_policy" "require_mfa_admins" {
  display_name = "Require MFA for Administrator Roles"
  state        = "enabled"
  
  conditions {
    # Target admin roles
    users {
      included_roles = [
        "Global Administrator",
        "Security Administrator",
        "Privileged Authentication Administrator"
      ]
    }
    
    # All cloud apps
    applications {
      included_applications = ["All"]
    }
    
    # All locations
    locations {
      included_locations = ["All"]
    }
  }
  
  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa"]  # Require MFA
  }
  
  session_controls {
    sign_in_frequency = 12  # Re-auth every 12 hours
    sign_in_frequency_period = "hours"
  }
}

# Conditional Access Policy: Block legacy authentication
resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "Block Legacy Authentication"
  state        = "enabled"
  
  conditions {
    users {
      included_users = ["All"]
      excluded_groups = ["Legacy-Auth-Exceptions"]  # Break-glass
    }
    
    applications {
      included_applications = ["All"]
    }
    
    # Target legacy auth clients
    client_app_types = [
      "exchangeActiveSync",
      "other"  # Legacy protocols
    ]
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]  # Block access
  }
}

# Conditional Access Policy: Require compliant device for Intune
resource "azuread_conditional_access_policy" "require_compliant_device" {
  display_name = "Require Compliant Device for Sensitive Apps"
  state        = "enabledForReportingButNotEnforced"  # Start in report-only
  
  conditions {
    users {
      included_users = ["All"]
    }
    
    applications {
      # Specific sensitive applications
      included_applications = [
        "00000003-0000-0000-c000-000000000000",  # Microsoft Graph
        "00000002-0000-0ff1-ce00-000000000000"   # Office 365 Exchange Online
      ]
    }
    
    platforms {
      included_platforms = ["android", "iOS", "windows", "macOS"]
    }
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = [
      "compliantDevice",        # Device is compliant
      "domainJoinedDevice"      # Or domain joined
    ]
  }
}
```

**Benefits:**
- ✅ Policies defined as code
- ✅ Version controlled in Git
- ✅ Peer reviewed via Pull Requests
- ✅ Consistent across environments (dev/prod)
- ✅ Can start in "report-only" mode
- ✅ Easy rollback if issues arise

### Testing in Report-Only Mode

Notice the `enabledForReportingButNotEnforced` state. This is powerful:

1. Deploy policy in report-only mode
2. Monitor Sign-In Logs for 2 weeks
3. See what would have been blocked
4. Adjust policy if needed
5. Switch to `enabled` when confident

**This is impossible with manual portal configuration!**

## The GitHub Actions Pipeline

Here's the actual CI/CD workflow that makes this all work:

```yaml
# .github/workflows/terraform.yml
name: Entra Automation Pipeline

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
  release:
    types: [created]

env:
  ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

jobs:
  terraform-plan:
    name: Terraform Plan (Dev)
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform
      
      - name: Terraform Validate
        run: terraform validate
        working-directory: ./terraform
      
      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -out=tfplan -no-color
        working-directory: ./terraform
        continue-on-error: true
      
      - name: Post Plan to PR
        uses: actions/github-script@v6
        with:
          script: |
            const output = `#### Terraform Plan 📋
            
            **Terraform initialization:** ✅
            **Terraform validation:** ✅
            
            <details><summary>Show Plan</summary>
            
            \`\`\`
            ${{ steps.plan.outputs.stdout }}
            \`\`\`
            
            </details>
            
            **Pusher:** @${{ github.actor }}
            **Action:** ${{ github.event_name }}`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

  terraform-apply-dev:
    name: Terraform Apply (Dev)
    runs-on: ubuntu-latest
    needs: [terraform-plan]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment:
      name: dev
      url: https://portal.azure.com
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform
      
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./terraform
        env:
          TF_VAR_environment: dev

  terraform-apply-prod:
    name: Terraform Apply (Production)
    runs-on: ubuntu-latest
    if: github.event_name == 'release'
    environment:
      name: production
      url: https://portal.azure.com
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform
      
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./terraform
        env:
          TF_VAR_environment: prod
```

**What This Pipeline Does:**

1. **Pull Request** triggers `terraform-plan`
   - Validates syntax
   - Generates plan showing changes
   - Posts plan as PR comment
   - Security team reviews

2. **Merge to main** triggers `terraform-apply-dev`
   - Requires approval from Dev environment approvers
   - Applies changes to Dev Entra ID

3. **Create Release** triggers `terraform-apply-prod`
   - Requires approval from Prod environment approvers
   - Applies changes to Production Entra ID

**Approval Gates Configured in GitHub:**
- Navigate to Repository → Settings → Environments
- Create "dev" environment with Dev approvers
- Create "production" environment with Security team approvers
- Require approvals before deployment

This creates **audit trail** and **separation of duties**.

## How to Teach This: The Fork/Rebase Workflow

The teaching methodology is simple: **provide working examples and documentation**.

### Repository Documentation Structure

```
entra-automation/
├── README.md                   # Quick start guide
├── ENTRA_RESOURCES.md         # All available Terraform resources
├── WORKFLOW_EXPLANATION.md    # Detailed CI/CD explanation
├── presentation.md            # Marp slides for training sessions
├── examples/
│   ├── access_package_solution.tf
│   ├── conditional_access_policy.tf
│   ├── security_group.tf
│   └── app_registration.tf
└── .github/workflows/
    └── terraform.yml
```

### Step 1: Provide Complete Documentation

**README.md** includes:
- What the repository does
- Why automation matters
- How Terraform + GitHub Actions work
- Step-by-step contribution guide
- FAQ and troubleshooting

**ENTRA_RESOURCES.md** catalogs all available resources:
```markdown
## Available Entra ID Resources

### Identity
- `azuread_user` - Create and manage users
- `azuread_group` - Create security/Microsoft 365 groups
- `azuread_group_member` - Manage group memberships

### Applications
- `azuread_application` - Register applications
- `azuread_service_principal` - Create service principals
- `azuread_application_password` - Manage app secrets

### Access Management
- `azuread_access_package` - Entitlement management
- `azuread_access_package_catalog` - Organize access packages
- `azuread_conditional_access_policy` - Security policies

### Administrative
- `azuread_administrative_unit` - Scope administration
- `azuread_directory_role` - Built-in roles
- `azuread_custom_directory_role` - Custom roles
```

**WORKFLOW_EXPLANATION.md** details the pipeline:
- How Pull Requests trigger plans
- Where approval gates exist
- How to interpret Terraform output
- What to do if something fails

### Step 2: Create Marp Presentation

Use **presentation.md** with [Marp](https://marp.app/) to generate slides:

```markdown
---
marp: true
theme: default
---

# Entra Automation
## Teaching Teams to Self-Service Identity Management

---

## The Problem

- 100+ access requests per week
- 2-3 days average resolution time
- Manual errors and inconsistency
- No audit trail
- Security team is bottleneck

---

## The Solution

- Self-service via Pull Requests
- Automated validation
- Security approval gates
- Full Git history
- 15 minutes from request to deployment

---

## Demo: Submitting Your First PR

1. Fork repository
2. Copy example template
3. Modify for your needs
4. Submit Pull Request
5. Review automated plan
6. Get approval
7. Auto-deploys!

---
```

Convert to slides: `marp presentation.md -o slides.pdf`

### Step 3: Hold Training Sessions

**1-Hour Workshop Agenda:**
- **10 min** - Why automation matters (pain points)
- **15 min** - Terraform + GitHub Actions concepts
- **20 min** - Live demo of creating Access Package
- **10 min** - Q&A and troubleshooting
- **5 min** - Next steps and resources

**Key Teaching Points:**
- Don't try to teach all Terraform
- Focus on "copy, modify, submit PR"
- Show the approval gate (security stays in control)
- Emphasize Git history as documentation
- Make it safe to experiment

### Step 4: Provide Working Examples

Teams learn by modifying working code. Provide templates:

```hcl
# examples/access_package_template.tf
# 
# INSTRUCTIONS:
# 1. Copy this file to main directory
# 2. Replace "MyApplication" with your app name
# 3. Update approvers with your manager group
# 4. Submit Pull Request
# 5. Review the plan in PR comments
# 6. Get approval and merge

resource "azuread_group" "readers" {
  display_name     = "App-MyApplication-Readers"  # CHANGE THIS
  description      = "Reader access to MyApplication"  # CHANGE THIS
  security_enabled = true
}

# ... rest of template with clear comments
```

### Step 5: Celebrate Early Adopters

When a team successfully self-services:
1. Share in team meetings
2. Write internal blog post
3. Invite them to train others
4. Track metrics (time saved, requests automated)

**Metrics to Track:**
- Average time from request to deployment (before/after)
- Number of self-service requests vs. manual tickets
- Error rate (manual mistakes vs. automated validation)
- Security team hours saved per week

## Real Results: 80% Reduction in Operational Work

In my role as Lead Product Manager at Cargill, we coached a team to embrace this automation-by-example approach.

**Before Automation:**
- 100+ access requests per week
- 2-3 days average resolution time
- 40 hours/week of manual work
- Frequent configuration errors
- No audit trail
- Security team = bottleneck

**After Automation:**
- Self-service via Pull Requests
- 15 minutes average resolution time
- 8 hours/week of review work (80% reduction!)
- Zero configuration errors (Terraform validation)
- Complete Git history audit trail
- Security team = enabler

**The Key:** We didn't just automate our work. We taught teams to automate themselves using real working examples they could copy and adapt.

## Additional Learning Resources

The repository includes references to industry best practices:

**Conditional Access Baselines:**
- [CA Baseline 2024](https://github.com/kennethvs/cabaseline202404) - Kenneth van Surksum's recommended baseline policies
- [CA Baseline 2022](https://github.com/kennethvs/cabaseline202212) - Previous baseline for reference
- [Conditional Access Demystified Whitepaper](https://www.vansurksum.com/2022/12/15/december-2022-update-of-the-conditional-access-demystified-whitepaper-and-workflow-cheat-sheet/) - Comprehensive CA guide
- [Modern Workplace Blog](https://www.vansurksum.com/) - Ongoing CA best practices

**Conversion Tools:**
- [CA-Terraform-json Converter](https://github.com/uniQuk/CA-Terraform-json/tree/main) - Convert JSON CA policies exported from Azure Portal to Terraform

These resources help teams understand not just **how** to automate, but **what** security policies to implement.

## The Infrastructure as Code Mindset

Everything in Entra ID should be code:
- **Security Groups** → Terraform
- **Access Packages** → Terraform
- **App Registrations** → Terraform
- **Conditional Access Policies** → Terraform
- **Administrative Roles** → Terraform

**Benefits:**
- ✅ **Version Control** - Git tracks every change with who/when/why
- ✅ **Peer Review** - Pull Requests require approval before merge
- ✅ **Testing** - CI/CD validates syntax and plan before apply
- ✅ **Rollback** - `git revert` undoes changes instantly
- ✅ **Documentation** - Code IS documentation
- ✅ **Consistency** - Same config across dev/prod
- ✅ **Drift Detection** - Terraform detects manual changes

### State Management

Terraform tracks infrastructure state in a state file stored in Azure Storage:

**Why Remote State?**
- Multiple team members can collaborate
- State is locked during operations (prevents conflicts)
- Encrypted at rest in Azure
- Versioned for rollback capability

**Setup:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "Security-Automation-rg"
    storage_account_name = "entgsecarchtfstate34234"
    container_name       = "terraformstate"
    key                  = "entra.tfstate"
  }
}
```

**State File Contains:**
- Current state of all managed resources
- Resource dependencies
- Provider configuration
- Outputs (for use in other systems)

**Important:** Never edit state file manually. Use `terraform state` commands if needed.

## Common Pitfalls to Avoid

### ❌ Mixing Manual and Automated Changes
**Problem:** Team creates access package via Terraform, then someone edits it in Azure Portal.
**Result:** Next Terraform run overwrites portal changes.
**Solution:** Choose one source of truth. If it's in Terraform, only change it in Terraform.

### ❌ Not Testing in Dev First
**Problem:** Submit PR that goes straight to production.
**Result:** Breaks production authentication.
**Solution:** Always have dev/prod environments. Test in dev first.

### ❌ Ignoring Plan Output
**Problem:** Team approves PR without reading Terraform plan.
**Result:** Accidentally deletes critical security group.
**Solution:** Make plan review mandatory. Require at least 2 approvers.

### ❌ No Rollback Plan
**Problem:** Deploy breaks production, no way to quickly undo.
**Result:** Extended outage while manually fixing.
**Solution:** Tag every production deployment. Can immediately `git revert` and redeploy.

### ❌ Hardcoding Secrets
**Problem:** Put client secrets directly in .tf files.
**Result:** Secrets committed to Git history forever.
**Solution:** Use GitHub Secrets, Azure Key Vault, or environment variables.

### ❌ Too Much Too Fast
**Problem:** Try to automate everything at once.
**Result:** Overwhelming, teams resist.
**Solution:** Start with one pain point. Success breeds adoption.

## The Bottom Line

**Automation by example isn't about replacing people.** It's about freeing them from soul-crushing manual work so they can focus on what matters: **strategy, innovation, and enabling the business.**

### What Makes This Approach Successful

1. **Real Working Code** - Not theory, actual examples teams can fork and use
2. **Documentation First** - README, guides, presentations all included
3. **Security Stays in Control** - Approval gates at every stage
4. **Self-Service Empowerment** - Teams move fast without tickets
5. **Git as Audit Trail** - Every change tracked with who/when/why
6. **Start Small, Scale Up** - One use case, prove value, expand

### The Teaching Method

1. **Provide Repository** - Working examples with clear documentation
2. **Hold Training** - 1-hour workshop with live demo
3. **Support First Users** - Help early adopters succeed
4. **Celebrate Wins** - Share success stories widely
5. **Iterate** - Improve based on feedback

### Results

By teaching teams to automate their own work through real, working examples:
- ✅ Security scales without hiring
- ✅ Teams move faster (days → minutes)
- ✅ Errors decrease (manual → validated)
- ✅ Job satisfaction increases (meaningful work)
- ✅ Security becomes an enabler, not a blocker

### Getting Started

Want to implement this approach?

1. **Pick One Pain Point** - What takes longest? Start there.
2. **Create Working Example** - Build one complete automation
3. **Document Heavily** - README + workflow guide + examples
4. **Train One Team** - Prove the concept
5. **Measure Results** - Time saved, errors reduced, satisfaction
6. **Expand** - More use cases, more teams

**The Repository Structure:**
```bash
git init security-automation
cd security-automation

# Create documentation
touch README.md WORKFLOW_EXPLANATION.md
mkdir examples/

# Add working example
cat > examples/access_package.tf << 'EOF'
# Complete working example here
EOF

# Create CI/CD pipeline
mkdir -p .github/workflows
cat > .github/workflows/terraform.yml << 'EOF'
# Pipeline with approval gates
EOF

# Commit and share
git add .
git commit -m "Initial automation by example repository"
```

Start with one painful task. Automate it. Document it. Teach someone else. Repeat.

That's how you transform a security team from a bottleneck to an enabler.

---

*Want to see more automation examples? Check out my [IP Scanner platform](/ip-scanner-platform) or [reach out](/contact) to discuss automation strategies for your organization.*
