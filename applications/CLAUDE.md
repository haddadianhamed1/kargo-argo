# FastAPI Application

This directory contains a FastAPI web service with HIV-related endpoints.

## Application Structure

```
applications/
├── main.py              # FastAPI application entry point
├── requirements.txt     # Python dependencies
├── Dockerfile          # Container build configuration
├── .dockerignore       # Docker build exclusions
├── README.md           # User documentation
└── CLAUDE.md           # This file - development context
```

## Application Details

### main.py
The main FastAPI application file containing:
- **FastAPI app instance** - Core application setup
- **GET /hiv1** - Endpoint returning "hiv1" string
- **GET /hiv2** - Endpoint returning "hiv2" string
- **Uvicorn runner** - Development server configuration

### API Endpoints

| Endpoint | Method | Response | Description |
|----------|--------|----------|-------------|
| `/hiv1`  | GET    | "hiv1"   | Returns hiv1 identifier |
| `/hiv2`  | GET    | "hiv2"   | Returns hiv2 identifier |

### Dependencies

- **FastAPI 0.104.1** - Modern async web framework
- **Uvicorn 0.24.0** - ASGI server implementation

## Development Workflow

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Or run directly
python main.py
```

### Docker Development
```bash
# Build container
docker build -t fastapi-app .

# Run container
docker run -p 8000:8000 fastapi-app
```

### API Documentation
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Code Patterns

- **Simple route handlers** - Direct string returns
- **Standard FastAPI setup** - Minimal configuration
- **Container-ready** - Optimized Dockerfile with proper layering
- **Development-friendly** - Auto-reload and debug-ready setup

## Extension Points

When adding new endpoints:
1. Add route handler functions to `main.py`
2. Follow the existing pattern for simple responses
3. Update this documentation if adding significant functionality
4. Consider adding request/response models for complex data

## Performance Considerations

- Current endpoints are simple string responses (minimal overhead)
- Uvicorn runs on single worker by default
- For production, consider: multiple workers, reverse proxy, health checks
