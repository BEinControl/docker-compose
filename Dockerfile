FROM python:slim-stretch
RUN pip install docker-compose==1.22.0
ENTRYPOINT ["/usr/local/bin/docker-compose"]
