import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# ───────────────────────────────────────────────────────────────
# 1)  GLOBAL PARAMETERS
# ───────────────────────────────────────────────────────────────
TOTAL_ENTRIES            = 10_000          # 1 tick = 1 ms (10 s)
INITIAL_CASH             = 10_000

TRADE_INTERVAL_SOFTWARE  = 200
TRADE_INTERVAL_FPGA      = 50
TRADE_THRESHOLD_SOFTWARE = 0.08
TRADE_THRESHOLD_FPGA     = 0.05

SW_MAX_HOLD,  SW_STOP_LOSS   = 100, 0.25
FPGA_MAX_HOLD, FPGA_STOP_LOSS =  50, 0.00

SHORT_WINDOW, LONG_WINDOW = 10, 100

# ───────────────────────────────────────────────────────────────
# 2)  SYNTHETIC PRICE STREAM
# ───────────────────────────────────────────────────────────────
np.random.seed(0)
start_price, end_price = 102.22, 105.48
drift_per_step = (end_price - start_price) / TOTAL_ENTRIES
drift_mult     = 2.0

prices, p = [], start_price
for _ in range(TOTAL_ENTRIES):
    p += np.random.uniform(-0.1, 0.1) + drift_mult * drift_per_step
    prices.append(round(max(p, 0), 2))
prices = np.array(prices)

short_ma = np.convolve(prices, np.ones(SHORT_WINDOW)/SHORT_WINDOW, mode='same')
long_ma  = np.convolve(prices, np.ones(LONG_WINDOW )/LONG_WINDOW , mode='same')

# ───────────────────────────────────────────────────────────────
# 3)  TRADE SIMULATOR
# ───────────────────────────────────────────────────────────────
def get_trade_data(prices, short_ma, long_ma,
                   interval, threshold, max_hold, stop_loss):
    trades, profits = [], []
    cash, position  = INITIAL_CASH, None
    entry_price = 0.0
    entry_i     = 0

    for i in range(len(prices)):
        if i < LONG_WINDOW:
            profits.append(0)
            continue

        # stop‑loss / max‑hold
        if position == 'long':
            hold = i - entry_i
            unreal = prices[i] - entry_price
            if hold >= max_hold or unreal <= -stop_loss:
                cash += unreal
                trades.append((i, prices[i], 'sell'))
                position = None

        # strategy
        if i % interval == 0:
            diff = short_ma[i] - long_ma[i]
            if position is None and diff > threshold:          # entry
                position, entry_price, entry_i = 'long', prices[i], i
                trades.append((i, prices[i], 'buy'))
            elif position == 'long' and diff < -threshold:     # exit
                cash += prices[i] - entry_price
                trades.append((i, prices[i], 'sell'))
                position = None

        unreal = prices[i] - entry_price if position == 'long' else 0
        profits.append(cash - INITIAL_CASH + unreal)

    if position == 'long':                                     # final exit
        cash += prices[-1] - entry_price
        trades.append((len(prices)-1, prices[-1], 'sell'))
        profits[-1] = cash - INITIAL_CASH

    return trades, profits

# 4)  RUN BOTH “ENGINES”
sw_trades, sw_profit = get_trade_data(
    prices, short_ma, long_ma,
    TRADE_INTERVAL_SOFTWARE, TRADE_THRESHOLD_SOFTWARE,
    SW_MAX_HOLD, SW_STOP_LOSS
)

fpga_trades, fpga_profit = get_trade_data(
    prices, short_ma, long_ma,
    TRADE_INTERVAL_FPGA, TRADE_THRESHOLD_FPGA,
    FPGA_MAX_HOLD, FPGA_STOP_LOSS
)

# ───────────────────────────────────────────────────────────────
# 5)  FIGURE / AXES (constrained layout!)
# ───────────────────────────────────────────────────────────────
fig, (ax1, ax2, ax3) = plt.subplots(
        3, 1, figsize=(15, 10), constrained_layout=True
)

