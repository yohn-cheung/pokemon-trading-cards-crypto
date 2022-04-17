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
        v-for="(item, index) in results"
        :key="index"
        @click="openPage(item.id)"
      >
        <q-img :src="item.images.small">
          <div class="absolute-bottom text-h6">{{ item.name }}</div>
        </q-img>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, reactive } from "vue";
import { useRouter, useRoute } from "vue-router";
import { useQuasar } from "quasar";

import pokemon from "pokemontcgsdk";

export default defineComponent({
  name: "IndexPage",
  setup() {
    pokemon.configure({ apiKey: process.env.POKEMON_API });
    let search = ref("");
    let results = ref([]);

    const router = useRouter();
    const route = useRoute();

    const $q = useQuasar();

    function openPage(id) {
      router.push(`/result/${id}`);
    }

    function getResults() {
      if (search.value === "") return;

      $q.loading.show();

      pokemon.card
        .where({ q: `name:${search.value}*` })
        .then((result) => {
          if (result.data.length === 0) {
            showNotification();
          } else {
            results.value = result.data;
          }

          $q.loading.hide();
        })
        .catch((error) => {
          $q.loading.hide();
          showNotification();
        });
    }

    function showNotification() {
      $q.notify({
        progress: true,
        position: "top",
        message: "No result, try again",
      });
    }

    return {
      search,
      results,
      getResults,
      openPage,
    };
  },
});
</script>

<style lang="sass" scoped>
.my-card
  width: 100%
  max-width: 30%
</style>
