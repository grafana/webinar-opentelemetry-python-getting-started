FROM python:3@sha256:e06cc1111ed84189e91866447f562b89faadbfbbb9937cd67e6bf4172cdb45df

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

