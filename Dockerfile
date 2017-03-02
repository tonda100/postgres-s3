FROM postgres:9.6.1
MAINTAINER Antonin Stoklasek

ENV AWS_KEY=
ENV AWS_SECRET=
ENV S3BUCKET=
ENV S3REGION=us-east-1

ENV TZ=Europe/Prague
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get -y install s3cmd cron

ADD dbbackup.sh /opt
RUN chmod 755 /opt/dbbackup.sh

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/dbbackup-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/dbbackup-cron

ADD start_services.sh /
RUN chmod 755 /start_services.sh

CMD /start_services.sh