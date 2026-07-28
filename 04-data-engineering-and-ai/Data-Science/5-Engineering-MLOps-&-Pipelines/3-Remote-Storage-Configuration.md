# Part 3: Remote Storage Configuration (AWS S3, GCS, and Network Shares)

## The Target: Configuring DVC Remote Storage

In this part, we'll configure DVC to use remote storage backends, enabling team collaboration and data backup. We'll cover AWS S3, Google Cloud Storage, and network shares, with a focus on security best practices.

## The Concept: Centralized Data Storage

Think of remote storage like a shared warehouse for your data:
- Your **local machine** is your personal workshop where you work
- The **remote storage** is the central warehouse where all data versions are stored
- When you "push" data, you're sending it to the warehouse
- When you "pull" data, you're retrieving it from the warehouse

This setup enables:
- **Team collaboration**: Everyone accesses the same data versions
- **Backup**: Your data is safe even if your local machine fails
- **CI/CD**: Automated pipelines can access the same data

## The Implementation: Setting Up Remote Storage

### Step 1: Choose Your Remote Storage Backend

We'll set up all three backends, but you can choose the one that fits your needs:

| Backend | Best For | Cost | Ease of Setup |
|---------|----------|------|---------------|
| AWS S3 | Production, scalable | Pay-as-you-go | Moderate |
| GCS | Google Cloud ecosystem | Pay-as-you-go | Moderate |
| Network Share | On-premises, prototyping | Low (existing infrastructure) | Easy |

### Step 2: AWS S3 Configuration

#### 2.1: Create an S3 Bucket

First, you need an AWS account and S3 bucket. Here's how to set it up:

```bash
# Install AWS CLI if you haven't already
pip install awscli

# Configure AWS credentials
aws configure
# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)

# Create an S3 bucket (replace with your unique bucket name)
aws s3 mb s3://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)

# Example: aws s3 mb s3://mlops-pipeline-data-john-20240101
```

#### 2.2: Configure DVC with S3

```bash
# Configure DVC remote for S3
# First, remove any existing default remote
dvc remote remove default 2>/dev/null || true

# Add S3 remote
dvc remote add s3_remote s3://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)

# Set as default
dvc remote default s3_remote

# Optional: Configure specific S3 settings
dvc remote modify s3_remote region us-east-1
dvc remote modify s3_remote endpointurl https://s3.amazonaws.com
dvc remote modify s3_remote acl bucket-owner-full-control
```

### Step 3: Google Cloud Storage Configuration

#### 3.1: Set Up GCS

```bash
# Install Google Cloud SDK
# Follow instructions at: https://cloud.google.com/sdk/docs/install

# Initialize gcloud
gcloud init

# Authenticate
gcloud auth application-default login

# Create a bucket (replace with your unique bucket name)
gsutil mb gs://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)

# Example: gsutil mb gs://mlops-pipeline-data-john-20240101
```

#### 3.2: Configure DVC with GCS

```bash
# Add GCS remote
dvc remote add gcs_remote gs://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)

# Set as default (optional)
dvc remote default gcs_remote

# Configure credentials via environment variable (more secure)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"

# Or use DVC's built-in config
dvc remote modify gcs_remote credentialpath /path/to/your/service-account-key.json
```

### Step 4: Network Share Configuration

For on-premises or local network storage:

```bash
# For a local directory (nfs mount, etc.)
dvc remote add network_remote /mnt/shared/dvc-storage

# Or for a network location (Windows SMB, NFS, etc.)
# Make sure the directory is mounted first
mkdir -p /mnt/dvc-storage
# Mount your network share (example for NFS)
sudo mount -t nfs 192.168.1.100:/exports/dvc-storage /mnt/dvc-storage

# Add the remote
dvc remote add network_remote /mnt/dvc-storage

# Set as default
dvc remote default network_remote
```

### Step 5: Security Best Practices

Create a secure environment file for credentials:

```bash
# Create a .env file (never commit this to Git!)
cat > .env << 'EOF'
# AWS S3 Credentials
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=us-east-1

# GCS Credentials
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json

# DVC Remote Configuration
DVC_REMOTE_TYPE=s3  # Options: s3, gcs, network
DVC_REMOTE_PATH=s3://your-bucket-name
EOF

# Update .gitignore to exclude .env
echo ".env" >> .gitignore
```

### Step 6: Configure DVC to Use Environment Variables

