<template>
  <q-page class="q-pa-md row items-start">
    <q-card class="full-width" flat v-if="pokemonData">
      <q-card-section horizontal>
        <q-img
          class="col-4"
          :src="pokemonData.images.small"
          :ratio="4 / 3"
          :alt="pokemonData.name"
          position="0 0"
        />
        <q-list dense class="full-width">
          <q-item>
            <q-item-section>
              <q-item-label class="text-subtitle1 text-weight-bold">
                {{ pokemonData.name }}
              </q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label>
                Release date:
                {{ pokemonData.set.releaseDate }}
              </q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label> Name: {{ pokemonData.set.name }} </q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label>
                Series: {{ pokemonData.set.series }}
              </q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label>
                {{ pokemonData.flavorText }}
              </q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>

      <q-list
        dense
        class="full-width q-py-md"
        v-if="pokemonData.tcgplayer.prices"
      >
        <q-item-label header
          ><a
            :href="pokemonData.tcgplayer.url"
            target="_blank"
            rel="noopener noreferrer"
            >Prices from TCG Player</a
          ></q-item-label
        >

        <Item
          :tcgplayer="pokemonData.tcgplayer.prices"
          @selected-price="openDialog"
        />
      </q-list>
    </q-card>

    <q-dialog v-model="stateDialog" persistent>
      <q-card style="width: 700px; max-width: 80vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">
            Confirmation payment - {{ selectedPrice.type }} -
            {{ selectedPrice.key }}
          </div>
          <q-space />
          <q-btn icon="close" flat round dense @click="closeDialog" />
        </q-card-section>

        <q-card-section class="q-gutter-md">
          <q-input
            v-model="selectedPrice.cardPrice"
            disable
            dense
            filled
            label="Price of card in dollar"
          />
          <q-select
            filled
            v-model="payment.selectedCurrency"
            :options="payment.options"
            label="Choose a cryptocurrency"
            dense
          />

          <q-input
            v-if="payment.selectedCurrency !== ''"
            v-model="payment.selectedCurrency.price"
            disable
            dense
            filled
            label="current price in US dollar"
          />
          <q-input
            v-if="payment.selectedCurrency !== ''"
            v-model="payment.totalAmount"
            disable
            dense
            filled
            label="Amount of coins to pay"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="primary" @click="closeDialog" />
          <q-btn
            flat
            :disabled="payment.selectedCurrency === ''"
            label="Pay"
            color="primary"
            @click="startPayment"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import pokemon from "pokemontcgsdk";
import { ethers } from "ethers";
import { contractABI, contractAddress } from "../utils/constants";
import Item from "../components/Item.vue";

export default {
  name: "ResultPage",
  props: ["id"],
  components: {
    Item,
  },
  data() {
    return {
      pokemonData: null,
      selectedPrice: null,
      stateDialog: false,
      payment: {
        selectedCurrency: "",
        options: [],
        totalAmount: "",
      },
    };
  },
  created() {
    pokemon.configure({ apiKey: process.env.POKEMON_API });
    this.getPokemonData();
    this.getCurrencies();
  },
  methods: {
    getPokemonData() {
      pokemon.card
        .find(`${this.id}`)
        .then((card) => {
          this.pokemonData = card;
        })
        .catch((error) => {
          console.log("error: ", error);
          this.$q.notify({
            progress: true,
            position: "top",
            type: "negative",
            message: "Something went wrong, refresh the page again",
          });
        });
    },
    openDialog(object) {
      this.selectedPrice = object;
      this.stateDialog = true;
    },
    closeDialog() {
      this.payment.selectedCurrency = "";
      this.stateDialog = false;
    },
    getCurrencies(data) {
      this.$axios
        .get("https://api.coincap.io/v2/assets") // ids bitcoin/ethereum/polygon/solana/cardano // .get("https://api.coincap.io/v2/assets?limit=10")
        .then((result) => {
          const currencies = result.data.data;

          currencies.forEach((currency) => {
            const formatter = new Intl.NumberFormat("en-US", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            });

            const formattedPrice = formatter.format(currency.priceUsd);
            let coins = data ? (data.price /= currency.priceUsd) : false;

            const object = {
              label: currency.name,
              value: formattedPrice,
              price: currency.priceUsd,
            };
            this.payment.options.push(object);
          });
        })
        .catch((error) => console.log("error: ", error));
    },
    async startPayment(row) {
      // start meta mask and do the payment
      this.$q.loading.show();
      try {
        const { ethereum } = window;
        if (ethereum) {
          // create provider object from ethers library, using ethereum object injected by metamask

          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const PokemonCardContract = new ethers.Contract(
            contractAddress,
            contractABI.abi,
            signer
          );

          const parsedAmount = ethers.utils.parseEther(
            this.payment.totalAmount.toString()
          );

          const overrides = {
            value: parsedAmount, // sending one ether
          };

          const cardTxn = await PokemonCardContract.buyCard(
            this.pokemonData.id,
            this.pokemonData.name,
            this.pokemonData.set.series,
            this.pokemonData.images.small,
            parsedAmount._hex,
            overrides
          );
          console.log("Mining...", cardTxn.hash);
          await cardTxn.wait();
          console.log("Mined -- ", cardTxn.hash);
          this.$q.loading.hide();
          this.$q.notify({
            progress: true,
            position: "top",
            type: "positive",
            message: "Payment succesfull, enjoy your Pokemon card",
          });
          this.payment.selectedCurrency = "";
          this.stateDialog = false;
        }
      } catch (error) {
        this.$q.loading.hide();
        this.payment.selectedCurrency = "";
        this.stateDialog = false;
        this.$q.notify({
          progress: true,
          position: "top",
          type: "negative",
          message: "Payment failed, try again",
        });
      }
    },
  },
  watch: {
    "payment.selectedCurrency": function (val) {
      this.payment.totalAmount =
        this.selectedPrice.cardPrice / this.payment.selectedCurrency.price;
    },
  },
};
</script>

<style lang="sass" scoped>
.table
  /* height or max-height is important */
  height: 410px

  .q-table__top,
  .q-table__bottom,
  thead tr:first-child th /* bg color is important for th; just specify one */
    background-color: #fff

  thead tr th
    position: sticky
    z-index: 1
  /* this will be the loading indicator */
  thead tr:last-child th
    /* height of all previous header rows */
    top: 48px
  thead tr:first-child th
    top: 0
</style>
