# Liquid-glass implementation spike (E1.2)

Findings from the E1.2 spike: prove out a Flutter implementation for the liquid-glass direction ruled in [ADR 0009](../decisions/0009-liquid-glass-direction.md).

## Chosen approach

Native-first frosted glass, no third-party glass dependency.

- The single primitive is `lib/core/glass/glass_surface.dart` (`GlassSurface`), a `ClipRRect` -> `BackdropFilter` -> tinted `DecoratedBox` stack.
- The filter is `ImageFilter.compose` of a Gaussian blur (sigma 12, from the design system's `--gs-glass-blur: blur(24px)`, CSS radius R = 2·sigma) and a saturation color matrix (`saturate(1.8)`).
- The two ruled intensities map to the dark-theme design tokens in `design/tokens/semantic.css`: `GlassIntensity.modest` uses `--gs-glass-bg` (rgba(24,23,29,.55)) for app-wide floating chrome, `GlassIntensity.heavy` uses `--gs-glass-bg-strong` (rgba(30,29,36,.85)) for overlays.
- **Isolation seam:** `GlassSurface` is the only public boundary; call sites pass `intensity` and `child` and never see the filter. A future refractive implementation (the deferred "liquid" part) replaces `GlassSurface.build` without touching any caller. E1.5's overlay components must compose `GlassSurface` rather than using `BackdropFilter` directly.

Both intensities share one blur; they differ only in tint opacity, which costs nothing extra. Heavier glass is therefore not slower glass; the cost drivers are blur sigma and blurred area.

## Demo and method

`lib/features/glass_demo/glass_demo_screen.dart` scrolls a 400-row list of gradient tiles (busy opaque content, per the "glass never on glass, content stays opaque" guideline) under a modest glass capsule (tab-bar stand-in) and a heavy glass overlay panel (modal stand-in).

Frame times come from `integration_test/glass_perf_test.dart` run in profile mode:

```sh
flutter drive --profile \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/glass_perf_test.dart
```

The test flings the list up and down five times each under four modes (no glass, modest only, heavy only, both) and captures a Dart timeline per mode via `traceAction`; the driver writes one `build/glass_<mode>.timeline_summary.json` per mode with build/raster percentiles.

## Measured behavior (Android emulator)

Environment: AVD `crew-android-35` (Android 15, x86_64, headless), Flutter 3.44.8, profile mode, Impeller (TODO: confirm backend from logcat).

| Mode | avg build ms | 90th build ms | avg raster ms | 90th raster ms | frames > 16 ms budget |
| --- | --- | --- | --- | --- | --- |
| none (baseline) | TODO | TODO | TODO | TODO | TODO |
| modest | TODO | TODO | TODO | TODO | TODO |
| heavy | TODO | TODO | TODO | TODO | TODO |
| both | TODO | TODO | TODO | TODO | TODO |

TODO: verdict paragraph.

### What the emulator can and cannot tell us

All numbers above come from an x86_64 emulator whose GPU work is host-rendered; absolute frame times do not transfer to phone hardware, and the emulator's graphics stack differs from a real device's GPU and driver.
The numbers are useful relatively: the delta between baseline and each glass mode isolates what the glass costs on this rendering stack, and a fundamental jank cliff would still show up here.

**Open item (deferred):** the E1.2 acceptance verdict of 60fps on a mid-range Android reference device is explicitly not claimed here; it needs a profile-mode run of the same benchmark on real hardware once a device is available. Until then, treat the budget below as provisional.

## Performance ceiling and knobs

- The dominant cost is the backdrop blur's full-screen-texture readback per glass region per frame; it scales with blurred area and sigma, not with the number of widgets under it.
- Knobs, in order of preference if real-device numbers miss 60fps:
  1. Reduce blurred area (smaller overlay panels; the capsule bar is already small).
  2. Lower `GlassSurface.blurSigma` (visual fidelity to the token degrades gracefully).
  3. Drop the saturation matrix (keeps the frost, loses the color pop).
  4. Fall back to near-opaque tint without blur for the modest tier (the heavy tier's `.85` tint already hides most detail, so blur matters least there).
- Multiple simultaneous glass regions each pay their own backdrop pass; E1.5 should keep at most one heavy overlay live at a time (which the modal/drawer model already implies).
