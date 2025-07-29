# Use official Python base image
FROM python:3.9-slim

# Set work directory
WORKDIR /app

COPY requirement.txt .
RUN pip install -r requirement.txt

# Copy app code
COPY app.py .

# Expose port
EXPOSE 5000

# Run app
CMD ["python", "app.py"]

