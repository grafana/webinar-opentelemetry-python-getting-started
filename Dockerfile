FROM python:3@sha256:e4bc83a3314d078d651f06c8440e9a03ba892ee2f6577437f174abd8731fb343

WORKDIR /src

COPY ./app.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt

RUN opentelemetry-bootstrap -a install

EXPOSE 8080

CMD [ "opentelemetry-instrument", "flask", "run", "-h", "0.0.0.0", "-p", "8080" ]

