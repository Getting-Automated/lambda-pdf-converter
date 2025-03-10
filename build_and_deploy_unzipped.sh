#!/bin/bash

# Set variables
LAMBDA_FUNCTION_NAME="pdf-to-jpg-converter-unzipped"
ECR_REPOSITORY_NAME="pdf-to-jpg-converter-unzipped"
LAMBDA_ROLE_NAME="lambda-execution-role"
AWS_REGION="us-east-1"  # Change to your preferred region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Disable AWS CLI pager to avoid needing to press 'q'
export AWS_PAGER=""

echo -e "${YELLOW}Building and deploying Docker-based Lambda function...${NC}"

# Check if the Lambda execution role exists, create if it doesn't
echo -e "${YELLOW}Checking if Lambda execution role exists...${NC}"
if ! aws iam get-role --role-name ${LAMBDA_ROLE_NAME} &> /dev/null; then
    echo -e "${YELLOW}Creating Lambda execution role: ${LAMBDA_ROLE_NAME}${NC}"
    aws iam create-role --role-name ${LAMBDA_ROLE_NAME} \
        --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
        &> /dev/null
    
    aws iam attach-role-policy --role-name ${LAMBDA_ROLE_NAME} \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
        &> /dev/null
    
    echo -e "${YELLOW}Waiting for role to propagate (10 seconds)...${NC}"
    sleep 10
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create Lambda execution role.${NC}"
        exit 1
    else
        echo -e "${GREEN}Lambda execution role created successfully.${NC}"
    fi
else
    echo -e "${GREEN}Lambda execution role already exists.${NC}"
fi

# Get the role ARN
LAMBDA_ROLE_ARN=$(aws iam get-role --role-name ${LAMBDA_ROLE_NAME} --query 'Role.Arn' --output text)
echo -e "${GREEN}Using Lambda role: ${LAMBDA_ROLE_ARN}${NC}"

# Create ECR repository if it doesn't exist
echo -e "${YELLOW}Checking if ECR repository exists...${NC}"
if ! aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} --region ${AWS_REGION} &> /dev/null; then
    echo -e "${YELLOW}Creating ECR repository: ${ECR_REPOSITORY_NAME}${NC}"
    aws ecr create-repository --repository-name ${ECR_REPOSITORY_NAME} --region ${AWS_REGION}
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create ECR repository.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}ECR repository already exists.${NC}"
fi

# Authenticate Docker to ECR
echo -e "${YELLOW}Authenticating Docker to ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to authenticate Docker to ECR.${NC}"
    exit 1
fi

# Create a temporary Dockerfile for the unzipped version
echo -e "${YELLOW}Creating temporary Dockerfile...${NC}"
cat > Dockerfile.unzipped << EOL
FROM public.ecr.aws/lambda/python:3.9

# Install system dependencies
RUN yum update -y && \
    yum install -y poppler poppler-utils && \
    yum clean all

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install -r requirements.txt --no-cache-dir

# Copy function code
COPY lambda_function_unzipped.py ${LAMBDA_TASK_ROOT}/lambda_function.py

CMD ["lambda_function.lambda_handler"]
EOL

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build --platform linux/amd64 -t ${ECR_REPOSITORY_NAME}:latest -f Dockerfile.unzipped .
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build Docker image.${NC}"
    exit 1
fi

# Tag Docker image
echo -e "${YELLOW}Tagging Docker image...${NC}"
docker tag ${ECR_REPOSITORY_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to tag Docker image.${NC}"
    exit 1
fi

# Push Docker image to ECR
echo -e "${YELLOW}Pushing Docker image to ECR...${NC}"
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to push Docker image to ECR.${NC}"
    exit 1
fi

# Check if Lambda function exists
echo -e "${YELLOW}Checking if Lambda function exists...${NC}"
if aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --region ${AWS_REGION} &> /dev/null; then
    # Update existing Lambda function
    echo -e "${YELLOW}Updating existing Lambda function...${NC}"
    aws lambda update-function-code \
        --function-name ${LAMBDA_FUNCTION_NAME} \
        --image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest \
        --region ${AWS_REGION}
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to update Lambda function.${NC}"
        exit 1
    fi
else
    # Create new Lambda function
    echo -e "${YELLOW}Creating new Lambda function...${NC}"
    aws lambda create-function \
        --function-name ${LAMBDA_FUNCTION_NAME} \
        --package-type Image \
        --code ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest \
        --role ${LAMBDA_ROLE_ARN} \
        --timeout 30 \
        --memory-size 1024 \
        --region ${AWS_REGION}
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create Lambda function.${NC}"
        exit 1
    fi
    
    # Set up CloudWatch Logs log group with retention
    echo -e "${YELLOW}Creating CloudWatch Logs log group...${NC}"
    LOG_GROUP_NAME="/aws/lambda/${LAMBDA_FUNCTION_NAME}"
    
    aws logs create-log-group --log-group-name ${LOG_GROUP_NAME} --region ${AWS_REGION}
    aws logs put-retention-policy --log-group-name ${LOG_GROUP_NAME} --retention-in-days 7 --region ${AWS_REGION}
fi

# Clean up temporary Dockerfile
rm Dockerfile.unzipped

echo -e "${GREEN}Docker-based Lambda function deployed successfully!${NC}"
echo -e "${GREEN}Function ARN: $(aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --query 'Configuration.FunctionArn' --output text --region ${AWS_REGION})${NC}"
echo -e "${GREEN}You can invoke this Lambda directly using the AWS CLI or SDK:${NC}"
echo -e "${GREEN}aws lambda invoke --function-name ${LAMBDA_FUNCTION_NAME} --payload '<base64-encoded-pdf-or-url-json>' output.txt${NC}"
echo -e "${GREEN}Deployment complete!${NC}"