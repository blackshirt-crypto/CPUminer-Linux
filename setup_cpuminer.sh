#!/bin/bash

#########################################
# Universal cpuminer-opt Setup for Linux Desktop
# Supports: Scrypt, Yespower, YescryptR16, and more
# Fully customizable for any coin/algorithm
#########################################

echo "========================================="
echo "  Universal cpuminer-opt Setup"
echo "  Multi-Algorithm CPU Mining (Desktop)"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Error: Please do not run this script as root/sudo"
    echo "The script will request sudo when needed"
    exit 1
fi

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo "Error: Unsupported package manager"
    echo "This script supports apt, dnf, yum, and pacman"
    exit 1
fi

# Step 1: Update system
echo "[1/5] Updating system packages..."
case $PKG_MANAGER in
    apt)
        sudo apt-get update
        ;;
    dnf)
        sudo dnf check-update || true
        ;;
    yum)
        sudo yum check-update || true
        ;;
    pacman)
        sudo pacman -Sy
        ;;
esac

# Step 2: Install dependencies
echo ""
echo "[2/5] Installing dependencies..."
case $PKG_MANAGER in
    apt)
        sudo apt-get install -y git build-essential automake autoconf pkg-config \
            libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev
        ;;
    dnf)
        sudo dnf install -y git gcc gcc-c++ make automake autoconf pkgconfig \
            libcurl-devel jansson-devel openssl-devel gmp-devel zlib-devel
        ;;
    yum)
        sudo yum install -y git gcc gcc-c++ make automake autoconf pkgconfig \
            libcurl-devel jansson-devel openssl-devel gmp-devel zlib-devel
        ;;
    pacman)
        sudo pacman -S --noconfirm git base-devel automake autoconf pkgconf \
            curl jansson openssl gmp zlib
        ;;
esac

# Step 3: Clone cpuminer-opt
echo ""
echo "[3/5] Cloning cpuminer-opt repository..."
cd ~
if [ -d "cpuminer-opt" ]; then
    echo "Removing old cpuminer-opt directory..."
    rm -rf cpuminer-opt
fi

git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt

# Step 4: Build cpuminer-opt
echo ""
echo "[4/5] Building cpuminer-opt for your CPU..."
echo "This may take 5-15 minutes depending on your CPU..."
echo ""

./autogen.sh

# Detect CPU architecture and optimize
if grep -q "avx2" /proc/cpuinfo; then
    echo "AVX2 support detected - building with optimizations"
    ./configure CFLAGS="-O3 -march=native -mtune=native" --with-curl
elif grep -q "avx" /proc/cpuinfo; then
    echo "AVX support detected - building with optimizations"
    ./configure CFLAGS="-O3 -march=native -mtune=native" --with-curl
elif grep -q "sse4_2" /proc/cpuinfo; then
    echo "SSE4.2 support detected - building with optimizations"
    ./configure CFLAGS="-O3 -march=native -mtune=native" --with-curl
else
    echo "Building with standard optimizations"
    ./configure CFLAGS="-O3" --with-curl
fi

make -j$(nproc)

# Check if build was successful
if [ -f "cpuminer" ]; then
    echo ""
    echo "✓ Build successful!"
else
    echo ""
    echo "✗ Build failed. Check errors above."
    echo "You may need to install additional dependencies."
    exit 1
fi

# Step 5: Interactive configuration
echo ""
echo "[5/5] Configuring mining parameters..."
echo ""
echo "========================================="
echo "  Algorithm Configuration"
echo "========================================="
echo ""
echo "Supported algorithms (examples):"
echo "  • scrypt - Dogecoin, Litecoin, etc."
echo "  • yespower - YespowerSugar, etc."
echo "  • yescryptr16 - Fennec (FNNC)"
echo "  • yescryptr32 - Wavi, etc."
echo "  • yespowerurx - URX"
echo "  • sha256d - Bitcoin-style coins"
echo "  • sha256t - Various coins"
echo ""
echo "Full list: Run ./cpuminer --help to see all algorithms"
echo ""
read -p "Enter algorithm to mine: " ALGO

echo ""
echo "========================================="
echo "  Primary Pool Configuration"
echo "========================================="
echo ""
echo "Enter primary pool address"
echo "Format: pool-address.com:port"
echo "Example: mine.fennecblockchain.com:3032"
echo ""
read -p "Primary pool address: " PRIMARY_POOL_INPUT
PRIMARY_POOL="stratum+tcp://$PRIMARY_POOL_INPUT"

