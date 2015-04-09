FROM ubuntu:14.04
MAINTAINER Dave P

# Create user
RUN useradd --create-home --uid 1000 streamrecord ; \
    echo "streamrecord:streamrecord" | chpasswd ; \
    locale-gen en ; \
    sed -i 's/archive.ubuntu.com/mirror.math.ucdavis.edu/' /etc/apt/sources.list ; \
    apt-get update ; apt-get install -y vim nginx-full uwsgi uwsgi-plugin-python3 python3-cherrypy3 python3-jinja2 supervisor curl mkvtoolnix libav-tools cron ; \
    echo "daemon off;" >> /etc/nginx/nginx.conf ; \
    echo "* * * * * sleep 2 && curl -s http://127.0.0.1/api/tick > /dev/null" > /tmp/crontab ; \
    crontab -u streamrecord /tmp/crontab ; \
    rm /tmp/crontab ; \
    su -c "mkdir /home/streamrecord/app/" streamrecord 

# install configs
COPY default /etc/nginx/sites-available/default
COPY streamrecord.ini /etc/uwsgi/apps-enabled/streamrecord.ini
COPY nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY cron.conf /etc/supervisor/conf.d/cron.conf
COPY streamrecord.conf /etc/supervisor/conf.d/streamrecord.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Install python app code
COPY streamrecord/ /home/streamrecord/app/
RUN chown -R streamrecord  /home/streamrecord/app ; \
    su -c "mkdir /home/streamrecord/app/files /home/streamrecord/app/files/output /home/streamrecord/app/files/temp /home/streamrecord/app/sessions ; ln -s ../files/output /home/streamrecord/app/static/output" streamrecord ; \
    rm -rf /etc/cron*

EXPOSE 80

