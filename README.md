# Lambda PDF Converter

[![Lambda PDF Converter Tutorial](https://img.youtube.com/vi/1siwCee9lpw/maxresdefault.jpg)](https://youtu.be/1siwCee9lpw "Watch the Tutorial")

Transform PDF files into high-quality JPEG images with this AWS Lambda function. Designed for seamless integration with automation tools like n8n, this solution delivers converted images as a convenient ZIP archive at a fraction of the cost of commercial API services.

## 🌟 Ready-to-Use n8n Workflow

We've created a production-ready n8n workflow that demonstrates how to integrate this Lambda function with other services to create powerful automation pipelines.

[Download the n8n Workflow](https://gettingautomated.com/i-saved-thousands-on-apis-with-this-n8n-aws-workflow/)

### What This Workflow Does

This workflow shows the complete integration path from PDF source to AI image analysis:

1. **Extract PDFs from Google Drive**
2. **Convert to JPEGs using the Lambda function**
3. **Unzip the resulting files**
4. **Send the images to OpenAI for interpretation**

Perfect for document processing, content extraction, or automated image analysis pipelines!

```mermaid
graph TD
    A[Google Drive] -->|Download PDF| B[Extract Content]
    B -->|PDF Binary| C[PDF to JPEG Lambda]
    C -->|ZIP File| D[Unzip & Extract Files]
    D -->|Multiple JPEGs| E[Base64 Encode Images]
    E -->|Aggregated Images| F[Build OpenAI Request]
    F -->|Multiple Images| G[OpenAI Vision API]
    
    style A fill:#ff52b9,stroke:#333,stroke-width:2px
    style C fill:#3985ff,stroke:#333,stroke-width:2px
    style G fill:#137f13,stroke:#333,stroke-width:2px
```

### Key Components

- **PDF Source**: Reads PDF files directly from Google Drive
- **Lambda Integration**: Seamlessly calls the AWS Lambda function
- **ZIP Processing**: Extracts individual JPEGs from the ZIP archive
- **OpenAI Integration**: Prepares and sends images to OpenAI's Vision API
- **Multi-Image Support**: Handles multi-page PDFs automatically

### Using the Ready-Made Workflow

We've done the hard work for you! The provided workflow is ready to import and use immediately:

1. **Download the Workflow**: Get the JSON file from the link above
2. **Import into n8n**: 
   - Open your n8n instance
   - Go to "Workflows" → "Import from File" or "Import from URL"
   - Select the downloaded JSON file or paste the URL
   - Click "Import"

That's it! The workflow is now in your n8n instance with all nodes already configured and connected.

#### Customization (Optional)

If you need to connect to your own services:

- For Google Drive: Update the credentials in the Google Drive node
- For AWS Lambda: Update the credentials and function ARN in the AWS Lambda node
- For OpenAI: Add your API key to the OpenAI credentials

All nodes include detailed descriptions and instructions in their configurations to help you understand and customize as needed.

## ✨ Features

- Converts PDF files to JPEG images with adjustable quality
- Accepts either direct PDF uploads or URLs to PDF files
- Returns all images as a single ZIP file
- Handles multi-page PDFs efficiently
- Proper error handling and logging
- Docker-based deployment for simplicity and consistency

## 🎯 Why Use This?

- **Ultra Cost-Effective**: ~$0.42/month for 10,000 conversions vs $100-1,000 with SaaS APIs
- **Complete Control**: Customize conversion parameters exactly to your needs
- **Serverless Architecture**: No servers to manage, maintain, or monitor
- **Seamless Integration**: Works with n8n, websites, apps, or any system that can make HTTP requests
- **Scale Automatically**: Handles thousands of simultaneous conversions without configuration
- **Privacy Focused**: Your documents never leave your AWS account
- **Deployment Flexibility**: Choose between Docker-based approach or Lambda Layers
- **Maximum Reusability**: Unlike embedded n8n-only solutions, this modular approach can be used with any system that can make HTTP requests

## 💰 Cost Breakdown

- **AWS Lambda Costs**:
  - Free Tier: 1 million free requests + 400,000 GB-seconds/month
  - Beyond Free Tier: $0.20 per million requests + $0.0000166667 per GB-second
  
- **Real-World Example** (10,000 PDFs/month with 512MB Lambda):
  - Request cost: 10,000 × $0.20/million = $0.002
  - Compute cost: 10,000 × 5 seconds × 0.5GB × $0.0000166667/GB-second = $0.42
  - **Total: $0.42 per month**

- **Compared to Commercial Services**:
  - SaaS PDF conversion APIs: $10-100/month for similar volume
  - Pay-per-conversion APIs: $0.01-0.10 per conversion ($100-1,000 for 10,000 files)
  - Many services impose rate limits or queue processing at lower tiers

### Detailed Cost Comparison

It's clear that AWS Lambda stands out as the most cost-effective option for PDF-to-JPEG conversions. The table below compares our Lambda solution with popular commercial alternatives:

| Service | Lowest Plan / Cost | Monthly Allotment (Approx) | Approx Cost for 1,000 Pages | Derived Cost per Page |
|:--------|:-------------------|:----------------------------|:----------------------------|:----------------------|
| **AWS Lambda** | Pay-per-use after free tier | N/A (pay for compute + requests) | ~$0.0213 for 1,000 pages¹ | ~$0.000021/page |
| **Zamzar** | $9/mo (Developer) | ~3,000 conversions/month | $9 for up to 3,000 pages² | $0.003/page |
| **CloudConvert** | $9/mo (1,000 conversion mins) | ~1,000 pages (if ~1 min per page) | $9 | $0.009/page |
| **DocConversionAPI** | $9.99/mo (Basic) | 1,000 conversions/month | $9.99 | $0.00999/page |
| **ConvertAPI** | $9/mo (Basic: 1,500 sec) | ~1,500 pages (if ~1 sec per page) | $9 | $0.006/page |
| **PDF.co** | $39/mo | ~2,000 credits | $39 (covers ~1,000 pages) | ~$0.02/page |
| **Aspose Cloud** | $29/mo (Basic) | ~3,000 API calls/month | $29 | $0.029/page |
| **Adobe PDF Tools** | Pay-as-you-go (~$0.05/transaction) | N/A | ~$50 for 1,000 pages | $0.05/page |
| **PDFTron** | Custom/Contact Sales | N/A | Varies, enterprise-focused | N/A |

¹ Based on 1 GB memory, ~1.266 seconds billed duration per invocation. Excludes the Lambda free tier, which can significantly reduce or eliminate costs for moderate usage.  
² 100 conversions/day = ~3,000 conversions/month.

Real-world costs may vary (e.g., file sizes, concurrency, how each service measures usage). Nonetheless, **if you're willing to package PDF conversion tools (poppler, ImageMagick, etc.) into a Lambda function, AWS is strikingly affordable compared to most specialized SaaS solutions.**

## 🏗️ Architecture

### System Flow

```mermaid
graph TD
    A[PDF Source] -->|Upload or URL| B[AWS Lambda Function]
    B -->|Process| C[Convert PDF to JPEGs]
    C -->|Package| D[Create ZIP Archive]
    D -->|Return| E[Base64-encoded ZIP]
    
    subgraph n8n["n8n Integration"]
        F[Read Binary File] -->|PDF| G[Encode to Base64]
        H[URL to PDF] -->|Specify URL| I[Create Request]
        G -->|Invoke| B
        I -->|Invoke| B
        E -->|Decode| J[Process Response]
        J -->|Save| K[ZIP File with Images]
    end
    
    style A fill:#ff52b9,stroke:#333,stroke-width:2px
    style B fill:#3985ff,stroke:#333,stroke-width:2px
    style E fill:#137f13,stroke:#333,stroke-width:2px
    style n8n fill:#2A2A2A,stroke:#666,color:#fff
    linkStyle default stroke:#666,stroke-width:2px
```

### AWS Services

- **AWS Lambda**: 
  - Runs containerized PDF conversion function
  - Scales automatically with demand
  - Pay-per-use pricing model

- **Amazon ECR**: 
  - Stores Docker container image
  - Manages container versions
  - Integrates with Lambda service

- **IAM**: 
  - Secure execution role for Lambda
  - Least-privilege permission model
  - Integration with external services

## 🔄 AWS Lambda for Non-AWS Users

If you've used automation tools like n8n but aren't familiar with AWS Lambda, here's what you need to know:

### What is AWS Lambda?

AWS Lambda is a "serverless" computing service that lets you run code without managing servers. Think of it like a specialized function in n8n, but instead of running within the n8n workflow, it runs in the cloud (AWS).

**In simple terms:**
- You upload your code (like our PDF converter function)
- AWS runs that code when it's triggered (by an API call, a file upload, etc.)
- You only pay for the computing time you actually use

**Compared to SaaS API services:**
- With commercial PDF conversion APIs, you pay for a subscription or per-conversion fee
- With Lambda + n8n, you run your own conversion service in AWS at a fraction of the cost
- You maintain control over the process while still keeping it serverless and scalable
- You can customize the conversion parameters exactly to your needs

### Docker-based Lambda Functions (Our Approach)

This project uses a Docker-based approach for AWS Lambda, which offers several advantages:

**What is a Docker-based Lambda?**
- Instead of uploading code files directly, we package our function in a Docker container
- This container includes all necessary dependencies, including poppler for PDF conversion
- AWS runs this container when the Lambda function is invoked

**Advantages of the Docker approach:**
- **Simplified Dependencies**: No need to create separate Lambda Layers - everything is in one container
- **Consistent Environment**: The exact same environment runs locally and in AWS
- **Easier Debugging**: You can test the container locally before deploying
- **No Library Path Issues**: Avoids common problems with shared libraries often encountered with Lambda Layers
- **Larger Size Limit**: Docker images can be up to 10GB, compared to 250MB for regular Lambda deployments

**How it works:**
1. We create a Dockerfile that includes Python, poppler utilities, and our code
2. The build script builds this Docker image and pushes it to Amazon ECR (container registry)
3. Our Lambda function runs this container image when invoked

## 🚀 Getting Started

### Function Variants

This project provides two variants of the PDF-to-JPG converter function:

#### 1. Standard Version (`pdf-to-jpg-converter`)

- Returns all converted images in a single ZIP file
- Ideal for handling multi-page PDFs where you want to keep all pages together
- Requires additional processing in n8n to unzip the contents

#### 2. Unzipped Version (`pdf-to-jpg-converter-unzipped`)

- Returns individual JPG images directly in the response (no ZIP file)
- Each image is returned as a base64-encoded string with its filename and content type
- Simplifies processing in n8n as no unzipping is required
- Ideal when you need to process each page individually

### Deploying the Functions

#### Standard Version (ZIP output)
```bash
# Make the deployment script executable
chmod +x build_and_deploy.sh

# Run the deployment script
./build_and_deploy.sh
```

#### Unzipped Version (Individual JPGs)
```bash
# Make the deployment script executable
chmod +x build_and_deploy_unzipped.sh

# Run the deployment script
./build_and_deploy_unzipped.sh
```

### n8n Integration

#### For the Standard Version (ZIP output)
```javascript
/**
 * Make sure you have installed `jszip` in your n8n environment!
 * For example, in your Dockerfile or on your server:
 *    npm install jszip
 */

const JSZip = require('jszip');

// 1) Get the base64-encoded string of the ZIP data.
const base64Data = $input.first().json.result.body;
const binaryData = Buffer.from(base64Data, 'base64');

// 2) Load the ZIP content using jszip
const zip = new JSZip();
return zip.loadAsync(binaryData)
  .then(async (contents) => {
    const items = [];

    // 3) Loop over each file in the ZIP
    for (const fileName of Object.keys(contents.files)) {
      const file = contents.files[fileName];

      // If it's not a directory, read the file contents
      if (!file.dir) {
        const fileBuffer = await file.async('nodebuffer');

        // 4) Return each unzipped file as a *separate* n8n item
        items.push({
          json: {
            fileName
          },
          binary: {
            // Use a property name like "data" or anything you want
            data: {
              data: fileBuffer.toString('base64'),
              mimeType: 'application/jpeg', // or something more specific if you know
              fileName
            }
          }
        });
      }
    }

    // Return an array of items, each with a single unzipped file
    return items;
  });
```

#### For the Unzipped Version (Individual JPGs)
```javascript
// 1) Get the input data from the Lambda response
const lambdaResponse = $input.first().json.result;

// 2) Parse the body if it's a string, or use it directly if it's already an object
let responseBody;
try {
  responseBody = typeof lambdaResponse.body === 'string' 
    ? JSON.parse(lambdaResponse.body) 
    : lambdaResponse.body;
} catch (error) {
  throw new Error(`Failed to parse Lambda response body: ${error.message}`);
}

// 3) Convert each image into an n8n item
return responseBody.images.map(image => ({
  json: {
    fileName: image.filename,
    totalPages: responseBody.total_pages
  },
  binary: {
    data: {
      data: image.content,
      mimeType: image.content_type,
      fileName: image.filename
    }
  }
}));
```

### Prerequisites

- AWS Account
- AWS CLI configured
- Docker installed and running
- Python 3.12+ installed
- Basic knowledge of AWS Lambda
- n8n workflow automation tool (optional)

### Quick Deployment

For a fully automated deployment to AWS Lambda, use the provided deployment script:

```bash
# Make the deployment script executable
chmod +x build_and_deploy.sh

# Run the deployment script
./build_and_deploy.sh
```

This script will:
1. Check if a Lambda execution role exists and create one if needed
2. Create an ECR repository for the Docker image if it doesn't exist
3. Build and tag the Docker image with all dependencies included
4. Push the Docker image to Amazon ECR
5. Create or update the Lambda function to use this Docker image
6. Configure proper memory, timeout, and other settings

By default, it creates a Lambda function named `pdf-to-jpg-converter` in the `us-east-1` region. You can edit the script variables to customize these settings.

### Testing Locally

You can test the Docker container locally before deploying:

```bash
# Build the Docker image
docker build -t pdf-converter .

# Run the container with a test PDF
docker run -p 9000:8080 pdf-converter
```

In another terminal:
```bash
# Invoke the local function with a test event
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"pdf_url":"https://example.com/document.pdf"}'
```

## 🔌 Integrating with n8n

> **A Note on External Dependencies:** This approach does create an external dependency on AWS, which some users might prefer to avoid by handling everything within n8n for simplicity. It's entirely possible to perform PDF conversion directly in n8n by adding custom packages to JavaScript Code nodes. However, we believe the Lambda-based approach offers greater flexibility and long-term benefits. Your conversion function becomes a standalone service that can be called from n8n, other automation tools, web applications, or any system that can make HTTP requests - not just locked inside your n8n workflows. Both approaches have merit depending on your specific needs and preferences.

### Setting Up Least Privilege AWS Credentials

For security best practices, create an IAM user with only the minimum permissions needed:

1. **Create a new IAM Policy:**
   - Go to AWS IAM Console → Policies → Create Policy
   - Choose JSON and paste the following:
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "lambda:InvokeFunction",
               "Resource": "arn:aws:lambda:*:*:function:pdf-to-jpg-converter"
           }
       ]
   }
   ```
   - Replace `pdf-to-jpg-converter` with your function name
   - Name the policy something like `n8n-pdf-converter-policy`

2. **Create a new IAM User:**
   - Go to AWS IAM Console → Users → Add User
   - Enter a name like `n8n-pdf-converter`
   - Select "Access key - Programmatic access"
   - Click "Next: Permissions"
   - Choose "Attach existing policies directly"
   - Search for and select your `n8n-pdf-converter-policy`
   - Complete user creation and save the access key ID and secret

3. **Use these credentials in n8n:**
   - When setting up your AWS credentials in n8n, use these limited access keys
   - This restricts n8n to only invoke this specific Lambda function
   - No other AWS resources or actions will be available to n8n

### Setting Up in n8n

1. In your n8n workflow, add an **AWS Lambda** node
2. Configure AWS credentials in n8n:
   - Access Key ID (from limited IAM user)
   - Secret Access Key (from limited IAM user)
   - Region (must match your Lambda function's region)
3. In the Lambda node configuration:
   - Function Name: `pdf-to-jpg-converter` (or your chosen name)
   - Invocation Type: `RequestResponse`


## 🧩 Alternative Approach: Lambda Layers

While this project uses a Docker-based approach, another common method is to use Lambda Layers. Here's a brief overview:

### What are Lambda Layers?

Lambda Layers are a way to package code and dependencies that can be shared across multiple Lambda functions.

**In simple terms:**
- Layers are packages of libraries or runtime components
- They get "attached" to your Lambda function when it runs
- They save you from having to include common dependencies in every function

**Layer Structure for Python:**
```
layer.zip
│
└── python/
    └── lib/
        └── python3.12/
            └── site-packages/
                └── [your packages and modules]
