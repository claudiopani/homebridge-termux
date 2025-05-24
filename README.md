Derivato dallo script di [Orachigami](https://github.com/Orachigami/).

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/script.sh | bash
```

Simulazione di un servizio continuo senza systemd: Questo script mantiene il server in esecuzione in un ciclo infinito e aggiorna automaticamente le dipendenze, come pacchetti di sistema e moduli Node.js, senza la necessità di utilizzare un gestore di servizi come systemd.

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/bashrc.sh | bash
```

Questo consente di riavviare automaticamente alle 04:00 AM il server.

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/tmux-bashrc.sh | bash
```

Testato su SM-A310F (Android 7), con kernel custom per sblocco octa-core, ed eseguito su Termux.
