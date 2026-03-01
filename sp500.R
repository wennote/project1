library(quantmod)
library(TTR)

# Download data
getSymbols("^GSPC", from="2020-01-01")

# Calculate moving averages
MA50 <- SMA(Cl(GSPC), 50)
MA200 <- SMA(Cl(GSPC), 200)

# Plot
plot(Cl(GSPC), main="S&P 500 Golden Cross Example")
lines(MA50, col="blue")
lines(MA200, col="red")

legend("topleft",
       legend=c("Close","MA50","MA200"),
       col=c("black","blue","red"),
       lty=1)
png("sp500_plot.png", width=1000, height=600)

plot(Cl(GSPC))
lines(MA50, col="blue")
lines(MA200, col="red")

dev.off()