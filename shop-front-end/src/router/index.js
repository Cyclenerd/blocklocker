import Vue from 'vue'
import Router from 'vue-router'
import ProductList from '@/components/ProductList'
import ProductDetails from '@/components/ProductDetails'
import Transaction from '@/components/Transaction'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/products',
      name: 'ProductList',
      component: ProductList
    }, {
      path: '/products/:id',
      name: 'ProductDetails',
      component: ProductDetails
    }, {
      path: '/transaction/:currency/:id',
      name: 'Transaction',
      component: Transaction
    }
  ]
})
