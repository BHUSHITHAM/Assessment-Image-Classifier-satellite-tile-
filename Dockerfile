# CPU-only image -- deliberately avoids the default `pip install torch`,
# which pulls in several GB of nvidia-cu* packages that are useless (and
# often too large to even fit) on a CPU-only offline deployment target.
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir torch --no-deps \
    && pip install --no-cache-dir torchvision --no-deps \
    && pip install --no-cache-dir -r requirements.txt

COPY models.py data.py storage.py main.py ./
COPY checkpoints/ ./checkpoints/

# Results DB and uploaded tiles are written here at runtime -- mount this as
# a volume if you need them to survive container restarts (see docker-compose.yml).
VOLUME ["/app/data"]
ENV DB_PATH=/app/data/results.db
ENV TILE_STORAGE_DIR=/app/data/stored_tiles

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
