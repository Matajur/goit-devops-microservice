# Use Python 3.12 base image
FROM python:3.12-slim

# Set working directory
WORKDIR /code/web

# Install dependencies
COPY ./requirements.txt /code/web/requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# requirements.txt instead of /code/web/requirements.txt because the workdir is already /code/web

# Copy project files
COPY . /code/web

# Open port inside the container (not obligatory, equal to ports 8000:8000 in docker-compose.yml)
EXPOSE 8000

# Default command
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
