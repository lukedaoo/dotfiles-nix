#!/bin/sh

# DP-0 (Left - 4K)
# DP-2 (Middle - 4K - Primary)
# DP-4 (Right - FHD)

xrandr \
  --output DP-0 --mode 3840x2160 --scale 0.6x0.6 --pos 0x0 --rotate normal \
  --output DP-2 --primary --mode 3840x2160 --scale 0.6x0.6 --pos 2304x0 --rotate normal \
  --output DP-4 --mode 1920x1080 --pos 4608x0 --rotate normal
