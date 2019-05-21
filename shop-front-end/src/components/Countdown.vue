<template>
  <span>
      <b v-if="hours">{{ hours | two_digits }} :</b>
      <b>{{ minutes | two_digits }} :</b>
      <b>{{ seconds | two_digits }}</b>
      <span v-if="hours">{{ $t("label.hours") }}</span>
      <span v-else>{{ $t("label.minutes") }}</span>
  </span>
</template>

<script>
export default {
  props: {
    from: {
      type: Number,
      required: true
    },
    to: {
      type: Number,
      required: true
    }
  },
  data () {
    return {
      now: this.from
    }
  },
  mounted () {
    const vm = this
    function checkTime () {
      vm.now = Math.trunc(new Date().getTime() / 1000)
      if (vm.to && vm.to - vm.now <= 0) {
        window.clearInterval(intervalId)
        vm.$emit('countdown-expired')
      }
    }
    checkTime()
    const intervalId = window.setInterval(() => {
      checkTime()
    }, 1000)
  },
  computed: {
    seconds () {
      if (this.now) {
        return Math.max(0, (this.to - this.now) % 60)
      } else {
        return 0
      }
    },
    minutes () {
      if (this.now) {
        return Math.max(0, Math.trunc((this.to - this.now) / 60) % 60)
      } else {
        return 0
      }
    },
    hours () {
      if (this.now) {
        return Math.max(0, Math.trunc((this.to - this.now) / 60 / 60) % 24)
      } else {
        return 0
      }
    }
  }
}
</script>
