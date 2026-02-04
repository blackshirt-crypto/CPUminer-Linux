# CPUminer-opt for Linux Desktop

Universal multi-algorithm CPU miner setup for Linux desktop and server systems. Mine dozens of different cryptocurrencies with a single installation!

## 🖥️ Requirements

- Linux system (Ubuntu, Debian, Fedora, Arch, or derivatives)
- x86_64 CPU (Intel or AMD)
- Sudo/root access for dependency installation
- Stable internet connection
- At least 2GB free storage space
- Wallet address for the coin you want to mine

## ⚡ Quick Start

### 1. Download and Run Setup Script

Open a terminal and run these commands:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/scratcher14/cpuminer-opt-desktop/main/setup_cpuminer.sh

# Make it executable
chmod +x setup_cpuminer.sh

# Run the setup (will ask for sudo password for dependencies)
./setup_cpuminer.sh
```

The script will automatically:
- Detect your Linux distribution and package manager
- Install all required dependencies
- Build cpuminer-opt optimized for your CPU
- Guide you through configuration

### 2. Configure During Setup

The interactive setup will prompt you for:
- **Algorithm**: Which coin/algorithm to mine (see supported list below)
- **Primary Pool**: Main mining pool address
- **Backup Pool**: Optional secondary pool for failover
- **Wallet Address**: Your wallet address for the chosen coin
- **Worker Name**: Identifier for this device (e.g., `desktop-1`, `server-main`)
- **Pool Password**: Usually `x` (pool-specific)
- **Threads**: CPU threads to use (recommended: 50-75% of available cores)

### 3. Start Mining

After setup completes:

```bash
cd ~/cpuminer-opt
./start.sh
```

## 🔄 Switching Coins/Algorithms

**No need to reinstall!** Use the built-in reconfiguration tool:

```bash
cd ~/cpuminer-opt
./reconfigure.sh
```

This allows you to:
- Switch to a different coin/algorithm
- Change mining pools
- Update wallet address and worker name
- Adjust thread count
- Reconfigure everything or just specific settings

## 🎯 Supported Algorithms

CPUminer-opt supports **50+ algorithms**. Here are the most popular:

### Popular Algorithms
- **scrypt** - Dogecoin (DOGE), Litecoin (LTC), Verge (XVG)
- **yespower** - YespowerSugar coins
- **yescryptr16** - Fennec (FNNC), YTN, SUGAR
- **yescryptr32** - Wavi (WAVI)
- **yespowerurx** - Uranium-X (URX)
- **sha256d** - Bitcoin-style coins
- **sha256t** - Various SHA256-based coins
- **lyra2z** - Zcoin forks
- **power2b** - MicroBitcoin (MBC)

### Full Algorithm List
- allium, anime, argon2, argon2d250, argon2d500, argon2d4096
- axiom, blake, blake2b, blake2s, bmw, bmw512
- c11, cpupower, cryptonight variants
- decred, dmd-gr, groestl
- hmq1725, hodl, jha
- keccak, keccakc, lbry
- luffa, lyra2h, lyra2re, lyra2rev2, lyra2rev3, lyra2z, lyra2z330
- m7m, minotaur, minotaurx, myr-gr
- neoscrypt, nist5, pentablake
- phi1612, phi2, polytimos, power2b
- quark, qubit
- scrypt, scrypt:N, scryptn2
- sha256d, sha256q, sha256t
- shavite3, skein, skein2, sonoa
- timetravel, timetravel10, tribus, vanilla, veltor
- x11, x11evo, x11gost, x12, x13, x14, x15
- x16r, x16rv2, x16rt, x16s, x17
- x20r, x21s, x22i, x25x, xevan
- yescrypt, yescryptr8, yescryptr16, yescryptr24, yescryptr32
- yespower, yespowerr16, yespowerurx, yespowerltncg, yespoweric, yespowersugar
- zr5

**To see the complete current list with descriptions:**
```bash
cd ~/cpuminer-opt
./cpuminer --help
```

## 🌐 Finding Mining Pools

### Pool Aggregator Sites
Find pools for any coin and algorithm:

- **[Mining Pool Stats](https://miningpoolstats.stream/)** - Comprehensive pool listings by coin
- **[MinerStat](https://minerstat.com/mining-pools)** - Pool comparison and statistics
- **[CoinWarz](https://www.coinwarz.com/mining/pools)** - Mining pool directory
- **[Pool.watch](https://pool.watch/)** - Multi-coin pool monitor
- **[WhatToMine](https://whattomine.com/)** - Profitability calculator with pool links

### Finding Pools for Your Coin
1. Visit Mining Pool Stats and search for your coin
2. Compare pool fees, hashrate, and minimum payout
3. Check pool website for connection details
4. Look for pools with good uptime and active miners

### Example Pool Formats
When entering pool addresses during setup:
- Format: `pool-address.com:port`
- Example: `mine.fennecblockchain.com:3032`
- Example: `pool.woolypooly.com:3094` (for Dogecoin)

## 🛠️ Managing Your Miner

### View Current Configuration
```bash
cd ~/cpuminer-opt
./info.sh
```

### Start Mining (Primary Pool)
```bash
cd ~/cpuminer-opt
./start.sh
```

### Start Mining (Backup Pool)
```bash
cd ~/cpuminer-opt
./start-backup.sh
```

### Stop Mining
Press `Ctrl + C` in the terminal window

### Reconfigure Everything
```bash
cd ~/cpuminer-opt
./reconfigure.sh
```

### Run Mining in Background (Screen)
To keep mining when closing terminal:
```bash
# Install screen if not already installed
sudo apt install screen  # Ubuntu/Debian
sudo dnf install screen  # Fedora
sudo pacman -S screen    # Arch

