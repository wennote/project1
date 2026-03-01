import sys
print(sys.executable)
import yfinance as yf

sp500 = yf.download("^GSPC", period="1mo")
sp500.head()