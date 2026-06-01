<div align="center">

# 🛒 Mizu SmartShop (v1.4.1)

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
- 7 built-in languages (EN, DE, ES, FR, PL, PT, TR, IT)
- Unlimited shops with custom items & images
- Per-item pricing, categories & max quantities

</td>
</tr>
<tr>
<td width="50%">

### 🔒 Access Control
- Job- and gang-restricted shops (e.g. Police Armory / gang stash)
- Grade-locked items (minimum job rank)
- Multi-job and multi-gang support per shop
- Automatic blip updates on job/gang change

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
<tr>
<td colspan="2">

### 📦 Item Picker (v1.2.0)
- Browse all registered items from your framework directly in the admin panel
- Auto-populates from QBCore Shared Items, ESX database, or QBox items
- Search & filter by item name or label
- Selecting an item auto-fills both internal name and display label

</td>
</tr>
<tr>
<td colspan="2">

### 📈 Dynamic Pricing (v1.3.0)
- Prices fluctuate automatically within a configurable range per item (`minPrice` / `maxPrice`)
- Toggle dynamic pricing on or off per shop via admin panel or config
- Adjustable refresh interval per shop (`DynamicPriceInterval`) or globally via `Config.DynamicPriceInterval`
- Configurable price range percentage (`DynamicPriceRange`) as fallback when no min/max is set
- Dynamic prices displayed in orange with animated icon in the shop UI
- Settings persist across script restarts via `saved_shops.json`

</td>
</tr>
<tr>
<td colspan="2">

### 🐧 Cross-Platform Compatibility (v1.3.1)
- Full Linux server support - all image paths normalized to be case-sensitive & OS-agnostic
- Resource loads correctly on both Windows and Linux FiveM servers without manual path adjustments

</td>
</tr>
<tr>
<td colspan="2">

### 📋 Premade Config (v1.3.2)
- `config.lua` comes pre-filled with all standard GTA V shop locations - ready to use out of the box
- `defaultlocations.md` lists all available shop locations as an additional reference
- Covers 24/7, LTD Gasoline, Rob's Liquor, Hardware Stores, Ammunation, Weedshop, Sea Word, Leisure Shop, Police & Ambulance Armory, Mechanic Shops, Benny's, Beeker's Garage, Prison Canteen & Black Market
- No manual coordinate conversion needed — copy individual entries from `defaultlocations.md` into your `config.lua` as needed
- Admin panel (`/smartshopedit`) now lists shops sorted alphabetically by shop ID

</td>
</tr>
<tr>
<td colspan="2">

### 🏷️ Item Metadata Support (v1.3.3)
- Optional `metadata` field per item - fully backwards compatible, items without it work exactly as before
- Metadata is passed directly to the inventory system on purchase (`AddItem`)
- Explicitly supported inventory systems: qb-inventory (QBCore), lj-inventory (QBCore), ox_inventory (QBCore, ESX & QBox), qs-inventory (QBCore/ESX), codem-inventory (QBCore/ESX), standard ESX (metadata ignored gracefully)
- Other inventory systems are not explicitly handled - metadata will not be passed at the moment
- Useful for weapons with serial numbers, expiry dates, vehicle keys, licenses, custom labels and more

</td>
</tr>
<tr>
<td colspan="2">

### 🔑 License System (v1.4.0)
- Optional `license` field per item — items are **completely hidden** in the shop UI if the player doesn't hold the required license
- Server-side validation on checkout as a second layer of protection — even if a client bypasses the UI, unlicensed items are rejected
- Define license types once in `Config.Licenses` with a human-readable label and metadata key — reference them on any item by key
- Supports all frameworks: QBCore & QBox check `player.metadata.licences`, ESX checks `getMeta('licences')` with a `getLicense` fallback for older setups; Standalone shows all items
- **Inventory item fallback**: holding the license item in inventory (e.g. `id_card`) is also accepted — no metadata entry required
- **Ownership verification**: items with a `citizenid` in their metadata are checked against the player's own — picking up another player's dropped ID card does **not** grant access; supported for ox_inventory, QBCore/QBox default inventory and ESX
- License field available in the in-game admin panel (`/smartshopedit`) — styled custom dropdown matching the job restriction selector
- Admin item list shows a document badge (`fa-file-alt`) next to license-restricted items; shop UI shows the same badge on item cards for players who hold the required license
- Discord / Fivemanage logs include which licenses were required for a given purchase

</td>
</tr>
</table>

### 🛠️ In-Game Admin Panel

> Create, edit, and delete shops without ever touching a config file or restarting your server.

- `/smartshopedit` — Full admin UI with shop grid, config/dynamic/override badges
- Edit shop settings: name, coords, blip, marker, job restrictions
- Add, edit & remove items with built-in image picker
- Item name picker — browse all registered framework items (QBCore/ESX/QBox)
- Dynamic pricing toggle, range & interval settings per shop
- Per-item min/max price configuration for dynamic pricing
- Searchable multi-select job dropdown (auto-populated from framework)
- `/smartshopcreate` — Clone any shop to your current position
- Changes sync instantly to all players & persist via `saved_shops.json`
- Server-side ACE permission checks & input sanitization on all events

### 📊 Logging
- Discord webhook support
- Fivemanage integration
- Purchase tracking with player & item details

### 🏷️ Metadata Examples

**Example 1 — Weapon with serial number:**
```lua
{ name = 'weapon_pistol', label = 'Pistol', price = 2500, image = 'weapon_pistol.png', maxQty = 1, category = 'Weapons',
  metadata = { label = 'Pistol', serial = 'MIZU-' .. math.random(100000, 999999), durability = 100 } },
```

**Example 2 — Item with custom image from another resource (Windows & Linux compatible via `nui://`):**
```lua
{ name = 'weapon_knife', label = 'Combat Knife', price = 800, image = 'weapon_knife.png', maxQty = 1, category = 'Weapons',
  metadata = { label = 'Combat Knife', imageurl = 'nui://mizu_smartshop/html/images/weapon_knife.png', serial = 'MIZU-' .. math.random(100000, 999999) } },
```
> `nui://` paths work identically on Windows and Linux servers - use them whenever referencing images from another resource.

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
