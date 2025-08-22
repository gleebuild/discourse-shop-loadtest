
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "shop-loadtest-nav",
  initialize() {
    const ss = Discourse?.SiteSettings;
    if (!ss || !ss.shop_test_enabled) return;

    const mode = ss.shop_test_nav_inject; // none | nav_api | nav_connector | both
    if (mode === "none") return;

    const prefix = (ss.shop_test_route_prefix || "shop").replace(/^\/+|\/+$/g, "");

    withPluginApi("1.8.0", (api) => {
      const addApiItem = () => {
        api.addNavigationBarItem({
          name: "shop",
          displayName: "商城",
          href: `/${prefix}`,
          forceActive: () => window.location.pathname.startsWith(`/${prefix}`)
        });
        if (api.getCurrentUser()?.staff) {
          api.addNavigationBarItem({
            name: "shop-admin",
            displayName: "管理",
            href: `/${prefix}/admin`,
            forceActive: () => window.location.pathname.startsWith(`/${prefix}/admin`)
          });
        }
      };

      const addConnector = () => {
        const mount = () => {
          const ul = document.querySelector(".nav-pills, .navigation-container ul, .list-controls .navigation-container ul");
          if (!ul) return;
          if (!ul.querySelector("li.shop-link")) {
            const li = document.createElement("li");
            li.className = "nav-item shop-link";
            const a = document.createElement("a");
            a.textContent = "商城";
            a.href = `/${prefix}`;
            a.setAttribute("data-auto-route", "false");
            li.appendChild(a);
            ul.appendChild(li);

            if (api.getCurrentUser()?.staff) {
              const li2 = document.createElement("li");
              li2.className = "nav-item shop-admin-link";
              const a2 = document.createElement("a");
              a2.textContent = "管理";
              a2.href = `/${prefix}/admin`;
              a2.setAttribute("data-auto-route", "false");
              li2.appendChild(a2);
              ul.appendChild(li2);
            }
          }
        };
        // mount now and on page changes
        mount();
        api.onPageChange(() => setTimeout(mount, 100));
      };

      if (mode === "nav_api" || mode === "both") addApiItem();
      if (mode === "nav_connector" || mode === "both") addConnector();
    });
  }
};
