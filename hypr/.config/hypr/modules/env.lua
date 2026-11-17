-- Environment variables
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11")

-- GPU: this laptop is AMD iGPU (drives both displays) + NVIDIA dGPU (offload only).
-- Apps render on the AMD GPU by default so the NVIDIA card can power down.
-- Run games / heavy apps on NVIDIA with:  prime-run <app>
-- Removed (were global): __NV_PRIME_RENDER_OFFLOAD, __GLX_VENDOR_LIBRARY_NAME=nvidia,
--   GBM_BACKEND=nvidia-drm, LIBVA_DRIVER_NAME=nvidia (no nvidia VA-API driver installed,
--   so it broke hardware video decode), and the no-op WLR_* / HYPRLAND_LOG_WLR vars.
