# Store POS Pro 🛒

A lightweight, modern Point of Sale (POS) and inventory management web application built with Flutter.

🔗 **Live Demo:** [Launch Store POS Pro](https://abelbino30-commits.github.io/shop-manager/)

---

## ⚡ Features

- **Billing & Register:** Rapid item entry, real-time GST (5%) calculations, and dynamic subtotaling.
- **Dual Payment Workflows:** 
  - **Cash:** Exact cash settlement and change due calculations.
  - **UPI / QR:** Dynamic UPI QR generation for instant payments.
- **Inventory Tracking:** Real-time stock counts, quick restock controls (`+5`, `+10`, `+25`), and low-stock alerts.
- **Shelf-Life Management:** Automatic expiry countdowns and sales guards to prohibit expired items.
- **Receipt Generation:** In-app formatted ASCII thermal bill modal.
- **Keyboard Shortcuts:** Built for cashiers (`F1` Cash, `F2` UPI, `F3` Exact, `F4` Clear, `F5` Stock, `F9` Settle).

---

## 🛠️ Built With

- **Flutter / Dart**
- **Material 3 UI**
- **GitHub Pages** (Hosting & Continuous Deployment)

---

## 🚀 Running Locally

```bash
git clone [https://github.com/abelbino30-commits/shop-manager.git](https://github.com/abelbino30-commits/shop-manager.git)
cd shop_manager
flutter pub get
flutter run -d chrome
