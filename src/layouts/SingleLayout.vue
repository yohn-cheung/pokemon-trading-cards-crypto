<template>
  <q-layout view="lHh Lpr lFf">
    <q-header bordered class="bg-white text-primary">
      <q-toolbar>
        <q-btn flat round dense icon="arrow_back_ios_new" to="/" />
        <q-toolbar-title class="text-center"> Result </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
export default {
  name: "SingleLayout",
};
</script>
