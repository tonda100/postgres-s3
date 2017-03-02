## PostgreSQL database with AWS S3 backup

This image is based on official Postgres [image](https://hub.docker.com/_/postgres/) so you can use everything mentioned there.
The image regularly backups the database and uploads the backup into AWS S3 using infrequent storage class. The database is backed up every hour.

How to setup AWS S3 Bucket
 1. Create Bucket in your region e.g. **com-yourcompany**
 2. Create folder for database backups inside the bucket e.g. **dbbackup**
 3. Inside dbbackup folder create three other folders with names
    1. **month** - there will be monthly db backups kept forever
    2. **day** - there will be daily db backups kept for 64 days
    3. **hour** - there will be hourly db backups kept for 4 days
 4. The structure looks like 
    * com-yourcompany\dbbackup\month
    * com-yourcompany\dbbackup\day
    * com-yourcompany\dbbackup\hour
 5. Setup the expiration of daily and hourly backups
    1. Add Lifecycle rule on the bucket com-yourcompany
    2. Apply the Rule to A prefix: **dbbackup/day**
    3. Permanently Delete **64** Days after the object's creation date
    4. Create and Activate the rule
    5. Add second Lifecycle rule on the bucket com-yourcompany
    6. Apply the Rule to A prefix: **dbbackup/hour**
    7. Permanently Delete **4** Days after the object's creation date
    8. Create and Activate the rule
 6. Done


### Environment variables
When starting the database with backup feature on you have to provide credentials for the upload through docker environment variables.
* **AWS_KEY** - access key to AWS S3
* **AWS_SECRET** - secret key to AWS S3
* **S3BUCKET** - AWS S3 bucket where the back ups will be stored
* **S3REGION** - region where the backup will be stored default value is us-east-1 

Run command will looks like 
 `docker run -d --name db -p 5432:5432 -e AWS_KEY=access_key -e AWS_SECRET=secret_key -e S3BUCKET=s3://com-yourcompany/dbbackup/ -e POSTGRES_USER=myapp -e POSTGRES_PASSWORD=my-password tonda100/postgres-s3`

If the AWS_KEY, AWS_SECRET or S3BUCKET will not be set. The image will works like ordinary postgres docker image.

The database backup are are triggered by cron at:
* monthly backups - at 0:15 on 1st day of every month
* daily backups - at 0:30 every day
* hourly backups - at x:45 every hour

The image uses the Europe/Prague timezone as default one. The timezone could be change using environment variable TZ e.g. -e TZ=America/Toronto

Project is available on [GitHub](https://github.com/tonda100/postgres-s3)