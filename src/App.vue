<template>
  <div v-if="!isWalletConnect" class="q-ma-md">
    <q-btn
      class="full-width"
      flat
      color="black"
      label="Connect your metamask wallet"
      @click="connectWallet"
    />
  </div>
  <div v-else>
    <router-view />
  </div>
</template>

<script>
export default {
  name: "App",
  data() {
    return {
      isWalletConnect: false,
    };
  },
  created() {
    this.connectWallet();
  },
  methods: {
    async connectWallet() {
      try {
        const { ethereum } = window;
        if (!ethereum) {
          alert("Must connect to MetaMask!");
          return;
        }
        const myAccounts = await ethereum.request({
          method: "eth_requestAccounts",
        });

        if (myAccounts.length) {
          this.isWalletConnect = true;
        }
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>
