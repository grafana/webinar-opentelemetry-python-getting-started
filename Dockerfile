FROM python:3@sha256:ffebef43892dd36262fa2b042eddd3320d5510a21f8440dce0a650a3c124b51d

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