echo ""
echo "========================================="
echo "  Backup Pool Configuration (Optional)"
echo "========================================="
echo ""
read -p "Do you want to add a backup/secondary pool? (y/n): " ADD_BACKUP

if [[ "$ADD_BACKUP" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Enter backup pool address"
    echo "Format: pool-address.com:port"
    echo ""
    read -p "Backup pool address: " BACKUP_POOL_INPUT
    BACKUP_POOL="stratum+tcp://$BACKUP_POOL_INPUT"
    HAS_BACKUP=true
    echo ""
    echo "✓ Backup pool configured: $BACKUP_POOL_INPUT"
else
    HAS_BACKUP=false
    BACKUP_POOL="None"
    echo ""
    echo "✓ No backup pool - using primary only"
fi

echo ""
echo "========================================="
echo "  Wallet Configuration"
echo "========================================="
echo ""
echo "Enter your wallet address for this coin"
echo "Example: FQyFJKLMNoPqRsTuVwXyZ... (for Fennec)"
echo ""
read -p "Wallet address: " WALLET_ADDRESS

echo ""
echo "========================================="
echo "  Worker Configuration"
echo "========================================="
echo ""
echo "Worker name helps identify this device"
echo "Examples: desktop-1, laptop-main, server-01"
echo ""
read -p "Worker name: " WORKER_NAME

echo ""
echo "========================================="
echo "  Password Configuration"
echo "========================================="
echo ""
echo "Most pools use 'x' as password"
echo "Some pools may require specific format"
echo ""
read -p "Pool password (default: x): " POOL_PASSWORD
POOL_PASSWORD=${POOL_PASSWORD:-x}

echo ""
echo "========================================="
echo "  Thread Configuration"
echo "========================================="
echo ""
CPU_CORES=$(nproc)
echo "Your system has $CPU_CORES CPU threads available"
echo "More threads = higher hash rate but more power/heat"
echo "Recommended: Use 50-75% of available threads"
RECOMMENDED=$((CPU_CORES * 3 / 4))
echo "Recommended for your system: $RECOMMENDED threads"
echo "Use 'auto' to let cpuminer decide"
echo ""
read -p "Number of threads (default: $RECOMMENDED): " THREADS
THREADS=${THREADS:-$RECOMMENDED}

# Create start.sh for primary pool
echo ""
echo "Creating mining scripts..."

cat > start.sh << EOF
#!/bin/bash
cd ~/cpuminer-opt

echo "========================================="
echo "  Starting cpuminer-opt"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $PRIMARY_POOL_INPUT"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF

chmod +x start.sh

# Create backup pool script if configured
if [ "$HAS_BACKUP" = true ]; then
    cat > start-backup.sh << EOF
#!/bin/bash
cd ~/cpuminer-opt

echo "========================================="
echo "  Starting cpuminer-opt (BACKUP POOL)"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $BACKUP_POOL_INPUT"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF
    
    chmod +x start-backup.sh
fi

# Create reconfigure script
cat > reconfigure.sh << 'EOF'
#!/bin/bash

echo "========================================="
echo "  cpuminer-opt Reconfiguration Tool"
echo "========================================="
echo ""
echo "This will update your mining configuration"
echo "without rebuilding cpuminer-opt"
echo ""

cd ~/cpuminer-opt

# Load current config if exists
if [ -f "mining-config.txt" ]; then
    echo "Current configuration found. Loading..."
    source mining-config.txt
    echo ""
    echo "Current settings:"
    echo "  Algorithm: $ALGO"
    echo "  Primary Pool: $PRIMARY_POOL"
    echo "  Wallet: $WALLET_ADDRESS"
    echo "  Worker: $WORKER_NAME"
    echo "  Threads: $THREADS"
    echo ""
fi

read -p "Press Enter to continue with reconfiguration..."
echo ""

# Ask what to reconfigure
echo "What would you like to change?"
echo ""
echo "1) Everything (full reconfiguration)"
echo "2) Algorithm only"
echo "3) Pools only"
echo "4) Wallet/Worker only"
echo "5) Threads only"
echo ""
read -p "Enter choice (1-5): " RECONFIG_CHOICE

case $RECONFIG_CHOICE in
    1)
        CHANGE_ALL=true
        ;;
    2)
        echo ""
        read -p "Enter new algorithm: " NEW_ALGO
        ALGO=$NEW_ALGO
        ;;
    3)
        echo ""
        read -p "Enter new primary pool (address:port): " NEW_PRIMARY
        PRIMARY_POOL="stratum+tcp://$NEW_PRIMARY"
        read -p "Update backup pool? (y/n): " UPDATE_BACKUP
        if [[ "$UPDATE_BACKUP" =~ ^[Yy]$ ]]; then
            read -p "Enter new backup pool (address:port): " NEW_BACKUP
            BACKUP_POOL="stratum+tcp://$NEW_BACKUP"
            HAS_BACKUP=true
        fi
        ;;
    4)
        echo ""
        read -p "Enter new wallet address: " NEW_WALLET
        WALLET_ADDRESS=$NEW_WALLET
        read -p "Enter new worker name: " NEW_WORKER
        WORKER_NAME=$NEW_WORKER
        ;;
    5)
        echo ""
        CPU_CORES=$(nproc)
        echo "Your system has $CPU_CORES CPU threads available"
        read -p "Enter new thread count: " NEW_THREADS
        THREADS=$NEW_THREADS
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Full reconfiguration
if [ "$CHANGE_ALL" = true ]; then
    echo ""
    echo "========================================="
    echo "  Full Reconfiguration"
    echo "========================================="
    echo ""
    
    read -p "Algorithm: " ALGO
    echo ""
    read -p "Primary pool (address:port): " PRIMARY_INPUT
    PRIMARY_POOL="stratum+tcp://$PRIMARY_INPUT"
    echo ""
    read -p "Add backup pool? (y/n): " ADD_BACKUP
    if [[ "$ADD_BACKUP" =~ ^[Yy]$ ]]; then
        read -p "Backup pool (address:port): " BACKUP_INPUT
        BACKUP_POOL="stratum+tcp://$BACKUP_INPUT"
        HAS_BACKUP=true
    else
        HAS_BACKUP=false
        BACKUP_POOL="None"
    fi
    echo ""
    read -p "Wallet address: " WALLET_ADDRESS
    echo ""
    read -p "Worker name: " WORKER_NAME
    echo ""
    read -p "Pool password (default: x): " POOL_PASSWORD
    POOL_PASSWORD=${POOL_PASSWORD:-x}
    echo ""
    CPU_CORES=$(nproc)
    echo "Your system has $CPU_CORES CPU threads available"
    RECOMMENDED=$((CPU_CORES * 3 / 4))
    read -p "Threads (default: $RECOMMENDED): " THREADS
    THREADS=${THREADS:-$RECOMMENDED}
