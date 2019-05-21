<template>
  <div class="md-layout md-alignment-center">
    <!-- Dialog: QR Code -->
    <md-dialog :md-active.sync="showQRCode" class="bl-centered">
      <md-dialog-title>{{ $t('message.scanTitle') }}</md-dialog-title>
      <md-content class="bl-margin">{{ $t('message.scanWithZcash') }}</md-content>
      <vue-qr class="bl-margin" :text="zcashLink" :size="300"></vue-qr>
      <md-dialog-actions>
        <md-button class="md-primary" @click="showQRCode = false">{{ $t("button.close") }}</md-button>
      </md-dialog-actions>
    </md-dialog>

    <!-- Dialog: Door cannot be opened -->
    <md-dialog :md-active.sync="showDoorWarning">
      <md-dialog-title>{{ $t('message.doorWarning') }}</md-dialog-title>
      <img src="../assets/giphy_door.gif" alt="">
      <md-dialog-actions>
        <md-button class="md-primary" @click="showDoorWarning = false">{{ $t("button.close") }}</md-button>
      </md-dialog-actions>
    </md-dialog>

    <!-- Dialog: Door can be opened-->
    <md-dialog :md-active.sync="showDoorSuccess">
      <md-dialog-content class="centered">
        <div class="block">
          <p class="text">{{ $t("label.door") }}</p>
          <p class="digit">{{openDoor}}</p>
          <p class="text">{{ $t("label.open") }}</p>
        </div>
      </md-dialog-content>

      <md-dialog-actions>
        <md-button class="md-primary" @click="showDoorSuccess = false">{{ $t("button.close") }}</md-button>
      </md-dialog-actions>
    </md-dialog>

    <!-- Snackbar: New Transaction or Confirmation -->
    <md-snackbar :md-active.sync="showSnackBar" md-position="left">
      <span>{{snackBarText}}</span>
    </md-snackbar>

    <!-- Main-Page -->
    <div
      v-if="!countdownExpired.payment && !countdownExpired.confirm && !countdownExpired.door"
      class="md-layout-item md-xlarge-size-45 md-large-size-50 md-medium-size-60 md-small-size-75 md-xsmall-size-100"
    >
      <md-card>
        <!-- Title -->
        <md-card-header>
          <div class="md-title">{{ $t("message.pleasePay") }}</div>
        </md-card-header>
        <md-card-content>

          <!-- Price and ZCash Address -->
          <md-field>
            <label>{{ $t("label.price") }}</label>
            <md-input :value="price" readonly></md-input>
          </md-field>
          <md-field>
            <label>{{ $t("label.address") }}</label>
            <md-input :value="address" readonly></md-input>
          </md-field>

          <!-- Countdowns -->
          <!-- 1st countdown: User has to do payment -->
          <div v-if="balance < price">
            {{ $t("message.notPaidWarning") }}:
            <Countdown
              :from="timestamp"
              :to="paymentUntil"
              @countdown-expired="onPaymentCountdownExpired"
            ></Countdown>
            <md-card-actions>
              <md-button
                class="md-raised md-primary"
                @click="onClickShowQR()"
              >{{ $t("button.showQR") }}</md-button>
              <md-button
                class="md-raised md-primary"
                @click="onClickOpenWallet()"
              >{{ $t("button.openWallet") }}</md-button>
            </md-card-actions>
          </div>

          <!-- 2nd countdown: Payment has to be confirmed -->
          <div v-if="balance >= price && confirmedBalance < price">
            {{ $t('message.notConfirmedWarning') }}:
            <Countdown
              :from="timestamp"
              :to="confirmationUntil"
              @countdown-expired="onConfirmCountdownExpired"
            ></Countdown>
          </div>

          <!-- 3rd countdown: Door has to be opened -->
          <div v-if="confirmedBalance >= price">
            {{ $t('message.openDoor') }}:
            <Countdown
              :from="timestamp"
              :to="openUntil"
              @countdown-expired="onDoorCountdownExpired"
            ></Countdown>
            <md-card-actions>
             <md-button
                class="md-primary md-raised bl-bigbutton bl-margin"
                @click="onClickOpen()"
              >{{ $t("label.openDoor") }}</md-button>
            </md-card-actions>
          </div>

          <!-- Transaction Table -->
          <md-table v-if="Object.keys(confirmations).length > 0">
            <md-table-toolbar>
              <h1 class="md-title">{{ $t("transaction.table.title") }}</h1>
            </md-table-toolbar>
            <md-table-row>
              <md-table-head>ID</md-table-head>
              <md-table-head md-numeric>{{ $t('transaction.table.price') }}</md-table-head>
              <md-table-head md-numeric>{{ $t('transaction.table.count') }}</md-table-head>
            </md-table-row>
            <md-table-row v-for="confirmation in confirmations" :key="confirmation.id">
              <md-table-cell>{{confirmation.id}}</md-table-cell>
              <md-table-cell md-numeric>{{ confirmation.amount }}</md-table-cell>
              <md-table-cell md-numeric>{{ confirmation.count }}</md-table-cell>
            </md-table-row>
          </md-table>
        </md-card-content>
      </md-card>
    </div>

    <md-empty-state
      v-if="countdownExpired.payment && balance < price"
      class="md-accent bl-margin"
      md-rounded
      md-icon="mood_bad"
      :md-label="$t('message.countdownExpTitle')"
      :md-description="$t('message.countdownExpMsg')"
    ></md-empty-state>

    <md-empty-state
      v-if="countdownExpired.confirm && balance >= price && confirmedBalance < price"
      class="md-accent bl-margin"
      md-rounded
      md-icon="mood_bad"
      :md-label="$t('message.countdownExpTitle')"
      :md-description="$t('message.countdownExpMsg')"
    ></md-empty-state>

    <md-empty-state
      v-if="countdownExpired.door && confirmedBalance >= price"
      class="md-primary bl-margin"
      md-rounded
      md-icon="mood"
      :md-label="$t('message.countdownDoorExpTitle')"
      :md-description="$t('message.countdownDoorExpMsg')"
    ></md-empty-state>
  </div>
