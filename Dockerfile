FROM python:3@sha256:7aea6827c8787754f99339ffed8cfc41fb09421f9c7d0e77a198b08422a3455e

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