```bash
# Modify DVC config to use environment variables
cat > .dvc/config.local << 'EOF'
# This file is for local configuration and should NOT be committed to Git
# It overrides settings in .dvc/config

['remote "s3_remote"']
url = ${DVC_REMOTE_PATH}
access_key_id = ${AWS_ACCESS_KEY_ID}
secret_access_key = ${AWS_SECRET_ACCESS_KEY}
region = ${AWS_DEFAULT_REGION}

['remote "gcs_remote"']
url = ${DVC_REMOTE_PATH}
credentialpath = ${GOOGLE_APPLICATION_CREDENTIALS}
EOF

# Make sure .dvc/config.local is in .gitignore
echo ".dvc/config.local" >> .gitignore
```

### Step 7: Test the Remote Configuration

```bash
# Push all data to remote storage
dvc push -v

# Expected output should show all files being uploaded
# 1 file pushed: data/raw/sensor_data_48h.csv
# 1 file pushed: data/raw/sensor_data_168h.csv
# 1 file pushed: data/processed/features_48h.csv
# 1 file pushed: data/processed/features_168h.csv

# Verify the files exist in remote storage
# For S3:
aws s3 ls s3://your-bucket-name/

# For GCS:
gsutil ls gs://your-bucket-name/

# For network share:
ls -la /mnt/dvc-storage/
```

### Step 8: Create a Robust Remote Configuration Script

Let's create a script to automate remote configuration based on environment variables:

```bash
cat > scripts/configure_dvc_remote.sh << 'EOF'
#!/bin/bash
# Script to configure DVC remote based on environment variables

set -e  # Exit on error

echo "Configuring DVC remote..."

# Load environment variables
if [ -f .env ]; then
    echo "Loading .env file..."
    set -a
    source .env
    set +a
fi

# Determine remote type
REMOTE_TYPE=${DVC_REMOTE_TYPE:-s3}
echo "Using remote type: $REMOTE_TYPE"

case $REMOTE_TYPE in
    s3)
        echo "Configuring AWS S3 remote..."
        dvc remote remove s3_remote 2>/dev/null || true
        dvc remote add s3_remote ${DVC_REMOTE_PATH:-s3://mlops-pipeline-data}
        dvc remote default s3_remote
        dvc remote modify s3_remote region ${AWS_DEFAULT_REGION:-us-east-1}
        dvc remote modify s3_remote access_key_id ${AWS_ACCESS_KEY_ID}
        dvc remote modify s3_remote secret_access_key ${AWS_SECRET_ACCESS_KEY}
        ;;
    gcs)
        echo "Configuring Google Cloud Storage remote..."
        dvc remote remove gcs_remote 2>/dev/null || true
        dvc remote add gcs_remote ${DVC_REMOTE_PATH:-gs://mlops-pipeline-data}
        dvc remote default gcs_remote
        dvc remote modify gcs_remote credentialpath ${GOOGLE_APPLICATION_CREDENTIALS}
        ;;
    network)
        echo "Configuring network share remote..."
        dvc remote remove network_remote 2>/dev/null || true
        dvc remote add network_remote ${DVC_REMOTE_PATH:-/mnt/shared/dvc-storage}
        dvc remote default network_remote
        ;;
    *)
        echo "Unknown remote type: $REMOTE_TYPE"
        echo "Valid options: s3, gcs, network"
        exit 1
        ;;
esac

echo "DVC remote configuration complete!"
echo "Remote type: $REMOTE_TYPE"
echo "Remote path: $(dvc remote default)"
EOF

chmod +x scripts/configure_dvc_remote.sh
```

### Step 9: Push All Data to Remote Storage

```bash
# Run the configuration script
./scripts/configure_dvc_remote.sh

# Push all data to remote storage
dvc push -v

# Verify the push was successful
dvc status --remote

# This should show that all data is synchronized with remote
```

### Step 10: Test Pull from Remote

Simulate a fresh environment and test pulling data:

```bash
# Create a test directory
mkdir -p /tmp/dvc_test
cd /tmp/dvc_test

# Clone the repository
git clone /path/to/your/repo .
# or clone from remote: git clone https://github.com/yourusername/mlops-pipeline-series.git .

# Configure DVC remote
cp /path/to/your/repo/.env .env  # Copy environment variables
source .env
dvc remote add s3_remote ${DVC_REMOTE_PATH}
dvc remote default s3_remote

# Pull the data
dvc pull

# Verify data was downloaded
ls -la data/raw/
ls -la data/processed/

# Clean up
cd - && rm -rf /tmp/dvc_test
```