</template>

<style lang="scss" scoped>
.bl-centered {
  text-align: center;
}

.bl-margin {
  margin: 1rem;
}

.bl-bigbutton.md-button {
  padding: 1rem;
  height: 4rem;
}

.md-layout-item {
  &:after {
    height: 100%;
    width: 100%;
    display: block;
    content: " ";
  }
}

.md-card {
  display: inline-block;
  margin: 1rem !important;
  min-width: auto;
  width: calc(100% - 2rem);
  vertical-align: top;
}

.md-dialog-content.centered {
  text-align: center;
}

.text {
  color: #1abc9c;
  font-size: 1rem;
  font-family: "Roboto Condensed", serif;
  font-weight: 400;
  margin: 2rem;
  text-align: center;
}

.digit {
  color: #ecf0f1;
  font-size: 2rem;
  font-weight: 100;
  font-family: "Roboto", serif;
  margin: 1rem;
  text-align: center;
}

</style>

<script>
import Countdown from './Countdown.vue'
import VueQr from 'vue-qr'

const mCurrency = {
  zcash: 'zec',
  bitcoin: 'btc',
  ethereum: 'eth',
  euro: 'eur'
}

export default {
  name: 'ProductDetails',
  components: { Countdown, VueQr },
  data: function () {
    return {
      address: this.$route.params.id,
      requiredConfirmations: 0,
      confirmations: {},
      countdownExpired: {
        payment: false,
        confirm: false,
        door: false
      },
      balance: 0,
      confirmedBalance: 0,
      price: 0,
      currency: mCurrency[this.$route.params.currency],
      timestamp: null,
      paymentUntil: null,
      confirmationUntil: null,
      openUntil: null,
      openDoor: 0,
      showDoorWarning: false,
      showDoorSuccess: false,
      showQRCode: false,
      showSnackBar: false,
      snackBarText: '',
      zcashLink: ''
    }
  },
  created () {
    this._fetchItem()
    window.setInterval(() => {
      this._fetchItem()
    }, 2000)
  },
  methods: {
    onClickShowQR () {
      this.showQRCode = true
    },
    onClickOpenWallet () {
      window.open(this.zcashLink, '_blank')
    },
    onPaymentCountdownExpired () {
      this.countdownExpired.payment = true;
    },
    onConfirmCountdownExpired () {
      this.countdownExpired.confirm = true;
    },
    onDoorCountdownExpired () {
      this.countdownExpired.door = true;
    },
    onClickOpen () {
      this.$http
        .get(`/api/v1/open/${this.$route.params.currency}/${this.$route.params.id}`)
        .then(
          response => {
            this.openDoor = response.body.door
            this.showDoorSuccess = true
            // response.body.door ist die Türnummer
            // Progressbar zw. Countdown und Button anzeigen
            // Bar sollte ca. 10 sekunden sich füllen
            // währenddessen kann nicht erneut DOOR OPEN geklickt werden
          },
          response => {
            this.showDoorWarning = true
          }
        )
    },
    _fetchItem () {
      this.$http
        .get(`/api/v1/status/${this.$route.params.currency}/${this.$route.params.id}`)
        .then(
          response => {
            this.price = response.body.price_zec
            this.timestamp = response.body.timestamp
            this.paymentUntil = response.body.payment_until
            this.confirmationUntil = response.body.confirmation_until
            this.openUntil = response.body.open_until
            this.requiredConfirmations = response.body.required_confirmations

            this.zcashLink = `zcash:${this.address}?amount=${this.price}`

            var mConfirmations = response.body.confirmations
            Object.keys(mConfirmations)
              .sort()
              .forEach(key => {
                var mConfirmation = mConfirmations[key]
                if (parseInt(key, 10) === 0) {
                  this.balance = mConfirmation.balance
                } else if (parseInt(key, 10) === this.requiredConfirmations) {
                  this.confirmedBalance = mConfirmation.balance
                }
                mConfirmation.transactions.forEach(transaction => {
                  if (!this.confirmations[transaction.txid]) {
                    this.confirmations[transaction.txid] = {
                      id: transaction.txid,
                      count: +key,
                      amount: transaction.amount
                    }

                    this.snackBarText = this.$t('message.newTransaction')
                    this.showSnackBar = true
                  } else if (
                    this.confirmations[transaction.txid].count < +key
                  ) {
                    this.confirmations[transaction.txid].count = +key
                    this.snackBarText = this.$t('message.newConfirmation')
                    this.showSnackBar = true
                  }
                })
              })
          },
          response => {}
        )
    }
  }
}
</script>
