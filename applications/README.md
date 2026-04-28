# FastAPI Application

A simple FastAPI application with two endpoints.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the application:
```bash
python main.py
```

Or with uvicorn directly:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Docker

### Build the Docker image:
```bash
docker build -t fastapi-app .
```

### Run with Docker:
```bash
docker run -p 8000:8000 fastapi-app
```

## Endpoints

- `GET /hiv1` - Returns "hiv1"
- `GET /hiv2` - Returns "hiv2"

The application runs on http://localhost:8000

You can also view the interactive API documentation at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
