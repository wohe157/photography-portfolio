# 📸 My Photography Portfolio

A minimal, performant photography portfolio site built with:

- **Frontend**: Static website (HTML/CSS/JS) hosted on S3
- **Backend**: Python-based AWS Lambda function returning gallery data from S3
- **Infrastructure**: Managed via Terraform (S3, Lambda, API Gateway, IAM)

---

## 📂 Project Structure

```
.
├── backend/            # Lambda backend code (Python)
├── frontend/           # Static frontend code (HTML/JS)
├── media/              # Local test images (not deployed)
├── infra/              # Terraform infrastructure config
├── scripts/            # Utility scripts (e.g. Lambda bundling)
├── build/              # Temporary build artifacts
└── .github/workflows/  # GitHub Actions automation
```

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/wohe157/photography-portfolio.git
cd photography-portfolio
```

# 🛠 Infrastructure Setup

Infrastructure is defined using Terraform and lives in the infra/ folder.

## ✅ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform)
- AWS credentials configured (via `~/.aws/credentials`, environment variables, or IAM role)

## 🔧 Build the Infrastructure

From the project root:

```bash
cd infra
terraform init
terraform plan   # Review changes
terraform apply  # Deploy infra
```

This creates:

- S3 buckets for the frontend and media
- A Lambda function for the backend
- API Gateway for accessing the backend

> 🔐 You will see output URLs for the deployed site and API after apply.

## 🖼 Media Upload

Media files are stored in the S3 media bucket. Upload them manually using:

- AWS Console
- AWS CLI
- Or a separate script/tool

> 💡 The files in `/media` are not deployed and only used for local testing.

---

# 🌐 Frontend Deployment

Your GitHub Action automatically:

- Injects runtime config (backend & media URLs)
- Uploads built files to the S3 frontend bucket

You can also upload manually via AWS CLI or Console if needed.

---

# 🧠 Backend Deployment

The backend code is deployed as a ZIP to Lambda:

- Uses a minimal Python Lambda function
- Read-only access to the media bucket
- Auto-deployed via GitHub Actions or via scripts/build_lambda.py

To build locally:

```bash
python scripts/build_lambda.py
```

This will:

- Package `backend/app.py`
- Output to `build/deployment-package.zip`

---

# 🧪 Running Locally (Coming Soon)

We’ll support running the site locally using:

- A local Python server for the backend
- Static file server for the frontend
- Local test media

---

# 🧼 Cleaning Up

To destroy all deployed infra:

```bash
cd infra
terraform destroy
```

---

# ✅ Todo

- Add CloudFront + custom domain (with HTTPS)
- Add local dev support
- Optimize images in S3

---

# 📄 License

MIT © Wouter Heyvaert
