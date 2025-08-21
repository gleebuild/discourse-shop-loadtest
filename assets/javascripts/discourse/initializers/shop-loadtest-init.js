
import { apiInitializer } from "discourse/lib/api";
export default apiInitializer("1.40.0", (api) => {
  const inject = Discourse.SiteSettings.shop_test_nav_inject;
  if (inject === "nav_api" || inject === "both") {
    api.addNavigationBarItem({
      name: "shop",
      displayName: "商城",
      href: "/shop",
      title: "商城",
      forceActive: (_c, _a, router) => (router.currentRouteName || "").startsWith("shop"),
    });
    api.addNavigationBarItem({
      name: "shop_admin",
      displayName: "管理",
      href: "/shop/admin",
      title: "管理",
      displayCondition: () => !!api.getCurrentUser?.()?.staff,
      forceActive: (_c, _a, router) => (router.currentRouteName || "").startsWith("shop-admin"),
    });
    console.log("[loadtest] injected nav via api.addNavigationBarItem");
  }
});
