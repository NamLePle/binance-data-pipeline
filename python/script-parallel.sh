#!/bin/bash

# Set the store directory
export STORE_DIRECTORY="./data"

# Create logs directory if it doesn't exist
mkdir -p ./logs

# Define log file with timestamp
LOG_FILE="./logs/download_$(date +%Y%m%d_%H%M%S).log"
echo "Starting download process at $(date). Logging to $LOG_FILE" | tee -a $LOG_FILE

# Check if GNU Parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "GNU Parallel is not installed. Please install it first." | tee -a $LOG_FILE
    echo "On Ubuntu/Debian: sudo apt-get install parallel" | tee -a $LOG_FILE
    echo "On macOS with Homebrew: brew install parallel" | tee -a $LOG_FILE
    exit 1
fi

# Number of parallel processes to run (total cores minus 4)
TOTAL_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 8)
NUM_CORES=$((TOTAL_CORES - 4))

# Ensure at least 1 core is used
if [ $NUM_CORES -lt 1 ]; then
    NUM_CORES=1
fi

echo "Total CPU cores: $TOTAL_CORES, using $NUM_CORES cores for downloads (reserving 4 cores for system)" | tee -a $LOG_FILE

# Create temporary files to store download commands
SPOT_COMMANDS=$(mktemp)
PERP_COMMANDS=$(mktemp)
BTC_QUARTERLY_COMMANDS=$(mktemp)
ETH_QUARTERLY_COMMANDS=$(mktemp)

# Create download commands for BTCUSDT and ETHUSDT spot data (1h interval only)
echo "python3 download-kline.py -t spot -s BTCUSDT -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" > $SPOT_COMMANDS
echo "python3 download-kline.py -t spot -s ETHUSDT -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" >> $SPOT_COMMANDS

# Create download commands for BTCUSDT and ETHUSDT perpetual futures (1h interval only)
echo "python3 download-kline.py -t um -s BTCUSDT -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" > $PERP_COMMANDS
echo "python3 download-kline.py -t um -s ETHUSDT -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" >> $PERP_COMMANDS

# BTC quarterly futures - split into multiple commands for parallel processing (1h interval only)
BTC_QUARTERLY=(
    "BTCUSDT_210326" "BTCUSDT_210625" "BTCUSDT_210924" "BTCUSDT_211231"
    "BTCUSDT_220325" "BTCUSDT_220624" "BTCUSDT_220930" "BTCUSDT_221230"
    "BTCUSDT_230331" "BTCUSDT_230630" "BTCUSDT_230929" "BTCUSDT_231229"
    "BTCUSDT_240329" "BTCUSDT_240628" "BTCUSDT_240927" "BTCUSDT_241227"
    "BTCUSDT_250328" "BTCUSDT_250627" "BTCUSDT_250926"
)

for symbol in "${BTC_QUARTERLY[@]}"; do
    echo "python3 download-kline.py -t um -s $symbol -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" >> $BTC_QUARTERLY_COMMANDS
done

# ETH quarterly futures - split into multiple commands for parallel processing (1h interval only)
ETH_QUARTERLY=(
    "ETHUSDT_210326" "ETHUSDT_210625" "ETHUSDT_210924" "ETHUSDT_211231"
    "ETHUSDT_220325" "ETHUSDT_220624" "ETHUSDT_220930" "ETHUSDT_221230"
    "ETHUSDT_230331" "ETHUSDT_230630" "ETHUSDT_230929" "ETHUSDT_231229"
    "ETHUSDT_240329" "ETHUSDT_240628" "ETHUSDT_240927" "ETHUSDT_241227"
    "ETHUSDT_250328" "ETHUSDT_250627" "ETHUSDT_250926"
)

for symbol in "${ETH_QUARTERLY[@]}"; do
    echo "python3 download-kline.py -t um -s $symbol -i 1h -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1" >> $ETH_QUARTERLY_COMMANDS
done

# Log the commands that will be executed
echo "Commands to be executed:" | tee -a $LOG_FILE
echo "Spot commands ($(wc -l < $SPOT_COMMANDS) commands):" | tee -a $LOG_FILE
cat $SPOT_COMMANDS | tee -a $LOG_FILE
echo "Perpetual futures commands ($(wc -l < $PERP_COMMANDS) commands):" | tee -a $LOG_FILE
cat $PERP_COMMANDS | tee -a $LOG_FILE
echo "BTC quarterly commands ($(wc -l < $BTC_QUARTERLY_COMMANDS) commands):" | tee -a $LOG_FILE
cat $BTC_QUARTERLY_COMMANDS | tee -a $LOG_FILE
echo "ETH quarterly commands ($(wc -l < $ETH_QUARTERLY_COMMANDS) commands):" | tee -a $LOG_FILE
cat $ETH_QUARTERLY_COMMANDS | tee -a $LOG_FILE

# Run all commands in parallel with a progress bar and log output
echo "Starting parallel downloads..." | tee -a $LOG_FILE
cat $SPOT_COMMANDS $PERP_COMMANDS $BTC_QUARTERLY_COMMANDS $ETH_QUARTERLY_COMMANDS | parallel --bar -j $NUM_CORES "echo 'Running: {}' >> $LOG_FILE; {} 2>&1 | tee -a $LOG_FILE"

# Clean up temporary files
rm $SPOT_COMMANDS $PERP_COMMANDS $BTC_QUARTERLY_COMMANDS $ETH_QUARTERLY_COMMANDS

echo "All downloads completed at $(date)!" | tee -a $LOG_FILE
echo "Log file saved to: $LOG_FILE" 