#!/data/data/com.termux/files/usr/bin/bash

# Impedisce che il dispositivo vada in sleep mentre lo script è in esecuzione
termux-wake-lock

################################################################################
#  FUNZIONI DI GESTIONE NODE.JS (via repo Termux)
################################################################################

get_latest_node_version() {
  curl -sL https://packages.termux.dev/apt/termux-main/dists/stable/main/binary-arm/Packages.gz \
    | gunzip \
    | awk '
        /^Package:/ { pkg = $2; show = (pkg == "nodejs-lts") }
        show && /^Version:/ { print $2; exit }
      '
}

get_current_node_version() {
  if command -v node >/dev/null 2>&1; then
    node -v | sed 's/^v//'
  else
    echo ""
  fi
}

version_ge() {
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

################################################################################
#  FUNZIONI DI GESTIONE PACCHETTI HOMEBRIDGE E LA SUA UI
################################################################################

get_latest_npm_version() {
  npm view "$1" version 2>/dev/null
}

get_installed_npm_version() {
  local package="$1"
  npm list -g "$package" --depth=0 --json 2>/dev/null \
    | node -pe "JSON.parse(require('fs').readFileSync(0)).dependencies?.['$package']?.version || ''"
}

update_npm_package_if_needed() {
  local package="$1"
  local latest current

  latest=$(get_latest_npm_version "$package")
  current=$(get_installed_npm_version "$package")

  echo "$package installato: ${current:-non installato}"
  echo "$package disponibile: $latest"

  if [ -z "$current" ] || ! version_ge "$current" "$latest"; then
    echo "Aggiornamento $package in corso..."
    if npm install -g --unsafe-perm "$package"; then
      echo "✅ $package aggiornato con successo"
    else
      echo "❌ Errore durante l'aggiornamento di $package"
    fi
  else
    echo "✅ $package è già aggiornato."
  fi
}

################################################################################
#  CICLO PRINCIPALE (loop infinito)
################################################################################

while true; do
  clear
  
  echo "== [1/4] Aggiornamento pacchetti Termux =="
  if pkg update -y && pkg upgrade -y; then
    echo "✅ Pacchetti aggiornati"
  else
    echo "❌ Errore durante l'aggiornamento dei pacchetti"
  fi

  echo "== [2/4] Controllo versione Node.js =="
  LATEST_VERSION=$(get_latest_node_version)
  CURRENT_VERSION=$(get_current_node_version)
  
  echo "Versione Node.js installata: $CURRENT_VERSION"
  echo "Versione Node.js disponibile: $LATEST_VERSION"

  export DEBIAN_FRONTEND=noninteractive
  echo -e 'Dpkg::Options {\n  "--force-confnew";\n}' > ~/../usr/etc/apt/apt.conf.d/local

  if [ -z "$CURRENT_VERSION" ]; then
    echo "Node.js non installato, installazione in corso..."
    if pkg install -y nodejs-lts && npm update -g --unsafe-perm; then
      echo "✅ Node.js installato correttamente"
    else
      echo "❌ Errore durante l'installazione di Node.js"
    fi
  elif ! version_ge "$CURRENT_VERSION" "$LATEST_VERSION"; then
    echo "Node.js è obsoleto, reinstallazione in corso..."
    if pkg install -y nodejs-lts && npm update -g --unsafe-perm; then
      echo "✅ Node.js aggiornato correttamente"
    else
      echo "❌ Errore durante l'aggiornamento di Node.js"
    fi
  else
    echo "✅ Node.js è già aggiornato."
  fi

  echo "== Rimozione delle opzioni dpkg impostate =="
  rm ~/../usr/etc/apt/apt.conf.d/local

  echo "== [3/4] Controllo aggiornamenti Homebridge e UI =="
  update_npm_package_if_needed homebridge
  update_npm_package_if_needed homebridge-config-ui-x

  echo "== [4/4] Rebuild moduli globali se versione node è cambiata =="
  NODE_VERSION_CURRENT=$(node -v)
  NODE_VERSION_FILE=~/.last_node_version

  if [ ! -f "$NODE_VERSION_FILE" ] || [ "$(cat $NODE_VERSION_FILE)" != "$NODE_VERSION_CURRENT" ]; then
    echo "== Nuova versione Node.js rilevata ($NODE_VERSION_CURRENT), eseguo npm rebuild =="
    if npm rebuild -g >> ~/npm-rebuild.log 2>&1; then
      echo "✅ Rebuild completato"
    else
      echo "❌ Errore durante npm rebuild"
    fi
    echo "$NODE_VERSION_CURRENT" > "$NODE_VERSION_FILE"
  else
    echo "✅ Nessuna rebuild necessaria"
  fi

  echo "== Avvio Homebridge =="
  proot -b ~/stat:/proc/stat hb

  sleep 5
done
