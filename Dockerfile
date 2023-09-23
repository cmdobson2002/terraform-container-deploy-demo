# Specify python version we're using
FROM python:3.9
# Set the working directory in the container to `/code`
WORKDIR /code
# Copy over our requirements.txt file into the container **note the /code, due to previous line**
COPY ./requirements.txt /code/requirements.txt
# Install all of our dependencies
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
# Copy our backend source code into the container
COPY ./app /code/app
# Start the server: --reload to continuously reload the server when changes occur
CMD ["uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "8080"]