fi

# Extract pool address without stratum+tcp:// for display
PRIMARY_POOL_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_POOL_DISPLAY=${BACKUP_POOL#stratum+tcp://}

# Recreate start.sh
cat > start.sh << INNEREOF
#!/bin/bash
cd ~/cpuminer-opt

echo "========================================="
echo "  Starting cpuminer-opt"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $PRIMARY_POOL_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF

chmod +x start.sh

# Recreate backup script if needed
if [ "$HAS_BACKUP" = true ]; then
    cat > start-backup.sh << INNEREOF
#!/bin/bash
cd ~/cpuminer-opt

echo "========================================="
echo "  Starting cpuminer-opt (BACKUP POOL)"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $BACKUP_POOL_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF
    
    chmod +x start-backup.sh
fi

# Save configuration
cat > mining-config.txt << INNEREOF
# cpuminer-opt configuration
# Last updated: $(date)
ALGO="$ALGO"
PRIMARY_POOL="$PRIMARY_POOL"
BACKUP_POOL="$BACKUP_POOL"
WALLET_ADDRESS="$WALLET_ADDRESS"
WORKER_NAME="$WORKER_NAME"
POOL_PASSWORD="$POOL_PASSWORD"
THREADS="$THREADS"
HAS_BACKUP=$HAS_BACKUP
INNEREOF

# Update info.sh
./create-info.sh

echo ""
echo "========================================="
echo "  ✓ Reconfiguration Complete!"
echo "========================================="
echo ""
echo "New configuration:"
echo "  Algorithm: $ALGO"
echo "  Primary Pool: $PRIMARY_POOL_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_POOL_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Threads: $THREADS"
echo ""
echo "Start mining with new config:"
echo "  ./start.sh"
echo ""
EOF

chmod +x reconfigure.sh

# Create helper script to regenerate info.sh
cat > create-info.sh << 'EOF'
#!/bin/bash

# Load current configuration
if [ -f "mining-config.txt" ]; then
    source mining-config.txt
fi

PRIMARY_POOL_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_POOL_DISPLAY=${BACKUP_POOL#stratum+tcp://}

cat > info.sh << INNEREOF
#!/bin/bash

echo "========================================="
echo "  cpuminer-opt Configuration"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Primary Pool: $PRIMARY_POOL_DISPLAY"
INNEREOF

if [ "$HAS_BACKUP" = true ]; then
    cat >> info.sh << INNEREOF
echo "Backup Pool: $BACKUP_POOL_DISPLAY"
INNEREOF
fi

cat >> info.sh << INNEREOF
echo "Wallet: $WALLET_ADDRESS"
echo "Worker: $WORKER_NAME"
echo "Password: $POOL_PASSWORD"
echo "Threads: $THREADS"
echo ""
echo "========================================="
echo "  Available Commands"
echo "========================================="
echo ""
echo "Start mining (primary pool):"
echo "  cd ~/cpuminer-opt && ./start.sh"
echo ""
INNEREOF

if [ "$HAS_BACKUP" = true ]; then
    cat >> info.sh << INNEREOF
echo "Start mining (backup pool):"
echo "  cd ~/cpuminer-opt && ./start-backup.sh"
echo ""
INNEREOF
fi

cat >> info.sh << INNEREOF
echo "Stop mining:"
echo "  Press Ctrl+C in the mining window"
echo ""
echo "Change mining configuration:"
echo "  cd ~/cpuminer-opt && ./reconfigure.sh"
echo ""
echo "  The reconfigure.sh script lets you:"
echo "  • Switch to different coin/algorithm"
echo "  • Change pools (primary and backup)"
echo "  • Update wallet address and worker name"
echo "  • Adjust thread count"
echo "  • Do partial or full reconfiguration"
echo ""
echo "View this info again:"
echo "  cd ~/cpuminer-opt && ./info.sh"
echo ""
echo "List supported algorithms:"
echo "  cd ~/cpuminer-opt && ./cpuminer --help"
echo ""
echo "========================================="
echo "  Quick Tips"
echo "========================================="
echo ""
echo "• Use reconfigure.sh to switch coins easily"
echo "• No need to rebuild cpuminer to change coins"
echo "• Monitor CPU temperature and usage"
echo "• Check pool website for your stats"
echo ""
INNEREOF

chmod +x info.sh
EOF

chmod +x create-info.sh

# Save initial configuration
cat > mining-config.txt << EOF
# cpuminer-opt configuration
# Created: $(date)
ALGO="$ALGO"
PRIMARY_POOL="$PRIMARY_POOL"
BACKUP_POOL="$BACKUP_POOL"
WALLET_ADDRESS="$WALLET_ADDRESS"
WORKER_NAME="$WORKER_NAME"
POOL_PASSWORD="$POOL_PASSWORD"
THREADS="$THREADS"
HAS_BACKUP=$HAS_BACKUP
EOF

# Generate info.sh
./create-info.sh

# Final success message
PRIMARY_POOL_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_POOL_DISPLAY=${BACKUP_POOL#stratum+tcp://}

echo ""
echo "========================================="
echo "  ✓ cpuminer-opt Setup Complete!"
echo "========================================="
echo ""
echo "Your configuration:"
echo "  Algorithm: $ALGO"
echo "  Primary Pool: $PRIMARY_POOL_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_POOL_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Password: $POOL_PASSWORD"
echo "  Threads: $THREADS"
echo ""
echo "========================================="
echo "  Quick Start Commands"
echo "========================================="
echo ""
echo "Start mining NOW:"
echo "  cd ~/cpuminer-opt && ./start.sh"
echo ""
if [ "$HAS_BACKUP" = true ]; then
    echo "Start with backup pool:"
    echo "  cd ~/cpuminer-opt && ./start-backup.sh"
    echo ""
fi
echo "View full info:"
echo "  cd ~/cpuminer-opt && ./info.sh"
echo ""
echo "========================================="
echo "  🔧 IMPORTANT: Changing Configuration"
echo "========================================="
echo ""
echo "To switch coins/algorithms or change settings,"
echo "run the reconfiguration script:"
echo ""
echo "  cd ~/cpuminer-opt && ./reconfigure.sh"
echo "  or"
echo "  ~/cpuminer-opt/reconfigure.sh"
echo ""
echo "This script lets you:"
echo "  ✓ Switch to a different coin/algorithm"
echo "  ✓ Change mining pools"
echo "  ✓ Update wallet address and worker"
echo "  ✓ Adjust thread count"
echo "  ✓ Reconfigure everything or just one setting"
echo ""
echo "No need to reinstall cpuminer-opt!"
echo "Just run ./reconfigure.sh whenever you want"
echo "to mine a different coin."
echo ""
echo "========================================="
echo "  Ready to mine!"
echo "========================================="
echo ""
echo "  cd ~/cpuminer-opt && ./start.sh"
echo "  or"
echo "  ~/cpuminer-opt/start.sh"
echo ""