```

**For binary dependencies (like poppler):**
```
layer.zip
│
└── bin/               # Executable files
└── lib/               # Shared libraries
└── include/           # Header files
```

You can learn more about this approach in AWS documentation if needed.

## 🤝 Join the Getting Automated Community

Want to go deeper with automation and get direct support? Join our exclusive automation community!

### What You Get from the Getting Automated Community:
- **In-depth Automation Workflows**: Learn how to integrate AI into your automation processes
- **Battle-Tested Templates**: Access exclusive, production-ready automation templates
- **Expert Guidance**: Get direct support from automation professionals
- **Early Access to Content**: Be the first to access exclusive content
- **Private Support Channels**: Receive personalized support through direct chat and office hours
- **Community of Serious Builders**: Connect with like-minded professionals

The community is capped at 250 members to ensure quality support and interaction.

[Join the Getting Automated Community](https://gettingautomated.com/community)

## 🔗 Additional Resources

- **Website**: [Getting Automated](https://gettingautomated.com)
- **YouTube Channel**: [Getting Automated YouTube](https://www.youtube.com/@hunterasneed)
- **Free Workflow Automation Tools**: [Automation Tools](https://tools.gettingautomated.com)

### Need Personalized Help?

If you need this solution built for you or want personalized guidance, you can schedule a consultation:

[Schedule a 30-Minute Connect](https://calendly.com/workflowsy/30-minute-connect)

## 📄 License

MIT
