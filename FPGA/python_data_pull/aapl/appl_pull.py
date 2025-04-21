import random

TOTAL_ENTRIES = 12000  # 12,000 entries for mock data

# Generate synthetic AAPL-like floating-point prices around $175
price = 175.00
prices = []

for _ in range(TOTAL_ENTRIES):
    # Simulate small price movements (+/- 0.10)
    price += random.uniform(-0.1, 0.1)
    price = max(price, 0)  # Prevent negative prices
    prices.append(round(price, 2))  # Round to 2 decimal places

# Save to a plain text file with each price on a new line
txt_path = "aapl_prices_12000.txt"
with open(txt_path, "w") as f:
    for p in prices:
        f.write(f"{p}\n")

txt_path