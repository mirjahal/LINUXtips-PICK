FROM cgr.dev/chainguard/python:latest-dev as builder
ENV PATH="/app/venv/bin:$PATH"
WORKDIR /app
RUN python -m venv /app/venv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
ARG REDIS_HOST="127.0.0.1"
ENV REDIS_HOST=$REDIS_HOST
ENV PATH="/venv/bin:$PATH"
COPY . .
COPY --from=builder /app/venv /venv
ENTRYPOINT [ "python", "-m" , "flask", "run", "--host=0.0.0.0"]
EXPOSE 5000
