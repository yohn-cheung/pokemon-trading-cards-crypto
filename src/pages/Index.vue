<template>
  <q-page>
    <div class="q-pa-md">
      <q-input
        clearable
        clear-icon="close"
        filled
        v-model="search"
        label="Search Pokemon"
        @keydown.enter.prevent="getResults"
      >
        <template v-slot:after>
          <q-btn round dense flat icon="search" @click="getResults" />
        </template>
      </q-input>
    </div>

    <div class="q-pa-md row items-start q-gutter-md" v-if="results.length > 0">
      <q-card
        class="my-card"
        flat
        bordered
        v-for="(item, index) in results"
        :key="index"
        @click="openPage(item.id)"
      >
        <q-card-section horizontal>
          <q-img
            class="col-5"
            :src="item.images.small"
            :ratio="4 / 3"
            :alt="item.name"
            position="0 0"
          />
          <q-list dense>
            <q-item>
              <q-item-section>
                <q-item-label class="text-subtitle1 text-weight-bold">
                  {{ item.name }}
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section caption>
                <q-item-label>
                  Release date: {{ item.set.releaseDate }}
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section caption>
                <q-item-label> Series: {{ item.set.series }} </q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import pokemon from "pokemontcgsdk";

export default {
  name: "IndexPage",
  data() {
    return {
      search: "",
      results: [],
    };
  },
  created() {
    pokemon.configure({ apiKey: process.env.POKEMON_API });
  },
  methods: {
    openPage(id) {
      this.$router.push(`/result/${id}`);
    },
    getResults() {
      if (this.search === "") return;

      this.$q.loading.show();

      pokemon.card
        .where({ q: `name:${this.search}*` })
        .then((result) => {
          if (result.data.length === 0) {
            showNotification();
          } else {
            this.results = result.data;
          }

          this.$q.loading.hide();
        })
        .catch(() => {
          this.$q.loading.hide();
          showNotification();
        });
    },
    showNotification() {
      this.$q.notify({
        progress: true,
        position: "top",
        type: "negative",
        message: "No result, try again",
      });
    },
  },
};
</script>

<style lang="sass" scoped>
.my-card
  width: 100%
</style>
