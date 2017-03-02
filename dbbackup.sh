#!/bin/bash
echo "$(date) Backuping database $POSTGRES_USER in mode $1"
if [ $AWS_KEY == "" ] || [ $AWS_SECRET == "" ] || [ $S3BUCKET == "" ]; then
    echo "$(date) AWS_KEY or AWS_SECRET or S3BUCKET is null"
    exit 0
fi

BF=/tmp/$POSTGRES_USER-db-$(date +%Y%m%d%H%M%S).tar.gz
pg_dump --username=postgres --no-password --format=tar --encoding=UTF8 $POSTGRES_USER > $BF

echo "$(date) Uploading into AWS S3 $BF"
s3cmd put $BF --access_key=$AWS_KEY --secret_key=$AWS_SECRET --storage-class=STANDARD_IA --encrypt --region=$S3REGION $S3BUCKET$1

rm $BF
