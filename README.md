# Homebridge su termux

## 🛡️ Licenza

Questo progetto è distribuito sotto la licenza **GNU Affero General Public License versione 3 (AGPLv3)**.  
Puoi consultare il testo completo nel file [`LICENSE`](./LICENSE).

### Codice di terze parti

Alcuni file sono basati su codice originariamente rilasciato sotto **MIT License** da [Orachigami](https://github.com/Orachigami/).  
Tale codice è stato modificato e integrato nel progetto nel rispetto dei termini compatibili con la AGPLv3.  
Le attribuzioni e la licenza originale sono disponibili nel file [`NOTICE`](./NOTICE) e nei commenti dei file interessati.

⚠️ Tutto il codice del progetto è distribuito complessivamente sotto AGPLv3.

---

## ▶️ Installazione e utilizzo

### Avvio iniziale
Poiché Termux non supporta `systemd`, questo progetto utilizza script alternativi per mantenere Homebridge attivo in modo persistente.
Per installare e avviare manualmente il servizio, esegui:

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/script.sh | bash
```

---

## ▶️ Automazioni
Gli script descritti di seguito consentono di mantenere Homebridge **sempre attivo e automaticamente aggiornato**, anche dopo riavvii o in base a una pianificazione.

### Avvio con verifica aggiornamenti
Per eseguire automaticamente un controllo degli aggiornamenti ad ogni riavvio del dispositivo, e installarli se disponibili prima dell’avvio di Homebridge, utilizza:

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/check-update-start.sh | bash
```

---

### Riavvio automatico giornaliero con verifica aggiornamenti
Per programmare un riavvio automatico giornaliero alle **04:00**, con controllo e installazione degli aggiornamenti, esegui:

```bash
curl https://raw.githubusercontent.com/claudiopani/homebridge-termux/main/scheduled-update-start.sh | bash
```

---

### 📱 Ambiente di test

* **Dispositivo**: Samsung SM-A310F (Android 7)
* **Kernel**: Custom per sblocco octa-core
* **Terminale**: Termux

---

### 📖 Note finali

Si consiglia di esaminare attentamente il contenuto degli script prima dell’esecuzione, per garantire la sicurezza del proprio sistema.

Per ulteriori dettagli, aggiornamenti o supporto, visita la [pagina del progetto su GitHub](https://github.com/claudiopani/homebridge-termux).

---