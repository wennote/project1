import yfinance as yf
import pandas as pd

# Download last 10 years of S&P 500 data
sp500 = yf.download("^GSPC", period="10y")

# Keep only Date and Close columns
sp500_close = sp500[['Close']].reset_index()

# Save to CSV formatted for R
filename = "sp500_10yr_close.csv"
sp500_close.to_csv(filename, index=False)

print(f"File saved as {filename}")
print(sp500_close.head())
