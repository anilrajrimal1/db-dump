# db-dump
Flexible Docker image for automated Postgres and MongoDB backups with S3 upload.

## Description
A lightweight and flexible Docker image designed to automate backups for Postgres and MongoDB databases. This image supports multiple backup configurations, compression, and secure uploads to AWS S3, making it ideal for development, staging, and production environments.

## Features
- **Flexible Backup Options**: Backup Postgres, MongoDB, or both databases.
- **Compressed Backups**: Reduces storage usage with compressed database dumps.
- **Cron Scheduling**: Built-in cron for automated, scheduled backups.
- **Local Retention Policy**: Configurable retention for local backup files.
- **AWS S3 Upload**: Securely upload backups to AWS S3 buckets.
- **Minimal Footprint**: Lightweight image optimized for efficiency.
- **Versioned Tags**: Stable versioning for safe usage across environments.

## Topics / Tags
`backup`, `postgres`, `mongodb`, `s3`, `cron`, `docker-image`, `devops`, `database`

## Getting Started
### Prerequisites
- Docker installed on your system.
- Access to a Postgres and/or MongoDB database.
- AWS account with S3 bucket and credentials (Access Key ID and Secret Access Key).
- Optional: Docker Compose for easier setup.

### Environment Variables
Create a `.env` file to configure the backup settings. Example:

```env
# Postgres settings
POSTGRES_HOST=db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=yourpassword
POSTGRES_DBS="A B C D"

# MongoDB settings
MONGO_HOST=mongo
MONGO_DB=your_db
MONGO_USER=
MONGO_PASSWORD=

# AWS S3 settings
S3_BACKUP_PATH=s3_path #use path part from s3://path URI
AWS_REGION=your_region
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Backup options
BACKUP_TYPE=all           # Options: postgres, mongo, or all
BACKUP_CRON="0 2 * * *"   # Cron expression for daily backups at 2 AM
RETENTION_DAYS=5          # Number of days to retain local backups
```

### Docker Compose Example
Below is an example `docker-compose.yml` to run the backup service:

```yaml
version: '3.8'
services:
  backup:
    image: anilrajrimal/db-dump:latest
    env_file:
      - .env
    volumes:
      - ./backups:/backups
    depends_on:
      - db
      - mongo
    environment:
      - BACKUP_TYPE=all
    command: >
      sh -c "
      echo \"$BACKUP_CRON /scripts/backup.sh >> /var/log/backup.log 2>&1\" | crontab - &&
      crond -f -l 2
      "
    restart: unless-stopped
```

### Usage Notes
- **Backup Type**: Use the `BACKUP_TYPE` environment variable to specify `postgres`, `mongo`, or `all` for selective backups.
- **Cron Scheduling**: The `BACKUP_CRON` variable defines the backup schedule using standard cron syntax (e.g., `0 2 * * *` for daily at 2 AM).
- **Local Retention**: The `RETENTION_DAYS` variable controls how long local backups are kept. Use S3 lifecycle rules for cloud retention.
- **Logs and Backups**: Mount the `/backups` directory to access backup files and logs externally.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue on GitHub to suggest improvements or report bugs.

## Support
For issues or questions, open an issue on the [GitHub repository](https://github.com/anilrajrimal1/db-dump).