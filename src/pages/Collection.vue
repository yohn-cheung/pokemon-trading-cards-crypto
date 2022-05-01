<template>
  <q-page>
    <div v-if="cards.length === 0" class="q-pa-md q-gutter-sm">
      <q-banner class="bg-grey-3">
        You have not yet bought a Pokemon card
      </q-banner>
    </div>
    <div v-else class="q-pa-md row items-start q-gutter-md">
      <q-card
        class="my-card"
        flat
        bordered
        v-for="(card, index) in cards"
        :key="index"
      >
        <q-card-section horizontal>
          <q-img
            class="col-5"
            :src="card.img"
            :ratio="4 / 3"
            :alt="card.name"
            position="0 0"
          />
          <q-list dense>
            <q-item>
              <q-item-section>
                <q-item-label class="text-subtitle1 text-weight-bold">
                  {{ card.name }}
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section caption>
                <q-item-label> Series: {{ card.series }} </q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section caption>
                <q-item-label>
                  Bought for: {{ card.amount }} coin(s)
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section caption>
                <q-item-label>
                  Date of buying: {{ card.timestamp }}
                </q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { ethers } from "ethers";
import { contractABI, contractAddress } from "../utils/constants";

export default {
  name: "CollectionPage",
  data() {
    return {
      cards: [],
    };
  },
  created() {
    this.getAllCards();
  },
  methods: {
    async getAllCards() {
      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const PokemonCardContract = new ethers.Contract(
            contractAddress,
            contractABI.abi,
            signer
          );

          const allCards = await PokemonCardContract.getAllBoughtCards();

          allCards.forEach((card) => {
            const object = {
              id: card.id,
              name: card.name,
              series: card.series,
              img: card.img,
              amount: parseInt(card.amount._hex) / 10 ** 18,
              buyer: card.buyer,
              timestamp: new Date(
                card.timestamp.toNumber() * 1000
              ).toLocaleString(),
            };
            this.cards.push(object);
          });
        }
      } catch (error) {
        console.log("error getting all the cards that you bought: ", error);
        this.$q.notify({
          progress: true,
          position: "top",
          type: "negative",
          message: "Something went wrong, refresh the page",
        });
      }
    },
  },
};
</script>

<style lang="sass" scoped>
.my-card
  width: 100%
</style>
