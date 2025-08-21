
export default function () {
  this.route("shoptest", { path: "/shop" });
  this.route("shoptest-admin", { path: "/shop/admin" });
  this.route("adminPlugins.shoptest", { path: "/admin/plugins/shop" });
}
