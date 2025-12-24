# Dotfiles Roadmap

Planned improvements and ideas for the dotfiles repository.

---

## How Screen Layout Works

### Two Systems: autorandr vs xrandr

| Aspect | autorandr | xrandr |
|--------|-----------|--------|
| **Location** | `autorandr-screenlayout/.config/autorandr/` | `xrandr-screenlayout/.screenlayout/` |
| **Activation** | Automatic (on monitor plug/unplug) | Manual (run script directly) |
| **Profile format** | `config` + `setup` files per profile | Single `.sh` script per layout |
| **Detection** | Matches monitors by EDID in `setup` file | N/A - you choose which script to run |

### The DualUp Mode Dependency

The LG DualUp monitor uses a non-standard resolution (1920x2160) that xrandr doesn't recognize automatically. A custom mode called `DualUpMode` must be created.

**Important:** autorandr profiles that use `DualUpMode` (e.g., `notebook-bigmonitor-dualup`) **do not create the mode** - they just reference it in the `config` file:

```
mode DualUpMode
```

The mode must be created by xrandr first:

```bash
cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode DualUpMode
xrandr --addmode DP-3-2 DualUpMode
```

**How it currently works:**
1. xrandr script runs → creates `DualUpMode` (persists until reboot)
2. autorandr triggers later → finds mode exists → applies successfully

**Potential issue:** After a fresh boot, if autorandr triggers before any xrandr script runs, profiles using `DualUpMode` will fail.

**Future fix:** Create the mode at X startup (see planned improvements below).

---

## Planned Improvements

## Screen Layout Management

### DualUp Mode Helper Script
**Status:** Planned

The LG DualUp monitor (1920x2160) requires a custom xrandr mode that isn't recognized automatically. Currently, each xrandr script that uses the DualUp monitor duplicates the mode creation logic:

```bash
DUALUPMODE="DualUpMode"
if ! $(xrandr --current | grep -q $DUALUPMODE); then
  cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode $DUALUPMODE
  xrandr --addmode DP-3-2 $DUALUPMODE
fi
```

**Proposal:** Create a shared helper script that all DualUp-related scripts can source:

```bash
# ~/.screenlayout/dualup-mode-helper.sh
ensure_dualup_mode() {
  local output="${1:-DP-3-2}"
  if ! xrandr --current | grep -q "DualUpMode"; then
    cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode DualUpMode
  fi
  xrandr --addmode "$output" DualUpMode 2>/dev/null || true
}
```

Scripts would then use:
```bash
source ~/.screenlayout/dualup-mode-helper.sh
ensure_dualup_mode DP-3-2
xrandr --output DP-3-2 --mode DualUpMode ...
```

**Benefits:**
- Single source of truth for the DualUp mode logic
- Easier to update if the monitor or output port changes
- New scripts don't need to copy-paste the boilerplate

**Files affected:**
- `xrandr-screenlayout/.screenlayout/bigmonitor-dualup-resized.sh`
- `xrandr-screenlayout/.screenlayout/notebook-bigmonitor-dualup-resized-left.sh`
- `xrandr-screenlayout/.screenlayout/notebook-bigmonitor-dualup-resized-right.sh` (currently missing the check)

---

## Documentation

### Screen Layout README
**Status:** Planned

Add documentation explaining:
- Difference between `autorandr-screenlayout/` (automatic) and `xrandr-screenlayout/` (manual)
- How autorandr detects and switches profiles
- Naming convention for profiles/scripts
- The DualUp custom mode requirement
