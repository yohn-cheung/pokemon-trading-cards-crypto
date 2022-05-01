<template>
  <div v-for="(item, key, index) in prices" :key="index">
    <q-item-label header class="text-weight-bold"
      >{{ key }} - click on the price to buy</q-item-label
    >
    <q-item>
      <q-item-section top @click="rowPrice('low', item.low, key)" class="hover">
        <span class="text-weight">Low: ${{ item.low }}</span>
      </q-item-section>
      <q-item-section top @click="rowPrice('mid', item.mid, key)" class="hover">
        <span class="text-weight">Mid: ${{ item.mid }}</span>
      </q-item-section>
      <q-item-section
        top
        @click="rowPrice('high', item.high, key)"
        class="hover"
      >
        <span class="text-weight">High: ${{ item.high }}</span>
      </q-item-section>
      <q-item-section
        top
        @click="rowPrice('market', item.market, key)"
        class="hover"
      >
        <span class="text-weight">Market: ${{ item.market }}</span>
      </q-item-section>
    </q-item>
    <q-separator spaced />
  </div>
</template>
<script>
import { defineComponent, reactive, ref } from "vue";

export default defineComponent({
  name: "ItemCompoment",
  emits: ["selectedPrice"],
  props: ["tcgplayer"],
  setup(props, ctx) {
    const prices = Object.entries(props.tcgplayer).reduce(
      (obj, [_key, _value]) => Object.assign(obj, { [_key]: _value }),
      {}
    );

    function rowPrice(type, price, key) {
      const object = {
        type: type,
        cardPrice: price,
        key: key,
      };
      ctx.emit("selectedPrice", object);
    }

    return { prices, rowPrice };
  },
});
</script>

<style lang="sass" scoped>
.hover:hover
  cursor: pointer
</style>
