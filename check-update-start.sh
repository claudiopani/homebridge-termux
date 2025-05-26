if [ ! -d /data/data/com.termux/files ]; then
  echo "❌ Questo script può essere eseguito solo su Termux"
  exit 1
fi
#!/data/data/com.termux/files/usr/bin/

termux-wake-lock
export DEBIAN_FRONTEND=noninteractive

# Funzione per confrontare versioni (ritorna 1 se $1 < $2)
version_lt() {
  [ "$1" = "$2" ] && return 1
  [ "$(printf "%s\n" "$1" "$2" | sort -V | head -n1)" = "$1" ]
}

while true; do
  clear

  echo -e "\n🔄 Aggiornamento lista pacchetti Termux"
  pkg update -y -q >/dev/null 2>&1
  pkg upgrade -y -q >/dev/null 2>&1

  echo -e "\n🔎 Controllo versioni di Node.js, Homebridge e UI"

  ################################################################################
  # 1. Node.js LTS
  ################################################################################
  INSTALLED_NODE=$(node -v 2>/dev/null | sed 's/v//')
  AVAILABLE_NODE=$(pkg show nodejs-lts 2>/dev/null | grep -i version | head -n1 | awk '{print $2}')

  echo -e "\n❗ Node.js LTS installata:  $INSTALLED_NODE"
  echo "❗ Node.js LTS disponibile: $AVAILABLE_NODE"

  if version_lt "$INSTALLED_NODE" "$AVAILABLE_NODE"; then
    echo "❗ Aggiornamento Node.js in corso"
    pkg install -y nodejs-lts || {
      echo "❌ Errore aggiornamento Node.js"
      break
    }
  else
    echo "✅ Node.js è aggiornato"
  fi

  ################################################################################
  # 2. Homebridge
  ################################################################################
  INSTALLED_HB=$(npm list -g homebridge --depth=0 2>/dev/null | grep homebridge@ | awk -F@ '{print $2}')
  AVAILABLE_HB=$(npm show homebridge version)

  echo -e "\n❗ Homebridge installata:  $INSTALLED_HB"
  echo "❗ Homebridge disponibile: $AVAILABLE_HB"

  if version_lt "$INSTALLED_HB" "$AVAILABLE_HB"; then
    echo "❗ Aggiornamento Homebridge in corso"
    npm install -g --unsafe-perm homebridge || {
      echo "❌ Errore aggiornamento Homebridge"
      break
    }
  else
    echo "✅ Homebridge è aggiornato"
  fi

  ################################################################################
  # 3. Homebridge Config UI X
  ################################################################################
  INSTALLED_UI=$(npm list -g homebridge-config-ui-x --depth=0 2>/dev/null | grep homebridge-config-ui-x@ | awk -F@ '{print $2}')
  AVAILABLE_UI=$(npm show homebridge-config-ui-x version)

  echo -e "\n❗ UI installata:  $INSTALLED_UI"
  echo "❗ UI disponibile: $AVAILABLE_UI"

  if version_lt "$INSTALLED_UI" "$AVAILABLE_UI"; then
    echo "❗ Aggiornamento Homebridge UI in corso"
    npm install -g --unsafe-perm homebridge-config-ui-x || {
      echo "❌ Errore aggiornamento UI"
      break
    }
  else
    echo "✅ Homebridge UI è aggiornata"
  fi

  ################################################################################
  # 4. Avvia Homebridge tramite proot in loop e poi ricomincia il ciclo
  ################################################################################
  echo -e "\n🚀 Avvio Homebridge\n"
  proot -b ~/stat:/proc/stat hb

  echo -e "\n🔄 Homebridge è terminato\n"
  sleep 5
done

termux-wake-unlock