# Liquid-glass implementation spike (E1.2)

Findings from the E1.2 spike: prove out a Flutter implementation for the liquid-glass direction ruled in [ADR 0009](../decisions/0009-liquid-glass-direction.md).

## Chosen approach

Native-first frosted glass, no third-party glass dependency.

- The single primitive is `GlassSurface` in `lib/core/glass/glass_surface.dart`: a `ClipRRect` -> `BackdropFilter` -> tinted `DecoratedBox` stack.
- The filter is `ImageFilter.compose` of a Gaussian blur (sigma 24: the design system's `--gs-glass-blur: blur(24px)`, whose length is the Gaussian standard deviation itself per the Filter Effects spec) and a saturation color matrix (`saturate(1.8)`).
- The two ruled intensities map to the dark-theme design tokens in `design/tokens/semantic.css`: `GlassIntensity.modest` uses `--gs-glass-bg` (rgba(24,23,29,.55)) for app-wide floating chrome, and `GlassIntensity.heavy` uses `--gs-glass-bg-strong` (rgba(30,29,36,.85)) for overlays.
- **Isolation seam:** `GlassSurface` is the only public boundary; call sites pass `intensity` and `child` and never see the filter.
  A future refractive implementation (the deferred "liquid" part of the direction) replaces `GlassSurface.build` without touching any caller.
  E1.5's overlay components must compose `GlassSurface` rather than reaching for `BackdropFilter` directly.

Both intensities share one blur; they differ only in tint opacity, which is free.
Heavier-looking glass is not intrinsically slower glass: the cost drivers are blur sigma and blurred area, not tint.

## Demo and method

`lib/features/glass_demo/glass_demo_screen.dart` scrolls a 400-row list of gradient tiles (busy opaque content, per the brand-glass guideline: glass never on glass, content stays opaque) under a modest glass capsule (tab-bar stand-in) and a heavy glass overlay panel (modal stand-in).

Frame times come from `integration_test/glass_perf_test.dart`, run in profile mode one mode at a time:

```sh
flutter build apk --profile --target=integration_test/glass_perf_test.dart --dart-define=GLASS_MODE=<mode>
flutter drive --profile --no-dds \
  --use-application-binary=build/app/outputs/flutter-apk/app-profile.apk \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/glass_perf_test.dart
```

for `<mode>` in `none` (baseline), `modest`, `heavy`, `both`; each run writes `build/glass_<mode>.timeline_summary.json`.
Method notes learned the hard way:

- `--no-dds` is required.
  With DDS on the host, the in-app `traceAction` cannot reach the VM service and the run fails with "Failed to connect to VM Service".
- Scrolling is driven by a `ScrollController` (`animateTo`, 3 s down, 3 s up, linear) so every mode does identical work; a synthetic fling gesture lands on the centered glass overlay instead of the list and silently measures a static screen.
- One mode per app launch keeps the reported timeline payload small.

## Measured behavior (Android emulator)

Environment: AVD `crew-android-35`, Android 15 x86_64, headless emulator, Flutter 3.44.8, profile mode.
The engine logs `Using the Impeller rendering backend (OpenGLES)`, but the emulator's GL is **SwiftShader** (software rendering on the host CPU; the emulator boots with `gles_mode_selected:swangle`), so every number below is a CPU-rasterized frame time.

| Mode | avg raster ms | 90th pct raster ms | avg UI-build ms | raster frames over 16 ms budget |
| --- | --- | --- | --- | --- |
| none (baseline) | 21.3 | 26.6 | 12.4 | 48 / 57 |
| modest | 79.3 | 102.3 | 32.9 | 48 / 48 |
| heavy | 85.6 | 128.3 | 34.9 | 46 / 46 |
| both | 92.3 | 100.4 | 22.5 | 44 / 44 |

Readings:

- **The baseline already misses the 16.7 ms budget on most frames (48 of 57).** A software rasterizer cannot demonstrate 60 fps on this scene, so this emulator can neither prove nor refute the 60 fps acceptance for any mode; the useful signal is the delta between modes.
- Glass is expensive on this software rasterizer, roughly 3-4x the baseline raster time in every glass mode.
- The differences between glass modes (6-7 ms between modest, heavy, and both) are smaller than run-to-run variability on this shared-host emulator (the no-glass baseline itself moved by more than that between sessions).
  Without repeated samples, the data supports no finer causal conclusion about blurred area or the cost of an additional region.
- The backdrop filter executes on the raster thread by construction (the blur is applied when the layer tree is rasterized); the per-mode average UI-build times in the table are too noisy across runs to establish whether total UI-thread timing is affected.
- No pathological behavior: no crashes, no exponential cliff, animations completed in every mode.
  On a software rasterizer a backdrop blur costing a multiple of the whole rest of the frame is the expected shape, not an early-failure signal.

### What the emulator can and cannot tell us

Absolute times here are dominated by SwiftShader's CPU rasterization and do not establish how a phone GPU will perform at sigma 24.
What does transfer: the cost is a per-frame backdrop pass on the raster thread, and tint strength is free.

**Open item (deferred):** the real-device verdict, both intensities at 60 fps on a mid-range Android reference device under Impeller, is explicitly **not claimed here**; it needs the same benchmark run on real hardware once a device is available.
Until then the heavy treatment is provisionally viable: the emulator shows no fundamental jank cliff, but device-grade proof is outstanding.

## Performance ceiling and knobs

- The dominant cost is the backdrop readback + blur per glass region per frame; it scales with blurred area and sigma, not with the number of widgets under the glass.
- Knobs, in order of preference if real-device numbers miss 60 fps:
  1. Reduce blurred area (smaller overlay panels; the capsule bar is already small).
  2. Lower `GlassSurface.blurSigma` (fidelity to the 24 px token degrades gracefully).
  3. Drop the saturation matrix (keeps the frost, loses the color pop).
  4. For the heavy tier, fall back to a near-opaque tint without blur; its .85 tint already hides most background detail, so blur contributes least there.
- Multiple simultaneous glass regions each pay their own backdrop pass. E1.5 should keep at most one heavy overlay live at a time, which the modal/drawer interaction model already implies.