# Start a screen session
screen -S mining

# Start mining
cd ~/cpuminer-opt && ./start.sh

# Detach from screen: Press Ctrl+A then D
# Reattach later with: screen -r mining
```

### Run Mining in Background (tmux)
Alternative to screen:
```bash
# Install tmux
sudo apt install tmux  # Ubuntu/Debian

# Start tmux session
tmux new -s mining

# Start mining
cd ~/cpuminer-opt && ./start.sh

# Detach: Press Ctrl+B then D
# Reattach: tmux attach -t mining
```

### Create Systemd Service (Auto-start on Boot)
```bash
# Create service file
sudo nano /etc/systemd/system/cpuminer.service
```

Add this content (replace USERNAME with your actual username):
```ini
[Unit]
Description=CPUminer-opt Mining Service
After=network.target

[Service]
Type=simple
User=USERNAME
WorkingDirectory=/home/USERNAME/cpuminer-opt
ExecStart=/home/USERNAME/cpuminer-opt/start.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable cpuminer.service
sudo systemctl start cpuminer.service

# Check status
sudo systemctl status cpuminer.service

# View logs
journalctl -u cpuminer.service -f
```

## 📊 Recommended Settings

### Thread Count by CPU
- **Dual-core** (2-4 threads): 2-3 threads
- **Quad-core** (4 threads): 3-4 threads
- **6-core** (6-12 threads): 4-8 threads
- **8-core** (8-16 threads): 6-12 threads
- **High-end** (16+ threads): 12-24 threads

**General rule**: Use 50-75% of available threads for best balance of performance and system responsiveness.

### CPU Architecture Optimizations
The setup script automatically detects and optimizes for:
- **AVX2** - Modern Intel/AMD CPUs (2013+)
- **AVX** - Intel Sandy Bridge+ / AMD Bulldozer+
- **SSE4.2** - Older CPUs
- **Generic** - Fallback for older architectures

### Algorithm Performance Notes
- **Scrypt-based**: CPU-intensive, higher power usage
- **SHA256d**: Lower power consumption, good for 24/7
- **Yespower variants**: Balanced CPU usage, efficient
- **X16 variants**: Higher CPU usage, more heat

### Choosing What to Mine
Consider:
- Current coin price and volume
- Pool fees and minimum payout
- Network difficulty
- Your electricity costs
- CPU cooling capabilities
- Power consumption vs. potential earnings

## ⚠️ Important Notes

### Temperature & Power Management

**Monitor CPU Temperature:**
```bash
# Install monitoring tools
sudo apt install lm-sensors htop  # Ubuntu/Debian

# Detect sensors
sudo sensors-detect

# Check temperature
sensors

