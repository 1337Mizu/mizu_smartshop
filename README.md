<div align="center">

# 🛒 Mizu SmartShop v1.1.0

### Smart, Sleek & Fully Configurable Shop System for FiveM

[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20ESX%20%7C%20QBox%20%7C%20Standalone-green.svg)]()
[![Price](https://img.shields.io/badge/price-FREE-brightgreen.svg)]()

[![Documentation](https://img.shields.io/badge/Documentation-blue?logo=bookstack&logoColor=white)](https://docs.mizuscripts.com/mizu_smartshop) · [![Preview](https://img.shields.io/badge/Live_Preview-green?logo=googlechrome&logoColor=white)](https://docs.mizuscripts.com/mizu_smartshop/preview) · [![Discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/Td7mTaYaXb)

[![YouTube](https://img.shields.io/badge/▶_Watch_Feature_Overview-red?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/watch?v=M6GW-rdAC8s)

<!-- Add a screenshot or GIF here:
![Preview](https://your-image-url.png)
-->

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🛍️ Shop UI
- Add-to-cart system with real-time totals
- Adjustable quantity per item with max limits
- Category tabs & live search filtering
- Cash or card payment selection

</td>
<td width="50%">

### 🎨 Customization
- 5 color themes (Default, Green, Yellow, Silver, Red)
- 7 built-in languages (EN, DE, ES, FR, PL, PT, TR)
- Unlimited shops with custom items & images
- Per-item pricing, categories & max quantities

</td>
</tr>
<tr>
<td width="50%">

### 🔒 Access Control
- Job-restricted shops (e.g. Police Armory)
- Grade-locked items (minimum job rank)
- Multi-job support per shop
- Automatic blip updates on job change

</td>
<td width="50%">

### 🗺️ Map Integration
- Custom blips per shop (sprite, color, name)
- Optional markers & minimap-only mode
- qb-target / ox_target support
- Marker fallback for standalone

</td>
</tr>
<tr>
<td width="50%">

### 🧍 Shop Peds (v1.1.0)
- Place an NPC at any shop via config or admin panel
- Ped replaces the marker — invincible, frozen, passive
- Optional idle animations via `PedScenario`
- Configurable heading (or "use my direction" in admin)

</td>
<td width="50%">

### 🧍 Ped Admin Tools
- In-game ped model picker with search (~500 models)
- Toggle peds on/off per shop in the admin panel
- Works with qb-target, ox_target & E-key fallback
- Job-restricted peds only visible to authorized players

</td>
</tr>
</table>

### 🛠️ In-Game Admin Panel

> Create, edit, and delete shops without ever touching a config file or restarting your server.

- `/smartshopedit` — Full admin UI with shop grid, config/dynamic/override badges
- Edit shop settings: name, coords, blip, marker, job restrictions
- Add, edit & remove items with built-in image picker
- Searchable multi-select job dropdown (auto-populated from framework)
- `/smartshopcreate` — Clone any shop to your current position
- Changes sync instantly to all players & persist via `saved_shops.json`
- Server-side ACE permission checks & input sanitization on all events

### 📊 Logging
- Discord webhook support
- Fivemanage integration
- Purchase tracking with player & item details

---

## 🚀 Quick Start

**1.** Drop `mizu_smartshop` into your `resources` folder

**2.** Add to `server.cfg`:
```cfg
ensure mizu_smartshop

# Admin permissions
add_ace group.admin command.smartshopcreate allow
add_ace group.admin command.smartshopedit allow
```

**3.** Edit `config.lua` — set your locale, theme, target system & shops

**4.** Restart your server — done! ✅

---

## 📦 Exports

```lua
-- Open a shop by ID
exports['mizu_smartshop']:OpenShop('247_supermarket')

-- Close the active shop
exports['mizu_smartshop']:CloseShop()
```

---

## 🔧 Supported Frameworks

| Framework | Status |
|-----------|--------|
| QBCore | ✅ Auto-detected |
| ESX | ✅ Auto-detected |
| QBox | ✅ Auto-detected |
| Standalone | ✅ Fallback |

| Target System | Status |
|---------------|--------|
| qb-target | ✅ Supported |
| ox_target | ✅ Supported |
| Markers | ✅ Fallback |

---

<div align="center">

## 🔗 Links

[![Documentation](https://img.shields.io/badge/Documentation-blue?logo=bookstack&logoColor=white)](https://docs.mizuscripts.com/mizu_smartshop) · [![Preview](https://img.shields.io/badge/Interactive_Preview-green?logo=googlechrome&logoColor=white)](https://docs.mizuscripts.com/mizu_smartshop/preview) · [![Discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/Td7mTaYaXb) · [![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)](https://github.com/1337Mizu)

---

**GPL-3.0 License** · Made with 💙 by Mizu Scripts

</div>
