<template>
  <q-page class="q-pa-md row items-start">
    <q-card class="full-width" flat>
      <q-card-section horizontal v-if="pokemonData">
        <q-img class="col-4" :src="pokemonData.images.small" />
        <q-card-section class="col-8">
          <div class="text-h5 q-mt-sm q-mb-xs">{{ pokemonData.name }}</div>
          <div class="text-caption">
            <div class="row">
              <div class="col-6">
                Release date: {{ pokemonData.set.releaseDate }}
              </div>
              <div class="col-6">Series: {{ pokemonData.set.series }}</div>
              <div class="col-12">
                Latest update: {{ pokemonData.tcgplayer.updatedAt }}
              </div>
            </div>
          </div>
          <q-separator class="q-my-md" />
          <div
            class="text-caption"
            v-if="pokemonData.tcgplayer.prices.holofoil"
          >
            <div class="text-h6 q-mt-sm q-mb-xs">
              <a
                :href="pokemonData.tcgplayer.url"
                target="_blank"
                rel="noopener noreferrer"
                >Prices from TCG Player</a
              >
            </div>
            <q-chip icon="event" square class="q-my-sm q-mx-none" size="sm"
              >Updated at {{ pokemonData.tcgplayer.updatedAt }}</q-chip
            >

            <div class="row">
              <div class="col-3">
                HOLOFOIL Market <br />${{
                  pokemonData.tcgplayer.prices.holofoil.market
                }}
              </div>
              <div class="col-3">
                HOLOFOIL Low <br />${{
                  pokemonData.tcgplayer.prices.holofoil.low
                }}
              </div>
              <div class="col-3">
                HOLOFOIL Mid <br />${{
                  pokemonData.tcgplayer.prices.holofoil.mid
                }}
              </div>
              <div class="col-3">
                HOLOFOIL High <br />${{
                  pokemonData.tcgplayer.prices.holofoil.high
                }}
              </div>
            </div>
          </div>
          <div class="text-caption" v-if="pokemonData.cardmarket.prices">
            <div class="text-h6 q-mt-sm q-mb-xs">
              <a
                :href="pokemonData.cardmarket.url"
                target="_blank"
                rel="noopener noreferrer"
              >
                Prices from card market
              </a>
            </div>
            <q-chip icon="event" square class="q-my-sm q-mx-none" size="sm"
              >Updated at {{ pokemonData.cardmarket.updatedAt }}</q-chip
            >

            <div class="row">
              <div class="col-3">
                Price trend<br />€{{ pokemonData.cardmarket.prices.trendPrice }}
              </div>
              <div class="col-3">
                1 DAY AVERAGE <br />€{{ pokemonData.cardmarket.prices.avg1 }}
              </div>
              <div class="col-3">
                7 DAY AVERAGE <br />€{{ pokemonData.cardmarket.prices.avg7 }}
              </div>
              <div class="col-3">
                30 DAY AVERAGE <br />€{{ pokemonData.cardmarket.prices.avg30 }}
              </div>
            </div>
          </div>
          <q-separator class="q-my-md" />
          <div class="text-caption">
            <q-table
              class="table"
              style="height: 250px; max-height: 300px"
              title="Latest cryptocurrency"
              :rows="rows"
              :columns="columns"
              row-key="index"
              :hide-pagination="true"
              :flat="true"
              dense
              :filter="filter"
              virtual-scroll
              v-model:pagination="pagination"
              :rows-per-page-options="[0]"
              @row-click="openDialog"
            >
              <template v-slot:top-right>
                <q-input
                  borderless
                  dense
                  debounce="300"
                  v-model="filter"
                  placeholder="Search"
                >
                  <template v-slot:append>
                    <q-icon name="search" />
                  </template>
                </q-input>
              </template>
            </q-table>
          </div>
        </q-card-section>
      </q-card-section>
    </q-card>

    <q-dialog v-model="dialog" persistent>
      <q-card style="width: 700px; max-width: 80vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">{{ payment.title }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-gutter-md">
          <q-input
            v-model="payment.price"
            disable
            dense
            filled
            label="current price in US dollar"
          />
          <q-input
            v-model="payment.rateinUSD"
            disable
            dense
            filled
            label="current rate in US dollar"
          />

          <q-select
            filled
            v-model="payment.selectedOption"
            :options="payment.options"
            label="Choose a market"
            dense
          />
          <q-input
            v-if="payment.selectedOption === 'Card market'"
            v-model="payment.total"
            disable
            dense
            filled
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="primary" v-close-popup />
          <q-btn flat label="Pay" color="primary" @click="startPayment" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { defineComponent, reactive, ref } from "vue";
import axios from "axios";

import pokemon from "pokemontcgsdk";

export default defineComponent({
  name: "ResultPage",
  props: ["id"],
  setup(props) {
    pokemon.configure({ apiKey: process.env.POKEMON_API });
    const columns = reactive([
      {
        name: "index",
        label: "#",
        field: "index",
        align: "left",
      },
      {
        name: "name",
        required: true,
        align: "left",
        label: "Name",
        field: "name",
      },
      {
        name: "price",
        required: true,
        align: "left",
        label: "Price",
        field: "price",
      },
    ]);
    const rows = reactive([]);
    const pagination = ref({
      rowsPerPage: 0,
    });

    let pokemonData = ref(null);

    const filter = ref("");
    let dialog = ref(false);
    let rateUsd = ref("");

    let payment = reactive({
      title: "",
      price: "",
      selectedOption: null,
      options: ["Card market"],
      amount: 1,
      rateinUSD: "",
      total: "",
    });

    function getPokemonData() {
      pokemon.card
        .find(`${props.id}`)
        .then((card) => {
          pokemonData.value = card;
        })
        .catch((error) => {
          console.log("error: ", error);
        });
    }

    function getEuroRate() {
      axios
        .get("https://api.coincap.io/v2/rates/euro")
        .then((result) => {
          const formatter = new Intl.NumberFormat("en-US", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          });

          rateUsd.value = formatter.format(result.data.data.rateUsd);
        })
        .catch((error) => console.log("error: ", error));
    }

    function getCurrencies() {
      axios
        .get("https://api.coincap.io/v2/assets") // ids bitcoin/ethereum/polygon/solana/cardano // .get("https://api.coincap.io/v2/assets?limit=10")
        .then((result) => {
          const currencies = result.data.data;

          currencies.forEach((currency) => {
            const formatter = new Intl.NumberFormat("en-US", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            });

            const object = {
              index: currency.rank,
              name: currency.name,
              price: `$${formatter.format(currency.priceUsd)}`,
              id: currency.id,
            };
            rows.push(object);
          });
        })
        .catch((error) => console.log("error: ", error));
    }

    function openDialog(evt, row, index) {
      const formatter = new Intl.NumberFormat("de-DE", {
        style: "currency",
        currency: "EUR",
      });

      dialog.value = true;
      payment.title = row.name;
      payment.price = row.price;
      payment.rateinUSD = `$${rateUsd.value}`;
      const totalPrice =
        pokemonData.value.cardmarket.prices.trendPrice * rateUsd.value;
      // payment.total = `€${totalPrice}`;
      payment.total = formatter.format(totalPrice);
    }

    function startPayment() {
      // start meta mask and do the payment
      dialog.value = false;
    }

    return {
      pokemonData,
      columns,
      rows,
      pagination,
      filter,
      getPokemonData,
      getCurrencies,
      getEuroRate,
      openDialog,
      dialog,
      payment,
      rateUsd,
      startPayment,
    };
  },
  created() {
    this.getPokemonData();
    this.getCurrencies();
    this.getEuroRate();
  },
});
</script>

<style lang="sass">
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
