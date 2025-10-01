FROM python:3.11-slim

# Configurar directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos de requisitos
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY flows/ ./flows/
COPY *.py ./

# Variables de entorno por defecto
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Exponer puerto para webhooks (si es necesario)
EXPOSE 8000

# Comando por defecto
CMD ["python", "flows/main_flow.py"]