#!/bin/bash

# Set the store directory
export STORE_DIRECTORY="./data"

# Download BTCUSDT and ETHUSDT spot data (monthly only) with checksum
echo "Downloading BTCUSDT and ETHUSDT spot data..."
python3 download-kline.py -t spot -s BTCUSDT ETHUSDT -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1

# Download BTCUSDT and ETHUSDT perpetual futures data (monthly only) with checksum
echo "Downloading BTCUSDT and ETHUSDT perpetual futures data..."
python3 download-kline.py -t um -s BTCUSDT ETHUSDT -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1

# Download BTCUSDT quarterly futures data (monthly only) with checksum
echo "Downloading BTCUSDT quarterly futures data..."
python3 download-kline.py -t um -s BTCUSDT_210326 BTCUSDT_210625 BTCUSDT_210924 BTCUSDT_211231 BTCUSDT_220325 BTCUSDT_220624 BTCUSDT_220930 BTCUSDT_221230 BTCUSDT_230331 BTCUSDT_230630 BTCUSDT_230929 BTCUSDT_231229 BTCUSDT_240329 BTCUSDT_240628 BTCUSDT_240927 BTCUSDT_241227 BTCUSDT_250328 BTCUSDT_250627 BTCUSDT_250926 -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1

# Download ETHUSDT quarterly futures data (monthly only) with checksum
echo "Downloading ETHUSDT quarterly futures data..."
python3 download-kline.py -t um -s ETHUSDT_210326 ETHUSDT_210625 ETHUSDT_210924 ETHUSDT_211231 ETHUSDT_220325 ETHUSDT_220624 ETHUSDT_220930 ETHUSDT_221230 ETHUSDT_230331 ETHUSDT_230630 ETHUSDT_230929 ETHUSDT_231229 ETHUSDT_240329 ETHUSDT_240628 ETHUSDT_240927 ETHUSDT_241227 ETHUSDT_250328 ETHUSDT_250627 ETHUSDT_250926 -startDate 2020-01-01 -endDate 2025-05-09 -skip-daily 1 -c 1

echo "All downloads completed!" 