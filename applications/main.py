from fastapi import FastAPI

app = FastAPI()


@app.get("/hiv1")
def get_hiv1():
    return "hiv1"


@app.get("/hiv2")
def get_hiv2():
    return "hiv2"


@app.get("/hamed")
def get_hamed():
    return "hamed"


@app.get("/test2")
def get_test2():
    return "test2"


@app.get("/interviewtest")
def get_interviewtest():
    return "interviewtest"


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
