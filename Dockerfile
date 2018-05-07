FROM debian:jessie

RUN apt-get update -y && \
    apt-get install -y \
    	cron \
    	apache2 \
    	jq \
    	supervisor && \
    rm -rf /var/lib/apt/lists/*


# apache stuff
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /etc/supervisor/conf.d/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
# empty out the default index file
RUN echo "Working" > /var/www/html/index.html

# cron job which will run hourly
COPY ./crons /etc/cron.hourly/
RUN chmod +x /etc/cron.hourly/crons
# test crons added via crontab
RUN echo "*/1 * * * * uptime >> /var/www/html/index.html" | crontab -
RUN (crontab -l ; echo "*/2 * * * * free >> /var/www/html/index.html") 2>&1 | crontab -

# supervisord config file
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
WORKDIR /var/www/html/
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