# ── subplot 1 : price + markers
line_price, = ax1.plot([], [], color='blue', lw=1, alpha=.7, label='NVDA Price')
sc_sw   = ax1.scatter([], [], color='red',   marker='x', s=90,  label='SW Trade')
sc_fpga = ax1.scatter([], [], color='green', marker='o', s=45,
                      edgecolors='black',     label='FPGA Trade')
ax1.set_xlim(0, TOTAL_ENTRIES)
ax1.set_ylim(min(prices), max(prices))
ax1.set_title("Price Over Time with Trade Markers")
ax1.set_xlabel("Time Index (ms)")
ax1.set_ylabel("Price ($)")
ax1.legend(); ax1.grid(True)

# ── subplot 2 : cumulative profit
line_sw_profit,   = ax2.plot([], [], color='red',   lw=2.5,
                             label='C++ Software Profit')
line_fpga_profit, = ax2.plot([], [], color='green', lw=2.5,
                             label='FPGA Profit')
ax2.set_xlim(0, TOTAL_ENTRIES)
ax2.set_ylim(-50, 150)
ax2.set_title("Cumulative Profit Over Time")
ax2.set_xlabel("Time Index (ms)")
ax2.set_ylabel("Profit ($)")
ax2.legend(loc='upper center'); ax2.grid(True)

sw_text   = ax2.text(0.01, 0.95, '', transform=ax2.transAxes,
                     va='top', color='red',   fontweight='bold')
fpga_text = ax2.text(0.99, 0.95, '', transform=ax2.transAxes,
                     va='top', ha='right', color='green', fontweight='bold')

# ── subplot 3 : latency / power / trades‑per‑s
elapsed_seconds   = TOTAL_ENTRIES / 1_000
sw_tps = len(sw_trades)   / elapsed_seconds
fpga_tps = len(fpga_trades) / elapsed_seconds

labels      = ['Latency (μs)', 'Power (W)', 'Trades/sec']
sw_values   = [200, 20,   sw_tps]
fpga_values = [0.008, 0.15, fpga_tps]

x = np.arange(len(labels))
ax3.bar(x - 0.2, sw_values,   0.4, label='C++ Software', color='red')
ax3.bar(x + 0.2, fpga_values, 0.4, label='FPGA',         color='green')
ax3.set_xticks(x); ax3.set_xticklabels(labels)
ax3.set_yscale('log')
ax3.set_ylabel('Metric Value (Log Scale)')
ax3.set_title('Latency, Power, and Trade Rate Comparison (current run)')
ax3.legend(); ax3.grid(True, axis='y')

# ───────────────────────────────────────────────────────────────
# 6)  ANIMATION CALLBACK
# ───────────────────────────────────────────────────────────────
def update(frame):
    x_vals = np.arange(frame)

    line_price.set_data(x_vals, prices[:frame])

    sw_x = [i for i, _, _ in sw_trades   if i < frame]
    sc_sw.set_offsets(np.c_[sw_x, [prices[i] for i in sw_x]])

    fpga_x = [i for i, _, _ in fpga_trades if i < frame]
    sc_fpga.set_offsets(np.c_[fpga_x, [prices[i] for i in fpga_x]])

    line_sw_profit.set_data(x_vals,   sw_profit[:frame])
    line_fpga_profit.set_data(x_vals, fpga_profit[:frame])

    sw_text.set_text(
        f"SW Profit: ${sw_profit[frame]:.2f}\nTrades: "
        f"{sum(1 for i,_,_ in sw_trades if i < frame)}"
    )
    fpga_text.set_text(
        f"FPGA Profit: ${fpga_profit[frame]:.2f}\nTrades: "
        f"{sum(1 for i,_,_ in fpga_trades if i < frame)}"
    )
    return (line_price, sc_sw, sc_fpga,
            line_sw_profit, line_fpga_profit, sw_text, fpga_text)

# ───────────────────────────────────────────────────────────────
# 7)  RUN ANIMATION
# ───────────────────────────────────────────────────────────────
ani = FuncAnimation(
    fig, update,
    frames=range(LONG_WINDOW, TOTAL_ENTRIES, 50),
    interval=10, blit=False, repeat=True
)

plt.show()
