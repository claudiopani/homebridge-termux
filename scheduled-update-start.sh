if [ ! -d /data/data/com.termux/files ]; then
  echo "❌ Questo script può essere eseguito solo su Termux"
  exit 1
fi
#!/data/data/com.termux/files/usr/bin/

termux-wake-lock
export DEBIAN_FRONTEND=noninteractive

# 🔧 Verifica se la versione A è più vecchia della B
version_is_older() {
  [ "$1" = "$2" ] && return 1
  [ "$(printf "%s\n" "$1" "$2" | sort -V | head -n1)" = "$1" ]
}

# 🔄 Aggiorna pacchetti Termux
aggiorna_termux() {
  echo -e "\n🔄 Aggiornamento lista pacchetti Termux"
  pkg update -y -q >/dev/null 2>&1
  pkg upgrade -y -q >/dev/null 2>&1
}

# 🔄 Verifica e aggiorna Node.js LTS
aggiorna_node() {
  INSTALLED_NODE=$(node -v 2>/dev/null | sed 's/v//')
  AVAILABLE_NODE=$(pkg show nodejs-lts 2>/dev/null | grep -i version | head -n1 | awk '{print $2}')

  echo -e "\n❗ Node.js LTS installata:  $INSTALLED_NODE"
  echo "❗ Node.js LTS disponibile: $AVAILABLE_NODE"

  if version_is_older "$INSTALLED_NODE" "$AVAILABLE_NODE"; then
    echo "❗ Aggiornamento Node.js in corso..."
    if pkg install -y nodejs-lts; then
      echo "✅ Node.js aggiornato con successo"
    else
      echo "❌ Errore aggiornamento Node.js"
    fi
  else
    echo "✅ Node.js è aggiornato"
  fi
}

# 🔄 Verifica e aggiorna Homebridge
aggiorna_homebridge() {
  INSTALLED_HB=$(npm list -g homebridge --depth=0 2>/dev/null | grep homebridge@ | awk -F@ '{print $2}')
  AVAILABLE_HB=$(npm show homebridge version)

  echo -e "\n❗ Homebridge installata:  $INSTALLED_HB"
  echo "❗ Homebridge disponibile: $AVAILABLE_HB"

  if version_is_older "$INSTALLED_HB" "$AVAILABLE_HB"; then
    echo "❗ Aggiornamento Homebridge in corso..."
    npm install -g --unsafe-perm homebridge || echo "❌ Errore aggiornamento Homebridge"
  else
    echo "✅ Homebridge è aggiornato"
  fi
}

# 🔄 Verifica e aggiorna Homebridge UI
aggiorna_ui() {
  INSTALLED_UI=$(npm list -g homebridge-config-ui-x --depth=0 2>/dev/null | grep homebridge-config-ui-x@ | awk -F@ '{print $2}')
  AVAILABLE_UI=$(npm show homebridge-config-ui-x version)

  echo -e "\n❗ UI installata:  $INSTALLED_UI"
  echo "❗ UI disponibile: $AVAILABLE_UI"

  if version_is_older "$INSTALLED_UI" "$AVAILABLE_UI"; then
    echo "❗ Aggiornamento Homebridge UI in corso..."
    npm install -g --unsafe-perm homebridge-config-ui-x || echo "❌ Errore aggiornamento UI"
  else
    echo "✅ Homebridge UI è aggiornata"
  fi
}

stop_homebridge() {
  echo -e "\n❗ Arresto Homebridge"

  if tmux has-session -t homebridge 2>/dev/null; then
    tmux kill-session -t homebridge
    echo "✅ Sessione Homebridge chiusa"
  else
    echo "❗ Nessuna sessione Homebridge attiva"
  fi

  PIDS=$(pgrep -f "hb|homebridge")
  if [ -n "$PIDS" ]; then
    echo -e "\n❗ Trovati processi da terminare:"
    echo -e "$PIDS\n"
    kill $PIDS
    sleep 2
    # Controlla ancora se ci sono processi rimasti e forza kill se serve
    PIDS_REMAINING=$(pgrep -f "hb|homebridge")
    if [ -n "$PIDS_REMAINING" ]; then
      echo "❗ Chiusura forzata dei processi:"
      echo -e "$PIDS_REMAINING\n"
      kill -9 $PIDS_REMAINING
      echo "✅ Processi forzatamente terminati"
    else
        echo "✅ Processi terminati"
    fi
  else
    echo "❗ Nessun processo Homebridge trovato"
  fi
}

# 🚀 Avvia Homebridge
start_homebridge() {
  # Controlla se la sessione tmux esiste già
  if tmux has-session -t homebridge 2>/dev/null; then
    if ! pgrep -f "hb|homebridge" >/dev/null; then
        echo -e "❗ Sessione Homebridge attiva senza processi\n❗ Stop in corso"
        tmux kill-session -t homebridge
    fi
  else
    tmux new-session -d -s homebridge 'proot -b ~/stat:/proc/stat hb'
    echo -e "\n🚀 Homebridge in esecuzione\n"    
  fi
}

################################################################################
# ♻️ LOOP PRINCIPALE
################################################################################
clear

LAST_RUN_DATE=""

while true; do
  CURRENT_TIME=$(date +%H:%M:%S)
  TODAY=$(date +%Y-%m-%d)

  if [[ "$CURRENT_TIME" > "04:00:00" && "$CURRENT_TIME" < "04:01:00" && "$LAST_RUN_DATE" != "$TODAY" ]]; then
    echo -e "\n⏰ Riavvio e aggiornamento delle 04:00AM"
    LAST_RUN_DATE="$TODAY"
    stop_homebridge
    aggiorna_termux
    aggiorna_node
    aggiorna_homebridge
    aggiorna_ui
    start_homebridge
    sleep 300
  fi

  start_homebridge
  sleep 15
done