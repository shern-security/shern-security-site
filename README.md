# Shern Security

Professional portfolio and blog site showcasing cybersecurity expertise, automation, and the Access Granted platform.

Built with [Astro 5](https://astro.build/) and the [AstroWind](https://astrowind.vercel.app/) theme, deployed to AWS S3 via Terraform and GitHub Actions.

## Site Structure

### Pages
- **Home** - "A Beacon of Light in Cybersecurity" featuring Split Rock Lighthouse imagery
- **Resume** - Complete professional experience (15+ years in cybersecurity)
- **Articles** - Technical blog posts on security automation and infrastructure
- **Access Granted** - Information about the self-service security platform
- **About** - Career highlights and professional background

### Blog Posts
- Welcome to Shern Security
- Introducing Access Granted
- IP Scanner Platform (Technical Deep Dive)
- Security Architecture Matters
- Automation by Example

## Local Development

### Prerequisites
- Node.js 18+ and npm
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/shern-sec-site.git
cd shern-sec-site

# Install dependencies
npm install

# Start development server
npm run dev
```

Visit [http://localhost:4321/](http://localhost:4321/)

### Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment instructions including:

- AWS Account setup and IAM permissions
- Terraform infrastructure configuration
- GitHub Actions CI/CD setup
- Step-by-step deployment guide

### Quick Deploy

1. **Configure AWS Infrastructure**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your bucket name
   terraform init
   terraform apply
   ```

2. **Push to GitHub**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/shern-sec-site.git
   git push -u origin main
   ```

3. **Configure GitHub Secrets**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `S3_BUCKET_NAME`

4. **Deploy automatically** on every push to `main`

## Content Management

### Adding Blog Posts

Create a new markdown file in `src/content/post/`:

```markdown
---
publishDate: 2025-01-15T00:00:00Z
title: 'Your Article Title'
excerpt: 'Brief description'
image: 'https://images.unsplash.com/photo-...'
category: 'Security'
tags:
  - security
  - automation
---

Your content here...
```

### Theme Customization

- **Site Config**: [src/config.yaml](src/config.yaml)
- **Navigation**: [src/navigation.ts](src/navigation.ts)
- **Logo**: [src/components/Logo.astro](src/components/Logo.astro)
- **Pages**: [src/pages/](src/pages/)

## Technology Stack

- **Framework**: Astro 5 (Static Site Generator)
- **Theme**: AstroWind
- **Styling**: TailwindCSS
- **Infrastructure**: Terraform (AWS S3 + CloudFront)
- **CI/CD**: GitHub Actions
- **Content**: Markdown/MDX

## Features

- Responsive design with light/dark mode
- SEO-optimized with meta tags and OG images
- Auto-generated RSS feed
- Blog with tagging and categories
- Fast performance (static site)
- Automated deployments
- Infrastructure as Code
- Cost-effective hosting (~$0.03/month)

## License

MIT © 2025 Shern Security

## Credits

Built with [AstroWind](https://github.com/onwidget/astrowind) theme by [onWidget](https://github.com/onwidget)
