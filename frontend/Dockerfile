FROM python:3.13-slim
WORKDIR /app
COPY . /app
EXPOSE 80
CMD ["python", "-m", "http.server", "80", "--bind", "0.0.0.0"]
