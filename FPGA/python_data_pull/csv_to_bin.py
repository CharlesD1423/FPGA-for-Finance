import pandas as pd
import struct

# Load CSV while skipping the first two rows
csv_file = "BTC-USD_historical_data.csv"
df = pd.read_csv(csv_file, skiprows=2)

# Rename columns properly
df.columns = ["Datetime", "Close", "High", "Low", "Open", "Volume"]

# Convert "Datetime" to UNIX timestamp
df["Datetime"] = pd.to_datetime(df["Datetime"]).astype(int) // 10**9

# Define binary file format (float32 for each value)
bin_file = "market_data.bin"

# Open binary file for writing
with open(bin_file, "wb") as f:
    for _, row in df.iterrows():
        timestamp = float(row["Datetime"])
        open_price = float(row["Open"])
        high_price = float(row["High"])
        low_price = float(row["Low"])
        close_price = float(row["Close"])
        volume = float(row["Volume"])

        # Pack as 6 floating-point numbers (each 4 bytes)
        f.write(struct.pack("f f f f f f", timestamp, open_price, high_price, low_price, close_price, volume))

print(f"Binary data saved to {bin_file}")
