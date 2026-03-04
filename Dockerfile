FROM python:3@sha256:b66f77a332babd8b2b0190f10a65eeb90c49d8da4696f7a3436baf1b1220eeec

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

