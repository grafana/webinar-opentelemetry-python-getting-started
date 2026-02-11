FROM python:3@sha256:151ab3571dad616bb031052e86411e2165295c7f67ef27206852203e854bcd12

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

