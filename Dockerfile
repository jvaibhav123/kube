FROM ubuntu:latest
RUN apt-get update -y
RUN apt-get install -y python python-pip libmysqlclient-dev
COPY app/requirements.txt .
RUN pip install -r requirements.txt
COPY app /app
WORKDIR /app
EXPOSE 5000
CMD ["gunicorn", "-b" , "0.0.0.0:5000", "hello:app"]