# Monitor in real-time
watch -n 2 sensors
```

**Keep CPU Cool:**
- Ensure proper case ventilation
- Clean dust from heatsinks/fans regularly
- Consider upgrading CPU cooler if mining 24/7
- Stop mining if CPU exceeds 80°C
- Modern CPUs throttle at 95-100°C

**Power Consumption:**
- Mining uses significant electricity
- Calculate costs: [Your Wattage] × [Hours] × [kWh Rate]
- Consider electricity costs vs. mining rewards
- Use a Kill-A-Watt meter to measure actual power draw

### Performance Tips
- Close unnecessary applications while mining
- Disable CPU power-saving features in BIOS for consistent hashrate
- Use `htop` or `top` to monitor CPU usage
- Consider undervolting CPU to reduce heat/power
- Ensure adequate PSU capacity for sustained load
- Monitor pool stats on pool website regularly

### Mining Strategy
- Test different algorithms to find best performance
- Switch between coins based on profitability
- Join pool Discord/Telegram for support
- Keep coins in exchange-ready wallet for selling
- Use profit-switching calculators

### Security Considerations
- Never run as root (security risk)
- Only download from trusted sources
- Verify pool addresses before mining
- Use dedicated wallet for mining (not main storage)
- Monitor system for unusual activity

## 🔧 Troubleshooting

### Build Fails

**Missing Dependencies:**
```bash
# Ubuntu/Debian
sudo apt-get install build-essential automake autoconf pkg-config \
    libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev

# Fedora/RHEL
sudo dnf install gcc gcc-c++ make automake autoconf pkgconfig \
    libcurl-devel jansson-devel openssl-devel gmp-devel zlib-devel

# Arch Linux
sudo pacman -S base-devel automake autoconf pkgconf \
    curl jansson openssl gmp zlib
```

**Compilation Errors:**
- Ensure you have enough storage (2GB+ free)
- Update your system: `sudo apt update && sudo apt upgrade`
- Try without optimization: `./configure CFLAGS="-O2" --with-curl`

### Low Hashrate
- Reduce thread count if CPU is thermal throttling
- Check CPU temperature with `sensors`
- Close background applications
- Ensure CPU isn't power-throttling (check power settings)
- Try different algorithm (some perform better on certain CPUs)

### Miner Won't Start
- Verify pool address format (address:port)
- Check if pool is online (visit pool website)
- Ensure wallet address is correct format for chosen coin
- Try backup pool if primary is down
- Run `./info.sh` to verify configuration
- Check firewall: `sudo ufw status` (allow outbound connections)

### Connection Issues
- Verify pool URL is correct
- Test network: `ping pool-address.com`
- Check firewall isn't blocking mining port
- Try different pool from the same coin
- Some pools require worker password - check pool docs
- Verify DNS resolution: `nslookup pool-address.com`

### System Freezing/Crashing
- Reduce thread count significantly
- Check CPU temperature (likely overheating)
- Ensure adequate RAM (mining uses ~100-500MB)
- Check system logs: `journalctl -xe`
- Test with single thread first: `-t 1`

### Switching Coins Not Working
- Run `./reconfigure.sh` to properly update config
- Verify new wallet address matches new coin
- Check that pool supports the algorithm you selected
- Restart after reconfiguration if issues persist
- Delete `mining-config.txt` and run setup again if corrupted

## 📁 File Structure

```
~/cpuminer-opt/
├── cpuminer              # Main miner executable
├── start.sh              # Start mining (primary pool)
├── start-backup.sh       # Start mining (backup pool)
├── reconfigure.sh        # Change coins/settings easily
├── info.sh               # View current configuration
├── mining-config.txt     # Saved configuration
└── create-info.sh        # Helper script
```

## 🔄 Updating CPUminer-opt

To update to the latest version:

```bash
cd ~/cpuminer-opt
git pull
make clean
./autogen.sh

# Rebuild with optimizations
if grep -q "avx2" /proc/cpuinfo; then
    ./configure CFLAGS="-O3 -march=native -mtune=native" --with-curl
else
    ./configure CFLAGS="-O3" --with-curl
fi

make -j$(nproc)
```

Note: After updating, run `./reconfigure.sh` to restore your settings.

## 💡 Tips & Tricks

### Managing Multiple Coins (Advanced)

Create separate start scripts for coins you mine regularly:

```bash
cd ~/cpuminer-opt

# Create start script for Monero (XMR)
nano startxmr.sh
```

Add this content (customize for your setup):
```bash
#!/bin/bash
cd ~/cpuminer-opt

echo "Starting Monero (XMR) Mining..."
./cpuminer -a randomx \
  -o stratum+tcp://pool.supportxmr.com:3333 \
  -u YOUR_XMR_WALLET.desktop1 \
  -p x \
  -t 12
```

```bash
chmod +x startxmr.sh

