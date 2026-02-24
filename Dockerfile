FROM python:3.11-slim

WORKDIR /app

COPY . .

RUN pip install --upgrade pip
RUN pip install -r docReq.txt

RUN python manage.py migrate
RUN python manage.py collectstatic --noinput

CMD gunicorn StockMarket.wsgi --bind 0.0.0.0:${PORT:-8000}