### Step 11: Implement Data Version Tags for Remote

```bash
# Create a tagging script for remote data versions
cat > scripts/tag_data_version.sh << 'EOF'
#!/bin/bash
# Script to tag data versions and push to remote

VERSION_TAG=${1:-v1.0.0}
COMMIT_MSG=${2:-"Data version $VERSION_TAG"}

echo "Tagging data version: $VERSION_TAG"

# Tag all tracked files
for file in $(dvc list --all); do
    echo "Tagging $file"
    dvc tag $file $VERSION_TAG
done

# Commit the tags
git add .
git commit -m "$COMMIT_MSG"

# Push tags to remote
dvc push --all-tags
git push --tags

echo "Data version $VERSION_TAG tagged and pushed!"
EOF

chmod +x scripts/tag_data_version.sh

# Use the script
./scripts/tag_data_version.sh v1.0.0 "Initial data version"
./scripts/tag_data_version.sh v1.1.0 "Added 168h dataset with enhanced features"
```

### Step 12: Set Up Automated Backup

Create a backup script that runs on a schedule:

```bash
cat > scripts/backup_data.sh << 'EOF'
#!/bin/bash
# Automated backup script for DVC data

BACKUP_LOG="logs/dvc_backup_$(date +%Y%m%d).log"
mkdir -p logs

echo "Starting DVC backup at $(date)" | tee -a $BACKUP_LOG

# Check for uncommitted changes
if dvc status | grep -q "changed"; then
    echo "WARNING: Uncommitted changes detected!" | tee -a $BACKUP_LOG
    echo "Run 'dvc commit' or 'dvc push' manually." | tee -a $BACKUP_LOG
    exit 1
fi

# Pull latest changes from remote
echo "Pulling latest changes..." | tee -a $BACKUP_LOG
dvc pull 2>&1 | tee -a $BACKUP_LOG

# Push all data to remote
echo "Pushing data to remote..." | tee -a $BACKUP_LOG
dvc push --all-commits 2>&1 | tee -a $BACKUP_LOG

# Verify backup
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)" | tee -a $BACKUP_LOG
else
    echo "ERROR: Backup failed at $(date)" | tee -a $BACKUP_LOG
    exit 1
fi
EOF

chmod +x scripts/backup_data.sh

# Test the backup script
./scripts/backup_data.sh
```

## The Verification: Testing Remote Storage

### Verification 1: Check Remote Status

```bash
# Check synchronization status
dvc status --remote

# Expected output should show:
# All commits are up to date.
```

### Verification 2: Verify Remote Files

```bash
# List files in remote (S3)
aws s3 ls ${DVC_REMOTE_PATH} --recursive

# Or for GCS:
gsutil ls ${DVC_REMOTE_PATH}/**/*

# Or for network share:
find /mnt/dvc-storage -type f
```

### Verification 3: Test Push/Pull Cycle

```bash
# Make a small change
echo "new,data,row" >> data/raw/sensor_data_48h.csv
dvc add data/raw/sensor_data_48h.csv

# Push the change
dvc push data/raw/sensor_data_48h.csv.dvc

# Simulate a fresh environment
rm -rf .dvc/cache data/raw/sensor_data_48h.csv

# Pull the change
dvc pull data/raw/sensor_data_48h.csv.dvc

# Verify the change was restored
tail -n 1 data/raw/sensor_data_48h.csv
```

### Verification 4: Test Remote with Multiple Environments

```bash
# Create a script to test remote access from different environments
cat > tests/test_remote_access.py << 'EOF'
#!/usr/bin/env python
"""
Test remote DVC storage access from different environments.
"""

import os
import subprocess
import sys


def test_remote_access():
    """Test that DVC can access remote storage."""
    
    # Check environment variables
    env_vars = ['DVC_REMOTE_TYPE', 'DVC_REMOTE_PATH']
    missing_vars = [var for var in env_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"ERROR: Missing environment variables: {missing_vars}")
        sys.exit(1)
    
    # Test DVC remote access
    try:
        result = subprocess.run(
            ['dvc', 'remote', 'default'],
            capture_output=True,
            text=True,
            check=True
        )
        print(f"Default remote: {result.stdout.strip()}")
    except subprocess.CalledProcessError as e:
        print(f"ERROR: DVC remote access failed: {e}")
        sys.exit(1)
    
    # Test pushing a small file
    test_file = 'test_remote.txt'
    with open(test_file, 'w') as f:
        f.write('Test remote access')
    
    try:
        subprocess.run(['dvc', 'add', test_file], check=True)
        subprocess.run(['dvc', 'push', f'{test_file}.dvc'], check=True)
        print("Successfully pushed test file to remote")
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Push failed: {e}")
        sys.exit(1)
    finally:
        # Clean up
        os.remove(test_file)
        os.remove(f'{test_file}.dvc')
    
    print("All remote access tests passed!")


if __name__ == "__main__":
    test_remote_access()
EOF

chmod +x tests/test_remote_access.py

# Run the test
python tests/test_remote_access.py
```

