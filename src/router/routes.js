const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      {
        path: "",
        component: () => import("pages/Index.vue"),
        meta: { title: "Home" },
      },
      {
        path: "/collection",
        component: () => import("pages/Collection.vue"),
        meta: { title: "Collection" },
      },
    ],
  },
  {
    path: "/",
    component: () => import("layouts/SingleLayout.vue"),
    children: [
      {
        path: "result/:id",
        props: true,
        component: () => import("pages/Result.vue"),
      },
    ],
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
