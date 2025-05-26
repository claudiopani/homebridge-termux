# This file is based on code originally licensed under the MIT License:
# (c) 2025 Orachigami - https://github.com/Orachigami/
# Modified by claudiopani - https://github.com/claudiopani/, 2025
#
# This file is part of homebridge-android and is licensed under the GPLv3.
# See the LICENSE file for more details.

if [ ! -d /data/data/com.termux/files ]; then
  echo "❌ Questo script può essere eseguito solo su Termux"
  exit 1
fi
#!/data/data/com.termux/files/usr/bin/bash

# Impedisce che Termux entri in sleep durante l'installazione
termux-wake-lock  

################################################################################
# 1. EVITA PROMPT INTERATTIVI DURANTE L'AGGIORNAMENTO
################################################################################

export DEBIAN_FRONTEND=noninteractive
echo -e 'Dpkg::Options {\n  "--force-confnew";\n}' > ~/../usr/etc/apt/apt.conf.d/local

################################################################################
# 2. RIMOZIONE DEI REPOSITORY NON SUPPORTATI
################################################################################

echo '❗ Rimuovo repositories invalide'
pkg remove -y game-repo
pkg remove -y science-repo

################################################################################
# 3. AGGIORNAMENTO DEI PACCHETTI BASE E INSTALLAZIONE DEI COMPONENTI NECESSARI
################################################################################

echo '== Aggiornamento dei repository e aggiornamento dei pacchetti =='
pkg update -y
pkg upgrade -y

echo '❗ Installazione di python, openssl, nodejs-lts e proot'
pkg install -y python openssl nodejs-lts proot tmux || {
  echo "❌ Errore nell'installazione dei pacchetti base"
  exit 1
}

################################################################################
# 4. CREAZIONE DI UN FILE /proc/stat SIMULATO PER PROOT
################################################################################

echo '❗ Creazione di un file /proc/stat di supporto'
cat << EOF > ~/stat
cpu 1132 34 1441 11311718 3675 127 438
cpu0 1132 34 1441 11311718 3675 127 438
EOF

################################################################################
# 5. RIPRISTINO DEL COMPORTAMENTO INTERATTIVO STANDARD
################################################################################

echo '❗ Rimozione delle opzioni Dpkg impostate'
rm -f ~/../usr/etc/apt/apt.conf.d/local

################################################################################
# 6. INSTALLAZIONE DI HOMEBRIDGE E HOMEBRIDGE UI
################################################################################

echo '❗ Installazione di Homebridge e Homebridge UI'
mkdir -p ~/.gyp
echo '{"variables":{"android_ndk_path":""}}' > ~/.gyp/include.gypi

npm install -g --unsafe-perm homebridge || {
  echo "❌ Errore durante l'installazione di homebridge"
  exit 1
}

npm install -g --unsafe-perm homebridge-config-ui-x || {
  echo "❌ Errore durante l'installazione di homebridge-config-ui-x"
  exit 1
}

################################################################################
# 7. CREAZIONE DELLA CONFIGURAZIONE DI BASE DI HOMEBRIDGE
################################################################################

echo '❗ Creazione della configurazione predefinita'
mkdir -p ~/.homebridge
cat << EOF > ~/.homebridge/config.json
{
    "bridge": {
        "name": "Homebridge QuantumX",
        "username": "72:9D:3F:B2:87:E1",
        "port": 51890,
        "pin": "528-32-918",
        "advertiser": "bonjour-hap"
    },
    "accessories": [],
    "platforms": [
        {
            "name": "Config",
            "port": 8581,
            "platform": "config",
            "log": {
                "method": "file",
                "path": "/data/data/com.termux/files/home/.homebridge/homebridge.log"
            }
        }
    ]
}
EOF

################################################################################
# 8. AGGIUNTA DI UN COMANDO PERSONALIZZATO "hb" E DI UN ALIAS "hb-start"
################################################################################

echo '❗ Aggiunta dei comandi di Homebridge'

# Script di avvio personalizzato
echo 'exec npx homebridge "$@" 2>&1 | tee ~/.homebridge/homebridge.log' > ~/../usr/bin/hb
chmod +x ~/../usr/bin/hb

# Alias persistente per avvio con stat emulato tramite proot
echo 'alias hb-start="proot -b ~/stat:/proc/stat hb"' >> ~/.profile

# Applica subito l'alias corrente alla shell
source ~/.profile

################################################################################
# 9. MESSAGGIO FINALE
################################################################################

echo -e '\n✅ Installazione completata!'
echo '👉 Riavvia Termux con il comando: exit'
echo '👉 Poi avvia Homebridge con: hb-start'

cat <<EOF

❗ Ricorda di eseguire lo script per automatizzare il 
   server!
   Questo manterrà Homebridge in esecuzione in un ciclo 
   continuo senza fine e aggiornerà automaticamente le 
   dipendenze a ogni riavvio.
   
   Comando suggerito (verifica aggiornamento ad ogni 
   riavvio):
   curl -s https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/check-update-start.sh | bash

   Comando migliore (controllo aggiornamenti alle ore 
   04:00AM e avvio rapido):
   curl -s https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/scheduled-update-start.sh | bash
EOF

# Disattiva il blocco del sonno attivato all'inizio dello script
termux-wake-unlock