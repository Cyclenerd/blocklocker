<template>
    <div class="md-layout md-alignment-top-left">
        <div   @click="onClickBuy(item)" v-for="item in items" :key="item.product_id" class="md-layout-item md-xlarge-size-20 md-large-size-25 md-medium-size-33 md-small-size-50 md-xsmall-size-100">
            <md-card md-with-hover>
                <md-card-media-cover md-solid>
                    <md-card-media md-ratio="16:9">
                        <img :src="item.product_img_url" :alt="item.product_name">
                    </md-card-media>

                    <md-card-area>
                        <md-card-header>
                            <span  class="md-title">{{item.product_name}}</span>
                            <span  class="md-subhead">{{item.product_price_zec}} ZEC / {{item.product_price_eur}} EUR</span>
                        </md-card-header>
                        <md-card-actions>
                            <md-button class="md-raised" @click="onClickBuy(item)">{{ $t("button.buy") }}</md-button>
                        </md-card-actions>
                    </md-card-area>
                </md-card-media-cover>
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

</style>

<script>
export default {
  name: 'ProductList',
  data: function () {
    return {
      items: null
    }
  },
  created () {
    this._fetchItems()
  },
  methods: {
    onClickBuy: function (item) {
      this.$router.push('/products/' + item.product_id)
    },
    _fetchItems () {
      this.$http.get('/api/v1/shop').then(
        response => {
          this.items = response.body
        },
        () => {}
      )
    }
  }
}
</script>
