<template>

    <div class="md-layout md-alignment-center">
        <md-dialog
            :md-active.sync="showCurrencyWarning">
            <md-dialog-content>
                {{ $t("message.currencyWarning") }}
            </md-dialog-content>
            <md-dialog-actions>
                <md-button class="md-primary" @click="showCurrencyWarning = false">{{ $t("button.close") }}</md-button>
            </md-dialog-actions>
        </md-dialog>

        <div class="md-layout-item md-xlarge-size-45 md-large-size-50 md-medium-size-60 md-small-size-75 md-xsmall-size-100">
            <md-card>
                <md-card-media md-ratio="16:9">
                    <img :src="item.product_img_url" :alt="item.product_name">
                </md-card-media>

                <md-card-header>
                    <div  class="md-title">{{item.product_name}}</div>
                    <span  v-if="item.number_available > 0" class="md-subhead">{{ $t('message.remainingProducts', { count: item.number_available }) }}</span>
                    <span  v-else class="md-subhead blockr-warning">{{ $t("message.soldOut") }}</span>
                </md-card-header>

                <md-card-content>
                    <md-list>
                        <md-list-item>
                            <span class="md-list-item-text">{{item.product_price_zec}} ZEC</span>
                            <md-button class="md-list-action" @click="onClickPay(item, 'zec')">{{ $t("button.pay") }}</md-button>
                        </md-list-item>
                        <md-list-item>
                            <span class="md-list-item-text">{{item.product_price_eur}} EUR</span>
                            <md-button class="md-list-action" @click="onClickPay(item, 'eur')">{{ $t("button.pay") }}</md-button>
                        </md-list-item>
                        <!--
                        <md-list-item>
                            <span class="md-list-item-text">{{item.product_price_eth}} ETH</span>
                            <md-button class="md-list-action" @click="onClickPay(item, 'eth')">{{ $t("button.pay") }}</md-button>
                        </md-list-item>
                        <md-list-item>
                            <span class="md-list-item-text">{{item.product_price_btc}} BTC</span>
                            <md-button class="md-list-action" @click="onClickPay(item, 'btc')">{{ $t("button.pay") }}</md-button>
                        </md-list-item>
                        -->
                    </md-list>
                </md-card-content>
            </md-card>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.md-layout-item {
  &:after {
    height: 100%;
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

.md-card .blockr-warning {
  color: #f22613;
  font-weight: 700;
  text-shadow: 1px 1px 1px #666;
}
</style>

<script>
export default {
  name: 'ProductDetails',
  data: function () {
    return {
      item: {},
      showCurrencyWarning: false
    }
  },
  created () {
    this._fetchItem()
  },
  methods: {
    onClickPay (mItem, sCurrency) {
      if (sCurrency !== 'zec') {
        this.showCurrencyWarning = true
      } else {
        this._buyItem(mItem.product_id, sCurrency)
      }
    },
    _fetchItem () {
      this.$http.get(`/api/v1/product/${this.$route.params.id}`).then(
        response => {
          this.item = response.body
        },
        () => {}
      )
    },

    _buyItem (sPoductId, sCurrency) {
      const mCurrency = {
        zec: 'zcash',
        btc: 'bitcoin',
        eth: 'ethereum',
        eur: 'euro'
      }

      const key = mCurrency[sCurrency]
      this.$http.get(`/api/v1/buy/${key}/${sPoductId}`).then(
        response => {
          const address = response.body[`${key}_address`]
          this.$router.push(`/transaction/${key}/${address}`)
        },
        () => {}
      )
    }
  }
}
</script>