# Now you can quickly switch:
./startxmr.sh  # Mine Monero
# Ctrl+C to stop, then:
./startdoge.sh  # Mine Dogecoin (if you created this script)
```

### Create Bash Aliases for Quick Mining

Add to your `~/.bashrc`:
```bash
alias minexmr='cd ~/cpuminer-opt && ./startxmr.sh'
alias minedoge='cd ~/cpuminer-opt && ./startdoge.sh'
alias mineinfo='cd ~/cpuminer-opt && ./info.sh'
alias minestop='pkill cpuminer'
```

Reload: `source ~/.bashrc`

Now just type: `minexmr` to start mining!

### Temperature Monitoring Script

Create a temperature monitor that stops mining if too hot:

```bash
nano ~/cpuminer-opt/temp-monitor.sh
```

```bash
#!/bin/bash
MAX_TEMP=80  # Maximum temperature in Celsius

while true; do
    TEMP=$(sensors | grep 'Core 0' | awk '{print $3}' | tr -d '+°C')
    if (( $(echo "$TEMP > $MAX_TEMP" | bc -l) )); then
        echo "Temperature $TEMP°C exceeds $MAX_TEMP°C! Stopping miner..."
        pkill cpuminer
        exit 1
    fi
    sleep 30
done
```

Run in background: `chmod +x temp-monitor.sh && ./temp-monitor.sh &`

### Profitability Calculation

Calculate your mining profitability:

```bash
# Find your hashrate from cpuminer output
# Calculate daily earnings:
# [Your Hashrate] × [Coin Block Reward] × [Blocks Per Day] / [Network Hashrate]

# Example for 1 MH/s on Dogecoin:
# ~10,000 DOGE block reward × 1440 blocks/day = 14,400,000 DOGE/day network-wide
# Your share = (1 MH/s / Network Hashrate) × 14,400,000
```

Use online calculators like WhatToMine for accurate estimates.

### Optimizing for Different CPUs

**Intel CPUs:**
- Newer generations (10th+) perform well on all algorithms
- Older i5/i7: Focus on scrypt/yespower variants
- Xeon servers: Great for 24/7 mining

**AMD CPUs:**
- Ryzen 5000/7000 series: Excellent for RandomX (Monero)
- Threadripper: Unmatched thread count for algorithms like yescrypt
- Older FX series: Stick to simpler algorithms like sha256d

### Multi-Machine Mining Fleet

If you have multiple computers:

1. Use different worker names: `desktop-1`, `laptop-1`, `server-1`
2. Monitor all workers on pool website
3. Centralize configuration with git repository
4. Use SSH to manage remote miners
5. Consider mining different coins on different machines

### Benchmarking

Test performance of different algorithms:

```bash
cd ~/cpuminer-opt

# Benchmark an algorithm
./cpuminer -a scrypt --benchmark

# Compare multiple algorithms
for algo in scrypt sha256d yescryptr16; do
    echo "Testing $algo..."
    timeout 60 ./cpuminer -a $algo --benchmark
done
```

## 🆘 Support & Resources

- **Cell Hasher**: [https://cellhasher.com/](https://cellhasher.com/) - Mobile/desktop mining community
- **VaultFarm YouTube**: [Tutorial videos](https://youtube.com/@vaultfarm?si=CY_Vt_PhnMqvhx8P)
- **CPUminer-opt Repository**: [JayDDee/cpuminer-opt](https://github.com/JayDDee/cpuminer-opt)
- **Mining Pool Stats**: [Find pools](https://miningpoolstats.stream/)
- **Reddit**: r/gpumining, r/CryptoCurrency (search for CPU mining threads)

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor your CPU temperature and system health regularly. 

This setup is for educational purposes and hobby mining. Mining profitability varies greatly based on:
- Hardware capabilities
- Electricity costs
- Market conditions
- Chosen coin and network difficulty

**Important**: Always calculate electricity costs vs. potential earnings. Desktop CPU mining is rarely highly profitable compared to ASIC or GPU mining, but can be:
- A learning experience about cryptocurrency
- A way to earn small amounts of various coins
- Fun for crypto enthusiasts
- Profitable during coin launches or with renewable energy

**Never** leave mining systems unattended for long periods without proper temperature monitoring and cooling.

## 📝 Supported Distributions

This setup script has been tested on:
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Linux Mint 20, 21
- Fedora 38, 39, 40
- CentOS Stream 9
- Arch Linux (latest)
- Manjaro (latest)
- Pop!_OS 22.04

Should work on any modern Linux distribution with apt, dnf, yum, or pacman.

## 📄 License

This setup script is provided as-is for the mining community. CPUminer-opt is open source - check the [original repository](https://github.com/JayDDee/cpuminer-opt) for license details.

---

**Happy Mining! ⛏️ Remember: Use ./reconfigure.sh to easily switch between coins!**

*Desktop edition - Optimized for x86_64 Linux systems*
