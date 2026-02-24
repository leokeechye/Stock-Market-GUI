# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stock Market AI-GUI is a Django web application for stock market analysis, LSTM-based price prediction, and reinforcement learning trading. It uses yfinance for market data, TensorFlow/Keras for ML models, and mpld3 for interactive browser-based charts.

## Commands

```bash
# Install dependencies
pip install -r requirements.txt        # full install
pip install -r docReq.txt              # minimal (Docker)
conda env create -f environment.yml    # conda alternative

# Run development server
python manage.py runserver             # serves at http://localhost:8000

# Database migrations
python manage.py migrate

# Docker
docker build -t smag:latest .
./runOnceDocker.sh
```

There is no test suite configured (Stock/tests.py is empty).

## Architecture

**Django project structure:** `StockMarket/` is the Django project config; `Stock/` is the single app.

**Request flow:** User form submissions go through `Stock/views.py`, which delegates to backend modules in `Stock/backend/`. The predict and trade features use AJAX endpoints that return JSON with embedded HTML charts.

**URL routes:**
- `/` — home page
- `/stock` — stock info (POST form → `stockinfo.py`)
- `/predict` + `/predict_stock/<params>` — LSTM prediction page + AJAX endpoint (`predict.py`)
- `/trade` + `/trade_stock/<params>` — trading agent page + AJAX endpoint (`trade.py`)

**Backend modules (`Stock/backend/`):**
- `stockinfo.py` — fetches Yahoo Finance data via yfinance, generates interactive mpld3 plots
- `predict.py` — LSTM neural network (1 layer, 128 units, 300 epochs, 0.8 dropout). Downloads data, normalizes with MinMaxScaler, trains, runs multiple simulations, filters valid predictions
- `trade.py` — Deep Evolution Strategy agent (window=30, layer_size=500, 3 output actions, 500 iterations, population=15). Generates buy/sell signals on historical data

**Visualization:** All charts use matplotlib with the Agg backend for server-side rendering, converted to interactive HTML via `mpld3.fig_to_html()`.

**Templates:** `Stock/templates/template.html` is the base template (Bootstrap). Feature pages extend it. Stock symbol list is loaded from `Stock/backend/all_symbols.pkl`.

**Database:** SQLite3, used only for Django internals. No custom models.

## Key Technical Notes

- ML operations are stateless — models train on each request, no persistence
- `StockMarket/settings.py` has `DEBUG = True` and a hardcoded `SECRET_KEY`
- `DATA_UPLOAD_MAX_MEMORY_SIZE` is set to 52MB
- Requires Python 3.9+ with TensorFlow 2.13+, Django 4.2
