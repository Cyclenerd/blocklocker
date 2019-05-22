<template>
  <div id="app">
    <!-- Dialog: Vendor state OK -->
    <md-dialog-alert
      :md-active.sync="showDoorWorking"
      :md-content="$t('message.doorWorking', { location: doorLocation })"
      :md-confirm-text="$t('button.close')" />

    <!-- Dialog: Vendor state NOT OK -->
    <md-dialog-alert
      :md-active.sync="showDoorNotWorking"
      :md-content="$t('message.doorNotWorking')"
      :md-confirm-text="$t('button.close')" />

    <!-- Dialog: Help page -->
    <md-dialog :md-active.sync="showHelpDialog">
      <md-dialog-title>{{ $t('button.about')}}</md-dialog-title>

      <md-tabs md-dynamic-height>
        <md-tab :md-label="$t('tab.faq')">
          <Faq></Faq>
        </md-tab>
        <md-tab :md-label="$t('tab.imprint')">
          <Imprint></Imprint>
        </md-tab>
      </md-tabs>

      <md-dialog-actions>
        <md-button class="md-primary" @click="showHelpDialog = false">{{ $t('button.close') }}</md-button>
      </md-dialog-actions>
    </md-dialog>

    <!-- Main Page -->
    <md-toolbar class="md-dense" md-elevation="1">
      <h3 class="md-title" style="flex: 1">BLOCKLOCKER</h3>
      <md-button v-if="doorWorking" class="md-icon-button" @click="showDoorWorking = true">
        <md-icon>check_circle_outline</md-icon>
      </md-button>
      <md-button v-if="!doorWorking" class="md-icon-button" @click="showDoorNotWorking = true">
        <md-icon>error_outline</md-icon>
      </md-button>
      <md-button @click="showHelpDialog = true">
        <md-icon>live_help</md-icon>
        {{ $t('button.about') }}
      </md-button>
    </md-toolbar>

    <router-view/>
  </div>
</template>

<style lang="scss" scoped>
@font-face {
  font-family: Arcade;
  src: url(./assets/arcade.ttf);
}

.md-toolbar > .md-title {
  font-family: Arcade;
  font-size: 2rem;
}

.bl-quote {
  margin: 1rem 0;
  padding: 0.25rem 0.5rem;
  overflow: hidden;
  background-color: #222;
  border-left: 0.25rem solid #448aff;
}
</style>

<script>
import Faq from './components/Faq.vue'
import Imprint from './components/Imprint.vue'
export default {
  name: 'app',
  components: { Faq, Imprint },
  data: function () {
    return {
      doorWorking: undefined,
      doorLocation: undefined,
      showDoorNotWorking: false,
      showDoorWorking: false,
      showHelpDialog: false
    }
  },
  created () {
    this._fetchDoorState()
    window.setInterval(() => {
      this._fetchDoorState()
    }, 10 * 1000)
    if (!this.$router.currentRoute.name) {
      this.$router.push('/products')
    }
  },
  methods: {
    _fetchDoorState () {
      this.$http.get('/api/v1/door').then(response => {
        this.doorWorking = response.body.status === 'OK'
        this.doorLocation = response.body.location
      }).catch(() => {
        // if the vending machine previously worked or the app is initially starting, show the info dialog once
        if (this.doorWorking === true || typeof this.doorWorking === 'undefined') {
          this.showDoorNotWorking = true
        }
        this.doorWorking = false
        this.doorLocation = ''
      })
    }
  }
}
</script>
