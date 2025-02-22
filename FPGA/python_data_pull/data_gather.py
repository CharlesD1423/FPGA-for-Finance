import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta

# Define the asset/ticker you want (examples: "AAPL" for Apple, "BTC-USD" for Bitcoin)
TICKER = "BTC-USD"  # Change this to other assets like "ETH-USD", "AAPL", etc.

# Define time range (yesterday afternoon)
yesterday = datetime.today() - timedelta(days=1)
start_time = yesterday.replace(hour=12, minute=0, second=0).strftime("%Y-%m-%d %H:%M:%S")
end_time = yesterday.replace(hour=18, minute=0, second=0).strftime("%Y-%m-%d %H:%M:%S")

# Fetch historical data
data = yf.download(TICKER, start=yesterday.strftime("%Y-%m-%d"), interval="5m")  # 5-minute intervals

# Filter for afternoon data
data = data.between_time("12:00", "18:00")

# Save to CSV
output_file = f"{TICKER}_historical_data.csv"
data.to_csv(output_file)

print(f"Historical data saved to {output_file}")
