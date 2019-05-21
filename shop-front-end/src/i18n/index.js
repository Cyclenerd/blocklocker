import Vue from 'vue'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

const messages = {
  'en-US': {
    message: {
      pleasePay: 'Please Pay',
      openDoor: 'You can open the door now. Please do this in',
      countdownDoorExpTitle: 'Thank You',
      countdownDoorExpMsg: 'You have received your product!',
      countdownExpTitle: 'Big Fat Sorry',
      countdownExpMsg: 'Your time is up. Hurry up next time.',
      currencyWarning: 'Payment in this currency is not supported.',
      doorNotWorking: 'The vending machine is not working.',
      doorWarning: 'Cannot open door',
      doorWorking: 'The vending machine is working. It is located here: {location}',
      newTransaction: 'A new transaction has arrived.',
      newConfirmation: 'A new conformation has arrived.',
      notConfirmedWarning: 'Your payment has not been confirmed. Please wait max.',
      notPaidWarning: 'Please pay the full amount in',
      remainingProducts: '{count} more available',
      scanTitle: 'Scan QR code',
      scanWithZcash: 'Scan this QR code with your Wallet app.',
      soldOut: 'Sold out!'
    },
    transaction: {
      table: {
        title: 'Transactions',
        price: 'Amount (ZEC)',
        count: 'Confirmations'
      }
    },
    label: {
      address: 'Address',
      door: 'Door',
      hours: 'Hours',
      minutes: 'Minutes',
      open: 'open',
      openDoor: 'Open Door',
      price: 'Amount (ZEC)',
      seconds: 'Seconds'
    },
    button: {
      about: 'Help',
      buy: 'Buy',
      close: 'Close',
      ok: 'OK',
      openWallet: 'Open Wallet',
      pay: 'Pay',
      showQR: 'Show QR Code'
    },
    tab: {
      faq: 'FAQ',
      imprint: 'Imprint'
    }
  },
  'de-DE': {
    message: {
      pleasePay: 'Bitte zahlen',
      openDoor: 'Du kannst die Tür jetzt öffnen. Bitte erledige das in',
      countdownDoorExpTitle: 'Vielen Dank',
      countdownDoorExpMsg: 'Du hast dein Produkt erhalten!',
      countdownExpTitle: 'Dickes fettes Sorry',
      countdownExpMsg: 'Deine Zeit ist abgelaufen. Beeil dich nächstes mal.',
      currencyWarning: 'Das Bezahlen in dieser Währung wird nicht unterstützt.',
      doorNotWorking: 'Der Automat ist außer Betrieb.',
      doorWarning: 'Tür kann nicht geöffnet werden',
      doorWorking: 'Der Automat ist in Betrieb. Er befindet sich hier: {location}',
      newTransaction: 'Eine neue Transaktion ist angekommen.',
      newConfirmation: 'Eine neue Bestätigung ist angekommen.',
      notConfirmedWarning: 'Deine Zahlung wurde noch nicht bestätigt. Bitte warte max.',
      notPaidWarning: 'Bitte zahle den vollständigen Betrag in',
      remainingProducts: 'Noch {count} verfügbar',
      scanTitle: 'QR-Code scannen',
      scanWithZcash: 'Scanne den QR-Code mit deiner Wallet-App.',
      soldOut: 'Ausverkauft!'
    },
    transaction: {
      table: {
        title: 'Transaktionen',
        price: 'Betrag (ZEC)',
        count: 'Bestätigungen'
      }
    },
    label: {
      address: 'Adresse',
      door: 'Tür',
      hours: 'Stunden',
      minutes: 'Minuten',
      open: 'offen',
      openDoor: 'Tür öffnen',
      price: 'Betrag (ZEC)',
      seconds: 'Sekunden'
    },
    button: {
      about: 'Hilfe',
      buy: 'Kaufen',
      close: 'Schließen',
      ok: 'OK',
      openWallet: 'Wallet öffnen',
      pay: 'Bezahlen',
      showQR: 'QR-Code anzeigen'
    },
    tab: {
      faq: 'FAQ',
      imprint: 'Impressum'
    }
  },
  'de': {
    message: {
      pleasePay: 'Bitte zahlen',
      openDoor: 'Du kannst die Tür jetzt öffnen. Bitte erledige das in',
      countdownDoorExpTitle: 'Vielen Dank',
      countdownDoorExpMsg: 'Du hast dein Produkt erhalten!',
      countdownExpTitle: 'Dickes fettes Sorry',
      countdownExpMsg: 'Deine Zeit ist abgelaufen. Beeil dich nächstes mal.',
      currencyWarning: 'Das Bezahlen in dieser Währung wird nicht unterstützt.',
      doorNotWorking: 'Der Automat ist außer Betrieb.',
      doorWarning: 'Tür kann nicht geöffnet werden!',
      newTransaction: 'Eine neue Transaktion ist angekommen.',
      newConfirmation: 'Eine neue Bestätigung ist angekommen.',
      doorWorking: 'Der Automat ist in Betrieb. Er befindet sich hier: {location}',
      notConfirmedWarning: 'Deine Zahlung wurde noch nicht bestätigt. Bitte warte max.',
      notPaidWarning: 'Bitte zahle den vollständigen Betrag in',
      remainingProducts: 'Noch {count} verfügbar',
      scanTitle: 'QR-Code scannen',
      scanWithZcash: 'Scanne den QR-Code mit deiner Wallet-App.',
      soldOut: 'Ausverkauft!'
    },
    transaction: {
      table: {
        title: 'Transaktionen',
        price: 'Betrag (ZEC)',
        count: 'Bestätigungen'
      }
    },
    label: {
      address: 'Adresse',
      door: 'Tür',
      hours: 'Stunden',
      minutes: 'Minuten',
      open: 'offen',
      openDoor: 'Tür öffnen',
      price: 'Betrag (ZEC)',
      seconds: 'Sekunden'
    },
    button: {
      about: 'Help',
      buy: 'Kaufen',
      close: 'Schließen',
      ok: 'OK',
      openWallet: 'Wallet öffnen',
      pay: 'Bezahlen',
      showQR: 'QR-Code anzeigen'
    },
    tab: {
      faq: 'FAQ',
      imprint: 'Impressum'
    }
  }
}

export default new VueI18n({
  locale: navigator.language,
  fallbackLocale: 'en-US',
  messages
})
