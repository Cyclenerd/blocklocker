// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import i18n from './i18n'

import VueResource from 'vue-resource'
import VueMaterial from 'vue-material'
import 'vue-material/dist/vue-material.css'
import 'vue-material/dist/theme/default-dark.css'

import './assets/material_icons.css'
import './assets/roboto.css'

Vue.config.productionTip = false
Vue.use(VueMaterial)
Vue.use(VueResource)
Vue.filter('two_digits', function (value) {
  if (value.toString().length <= 1) {
    return '0' + value.toString()
  }
  return value.toString()
})

/* eslint-disable no-new */
Vue.prototype.$eventBus = new Vue()

new Vue({
  el: '#app',
  router,
  i18n,
  components: { App },
  template: '<App/>'
})