### Verification 5: Test Disaster Recovery

```bash
# Simulate a complete data loss
rm -rf .dvc/cache data/raw data/processed

# Pull everything from remote
dvc pull

# Verify all data is restored
ls -la data/raw/
ls -la data/processed/
wc -l data/raw/*.csv
wc -l data/processed/*.csv
```

## Advanced Remote Configuration

### Using Multiple Remotes

```bash
# Add multiple remotes for different purposes
dvc remote add prod_s3 s3://mlops-prod-data
dvc remote add staging_gcs gs://mlops-staging-data
dvc remote add backup_network /mnt/backup/dvc-storage

# Configure different remotes for different data
dvc remote modify raw_data --remote prod_s3
dvc remote modify features --remote staging_gcs

# Push specific files to specific remotes
dvc push data/raw/sensor_data_48h.csv.dvc --remote prod_s3
dvc push data/processed/features_48h.csv.dvc --remote staging_gcs
```

### Setting Up Remote File Versioning

```bash
# Enable versioning on S3 bucket
aws s3api put-bucket-versioning \
    --bucket mlops-pipeline-data-john-20240101 \
    --versioning-configuration Status=Enabled

# This provides an additional layer of protection
```

### Configuring Access Control

```bash
# Create a DVC remote with specific access permissions
# For S3 with server-side encryption
dvc remote modify s3_remote sse AES256
dvc remote modify s3_remote acl private

# For GCS with encryption
dvc remote modify gcs_remote encryption_key ${ENCRYPTION_KEY}
dvc remote modify gcs_remote unified true
```

## What We've Accomplished

By completing this part, you have:

1. **Configured multiple remote storage backends** (S3, GCS, network share)
2. **Implemented secure credential management** using environment variables
3. **Created automation scripts** for remote configuration and backup
4. **Tested push/pull operations** to ensure data synchronization
5. **Set up data version tagging** for reproducible deployments
6. **Implemented disaster recovery procedures**
7. **Configured access control and encryption** for sensitive data

## Common Remote Storage Commands

| Command | Purpose |
|---------|---------|
| `dvc push` | Upload data to remote |
| `dvc pull` | Download data from remote |
| `dvc status --remote` | Check synchronization status |
| `dvc remote list` | List configured remotes |
| `dvc remote default` | Show default remote |
| `dvc remote modify` | Change remote settings |
| `dvc tag` | Tag specific data versions |

## Security Best Practices

1. **Never commit credentials** to Git
2. **Use environment variables** or AWS IAM roles
3. **Enable server-side encryption** for cloud storage
4. **Implement access controls** (IAM policies for cloud)
5. **Rotate credentials regularly**
6. **Use separate buckets** for different environments
7. **Enable logging** for audit trails
8. **Implement data expiration policies** for cost management

## Troubleshooting

**Issue:** Permission denied when pushing to S3
```bash
# Solution: Check IAM permissions
aws sts get-caller-identity  # Verify identity
aws s3 ls  # Verify S3 access
# Ensure your IAM user has s3:PutObject and s3:GetObject permissions
```

**Issue:** GCS authentication failure
```bash
# Solution: Re-authenticate
gcloud auth application-default login
# Or use a service account
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
```

**Issue:** Network share mount failing
```bash
# Solution: Check mount status
mount | grep dvc-storage
# Or remount
sudo mount -a
```

**Issue:** Data cache corruption
```bash
# Solution: Rebuild cache
dvc gc --force  # Clean cache
dvc pull  # Redownload everything
```

## Next Steps

You now have a complete data versioning infrastructure with remote storage! In Part 4, we'll:
- Set up MLflow for experiment tracking
- Integrate MLflow with DVC
- Track model training runs
- Implement the model registry

---

*End of Part 3: Remote Storage Configuration*
