import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt

# Download 5 years of S&P 500 data
sp500 = yf.download("^GSPC", period="5y")

# Calculate moving averages
sp500['MA50'] = sp500['Close'].rolling(window=50).mean()
sp500['MA200'] = sp500['Close'].rolling(window=200).mean()

# Detect Golden Cross
sp500['Signal'] = 0
sp500.loc[sp500['MA50'] > sp500['MA200'], 'Signal'] = 1
sp500['GoldenCross'] = sp500['Signal'].diff()

# Print Golden Cross dates
golden_cross_dates = sp500[sp500['GoldenCross'] == 1]
print("Golden Cross Dates:")
print(golden_cross_dates.index)

# Plot
plt.figure(figsize=(12,6))
plt.plot(sp500.index, sp500['Close'], label='S&P 500 Close', alpha=0.5)
plt.plot(sp500.index, sp500['MA50'], label='50-day MA', color='blue')
plt.plot(sp500.index, sp500['MA200'], label='200-day MA', color='red')

# Mark Golden Cross points
plt.scatter(golden_cross_dates.index,
            golden_cross_dates['Close'],
            marker='^',
            color='green',
            s=100,
            label='Golden Cross')

plt.title('S&P 500 Golden Cross Example')
plt.legend()
plt.grid()
plt.show()