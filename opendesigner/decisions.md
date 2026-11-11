# Decisions

Append-only, ADR-style (spec 7.9): one entry per decision, newest last. A later entry for the same path supersedes an earlier one; nothing is edited or deleted. set_by is chosen, confirmed_default, auto_default, assumed, delegated, reference, asset or standard.

## D-0001 · init with defaults
- set_by: auto_default · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: Start of the design system; every default traces to references/levers.json.

## D-0002 · context.product = "A small web app for the Loot Goblins WoW Forever guild: roster and levelling, professions, raid readiness, and raid attendance and loot."
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: read from the first paragraph of README.md; say if that's wrong
- previous value: ""

## D-0003 · answers.Q-plat-01 = ["web"]
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: read from the files (HTML pages); say if that's wrong
- also set: raw.platforms = ["web"] (from Q-plat-01)

## D-0004 · raw.textFace = "Alegreya Sans SC"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: read from a Google Fonts link in public/index.html; say if that's wrong
- previous value: "system"

## D-0005 · answers.Q-theme-01 = "system-light-dark"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: read from prefers-color-scheme: dark in public/index.html; say if that's wrong
- also set: raw.flags.darkMode = true (from Q-theme-01)
- also set: raw.defaultTheme = "system" (from Q-theme-01)

## D-0006 · answers.Q-scope-07 = "near-launch"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: read from the repo: code and deploy settings (firebase.json), but no released version yet; say if that's wrong

## D-0007 · House standards v3: 289 applied
- set_by: standard · locked: yes · date: 2026-11-04 · supersedes: none · source_ref: standards.json v3
- reason: OpenDesigner's house standards (sources marked non-negotiable) are applied without asking and locked. Change one only when the person asks: engine.py standard override <id> --why "<their words>".
- <details><summary>289 standards</summary> STD-when-to-animate-01, STD-when-to-animate-03, STD-when-to-animate-04, STD-when-to-animate-05, STD-when-to-animate-06, STD-when-to-animate-07, STD-when-to-animate-08, STD-when-to-animate-09, STD-when-to-animate-10, STD-when-to-animate-11, STD-when-to-animate-13, STD-when-to-animate-15, STD-when-to-animate-16, STD-when-to-animate-17, STD-when-to-animate-20, STD-when-to-animate-22, STD-easing-duration-01, STD-easing-duration-02, STD-easing-duration-03, STD-easing-duration-06, STD-easing-duration-07, STD-easing-duration-09, STD-easing-duration-10, STD-easing-duration-11, STD-easing-duration-12, STD-easing-duration-13, STD-easing-duration-15, STD-easing-duration-17, STD-easing-duration-19, STD-enter-exit-origin-01, STD-enter-exit-origin-02, STD-enter-exit-origin-03, STD-enter-exit-origin-04, STD-enter-exit-origin-06, STD-enter-exit-origin-08, STD-enter-exit-origin-09, STD-enter-exit-origin-10, STD-enter-exit-origin-11, STD-enter-exit-origin-12, STD-enter-exit-origin-13, STD-enter-exit-origin-16, STD-enter-exit-origin-17, STD-enter-exit-origin-21, STD-enter-exit-origin-23, STD-enter-exit-origin-24, STD-enter-exit-origin-26, STD-enter-exit-origin-27, STD-enter-exit-origin-28, STD-enter-exit-origin-29, STD-enter-exit-origin-30, STD-enter-exit-origin-31, STD-enter-exit-origin-37, STD-enter-exit-origin-38, STD-enter-exit-origin-39, STD-enter-exit-origin-40, STD-enter-exit-origin-41, STD-enter-exit-origin-42, STD-enter-exit-origin-43, STD-enter-exit-origin-44, STD-springs-gestures-01, STD-springs-gestures-02, STD-springs-gestures-04, STD-springs-gestures-05, STD-springs-gestures-06, STD-springs-gestures-07, STD-springs-gestures-08, STD-springs-gestures-09, STD-springs-gestures-11, STD-springs-gestures-12, STD-springs-gestures-13, STD-springs-gestures-14, STD-springs-gestures-15, STD-springs-gestures-16, STD-springs-gestures-17, STD-springs-gestures-18, STD-springs-gestures-19, STD-springs-gestures-20, STD-springs-gestures-21, STD-springs-gestures-25, STD-springs-gestures-26, STD-springs-gestures-28, STD-springs-gestures-30, STD-springs-gestures-34, STD-springs-gestures-39, STD-springs-gestures-41, STD-springs-gestures-42, STD-springs-gestures-45, STD-springs-gestures-59, STD-springs-gestures-60, STD-springs-gestures-61, STD-springs-gestures-63, STD-performance-properties-01, STD-performance-properties-02, STD-performance-properties-06, STD-performance-properties-09, STD-performance-properties-10, STD-performance-properties-11, STD-performance-properties-12, STD-performance-properties-13, STD-performance-properties-14, STD-performance-properties-15, STD-performance-properties-16, STD-performance-properties-17, STD-performance-properties-24, STD-performance-properties-25, STD-accessibility-motion-01, STD-accessibility-motion-02, STD-accessibility-motion-05, STD-accessibility-motion-06, STD-accessibility-motion-07, STD-accessibility-motion-08, STD-accessibility-motion-09, STD-accessibility-motion-10, STD-accessibility-motion-11, STD-accessibility-motion-12, STD-accessibility-motion-13, STD-accessibility-motion-15, STD-accessibility-motion-16, STD-accessibility-motion-17, STD-accessibility-motion-18, STD-accessibility-motion-20, STD-accessibility-motion-23, STD-accessibility-motion-24, STD-accessibility-motion-26, STD-accessibility-motion-27, STD-components-toasts-drawers-03, STD-components-toasts-drawers-07, STD-components-toasts-drawers-10, STD-components-toasts-drawers-11, STD-components-toasts-drawers-12, STD-components-toasts-drawers-13, STD-components-toasts-drawers-14, STD-components-toasts-drawers-15, STD-components-toasts-drawers-16, STD-components-toasts-drawers-17, STD-components-toasts-drawers-18, STD-components-toasts-drawers-25, STD-components-toasts-drawers-29, STD-components-toasts-drawers-30, STD-components-toasts-drawers-33, STD-components-toasts-drawers-34, STD-components-toasts-drawers-37, STD-components-toasts-drawers-40, STD-components-toasts-drawers-44, STD-components-toasts-drawers-45, STD-components-toasts-drawers-48, STD-components-toasts-drawers-65, STD-components-toasts-drawers-72, STD-components-toasts-drawers-77, STD-mobile-touch-02, STD-mobile-touch-03, STD-mobile-touch-05, STD-mobile-touch-06, STD-mobile-touch-07, STD-mobile-touch-08, STD-mobile-touch-09, STD-mobile-touch-10, STD-mobile-touch-11, STD-mobile-touch-13, STD-mobile-touch-14, STD-mobile-touch-15, STD-mobile-touch-16, STD-mobile-touch-17, STD-mobile-touch-18, STD-mobile-touch-19, STD-mobile-touch-20, STD-mobile-touch-21, STD-mobile-touch-24, STD-mobile-touch-28, STD-mobile-touch-70, STD-visual-details-01, STD-visual-details-02, STD-visual-details-03, STD-visual-details-04, STD-visual-details-05, STD-visual-details-06, STD-visual-details-07, STD-visual-details-08, STD-visual-details-09, STD-visual-details-10, STD-visual-details-11, STD-visual-details-13, STD-visual-details-14, STD-visual-details-15, STD-visual-details-16, STD-visual-details-17, STD-visual-details-18, STD-visual-details-19, STD-visual-details-20, STD-visual-details-21, STD-visual-details-24, STD-visual-details-25, STD-visual-details-26, STD-visual-details-27, STD-visual-details-28, STD-visual-details-29, STD-visual-details-30, STD-visual-details-31, STD-visual-details-32, STD-visual-details-33, STD-visual-details-34, STD-visual-details-35, STD-visual-details-36, STD-visual-details-37, STD-visual-details-38, STD-visual-details-39, STD-visual-details-40, STD-visual-details-41, STD-visual-details-42, STD-visual-details-43, STD-visual-details-44, STD-visual-details-45, STD-visual-details-46, STD-visual-details-47, STD-visual-details-48, STD-visual-details-49, STD-visual-details-50, STD-visual-details-51, STD-visual-details-55, STD-visual-details-56, STD-visual-details-57, STD-visual-details-59, STD-visual-details-64, STD-process-review-taste-01, STD-process-review-taste-02, STD-process-review-taste-03, STD-process-review-taste-04, STD-process-review-taste-05, STD-process-review-taste-06, STD-process-review-taste-07, STD-process-review-taste-08, STD-process-review-taste-09, STD-process-review-taste-10, STD-process-review-taste-11, STD-process-review-taste-12, STD-process-review-taste-13, STD-process-review-taste-14, STD-process-review-taste-15, STD-process-review-taste-16, STD-process-review-taste-17, STD-process-review-taste-18, STD-process-review-taste-19, STD-process-review-taste-20, STD-process-review-taste-21, STD-process-review-taste-22, STD-process-review-taste-23, STD-process-review-taste-24, STD-process-review-taste-25, STD-process-review-taste-26, STD-process-review-taste-27, STD-process-review-taste-28, STD-process-review-taste-29, STD-process-review-taste-30, STD-process-review-taste-31, STD-process-review-taste-32, STD-process-review-taste-33, STD-process-review-taste-34, STD-process-review-taste-35, STD-process-review-taste-36, STD-process-review-taste-37, STD-process-review-taste-38, STD-process-review-taste-39, STD-process-review-taste-40, STD-process-review-taste-41, STD-process-review-taste-42, STD-process-review-taste-43, STD-process-review-taste-44, STD-process-review-taste-45, STD-process-review-taste-46, STD-process-review-taste-47, STD-process-review-taste-48, STD-process-review-taste-49, STD-process-review-taste-50, STD-process-review-taste-51, STD-process-review-taste-52, STD-process-review-taste-53, STD-process-review-taste-54, STD-process-review-taste-55, STD-process-review-taste-56, STD-process-review-taste-57, STD-process-review-taste-58, STD-process-review-taste-59, STD-process-review-taste-60, STD-process-review-taste-62, STD-process-review-taste-63, STD-process-review-taste-64, STD-process-review-taste-65, STD-process-review-taste-66, STD-process-review-taste-67</details>
- STD-when-to-animate-01: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-03: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-04: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-05: motion.duration.instant = 0ms
- STD-when-to-animate-06: followed; it sets no values (DESIGN.md and review carry it)
- STD-when-to-animate-07: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-08: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-09: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-10: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-11: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-13: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-15: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-16: followed; it sets no values
- STD-when-to-animate-17: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-20: followed; it sets no values (DESIGN.md carries it)
- STD-when-to-animate-22: followed; it sets no values
- STD-easing-duration-01: motion.easing.linear = [0, 0, 1, 1]
- STD-easing-duration-01: motion.easing.hover = [0.25, 0.1, 0.25, 1]
- STD-easing-duration-02: motion.easing.enter = [0.23, 1, 0.32, 1]
- STD-easing-duration-02: motion.easing.exit = [0.23, 1, 0.32, 1]
- STD-easing-duration-02: motion.easing.standard = [0.77, 0, 0.175, 1]
- STD-easing-duration-03: followed; it sets no values (DESIGN.md and review carry it)
- STD-easing-duration-06: followed; it sets no values (DESIGN.md and review carry it)
- STD-easing-duration-07: motion.duration.micro = 100ms
- STD-easing-duration-07: motion.duration.short = 150ms
- STD-easing-duration-07: motion.duration.medium = 200ms
- STD-easing-duration-07: motion.duration.long = 250ms
- STD-easing-duration-09: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-10: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-11: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-12: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-13: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-15: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-17: followed; it sets no values (DESIGN.md carries it)
- STD-easing-duration-19: followed; it sets no values
- STD-enter-exit-origin-01: motion.scale.enter = 0.95
- STD-enter-exit-origin-02: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-03: followed; it sets no values (DESIGN.md and review carry it)
- STD-enter-exit-origin-04: followed; it sets no values (DESIGN.md and review carry it)
- STD-enter-exit-origin-06: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-08: motion.duration.medium = 200ms
- STD-enter-exit-origin-08: motion.scale.enter = 0.95
- STD-enter-exit-origin-09: motion.duration.tooltip = 125ms
- STD-enter-exit-origin-09: motion.scale.enter-tooltip = 0.97
- STD-enter-exit-origin-10: motion.duration.instant = 0ms
- STD-enter-exit-origin-11: motion.duration.modal = 250ms
- STD-enter-exit-origin-11: motion.scale.enter-modal = 0.96
- STD-enter-exit-origin-12: motion.duration.modal = 250ms
- STD-enter-exit-origin-13: motion.duration.stagger = 50ms
- STD-enter-exit-origin-16: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-17: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-21: followed; it sets no values (DESIGN.md and review carry it)
- STD-enter-exit-origin-23: motion.duration.medium = 200ms
- STD-enter-exit-origin-24: followed; it sets no values (DESIGN.md and review carry it)
- STD-enter-exit-origin-26: motion.duration.reveal = 600ms
- STD-enter-exit-origin-27: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-28: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-29: motion.blur.crossfade = 2px
- STD-enter-exit-origin-30: followed; it sets no values (DESIGN.md and review carry it)
- STD-enter-exit-origin-31: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-37: followed; it sets no values
- STD-enter-exit-origin-38: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-39: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-40: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-41: motion.easing.drawer = [0.32, 0.72, 0, 1]
- STD-enter-exit-origin-41: motion.duration.drawer = 500ms
- STD-enter-exit-origin-42: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-43: followed; it sets no values (DESIGN.md carries it)
- STD-enter-exit-origin-44: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-01: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-02: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-04: motion.spring.spatial.dampingRatio = 1.0
- STD-springs-gestures-04: motion.spring.spatial.stiffness = 246.7
- STD-springs-gestures-05: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-06: motion.spring.momentum = {"dampingRatio": 0.8, "stiffness": 246.7, "mass": 1}
- STD-springs-gestures-07: followed; it sets no values (DESIGN.md and review carry it)
- STD-springs-gestures-08: motion.spring.sheet = {"dampingRatio": 0.8, "stiffness": 438.6, "mass": 1}
- STD-springs-gestures-09: motion.spring.rotation = {"dampingRatio": 0.8, "stiffness": 246.7, "mass": 1}
- STD-springs-gestures-11: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-12: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-13: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-14: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-15: followed; it sets no values (DESIGN.md and review carry it)
- STD-springs-gestures-16: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-17: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-18: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-19: motion.gesture.deceleration-rate = 0.998
- STD-springs-gestures-20: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-21: motion.gesture.dismiss-velocity = 0.11
- STD-springs-gestures-25: motion.gesture.rubberband-constant = 0.55
- STD-springs-gestures-26: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-28: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-30: motion.gesture.direction-threshold = 10px
- STD-springs-gestures-34: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-39: followed; it sets no values (DESIGN.md and review carry it)
- STD-springs-gestures-41: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-42: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-45: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-59: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-60: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-61: followed; it sets no values (DESIGN.md carries it)
- STD-springs-gestures-63: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-01: followed; it sets no values (DESIGN.md and review carry it)
- STD-performance-properties-02: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-06: followed; it sets no values (DESIGN.md and review carry it)
- STD-performance-properties-09: followed; it sets no values (DESIGN.md and review carry it)
- STD-performance-properties-10: followed; it sets no values (DESIGN.md and review carry it)
- STD-performance-properties-11: followed; it sets no values (DESIGN.md and review carry it)
- STD-performance-properties-12: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-13: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-14: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-15: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-16: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-17: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-24: followed; it sets no values (DESIGN.md carries it)
- STD-performance-properties-25: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-01: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-02: raw.reducedMotion = "replace"
- STD-accessibility-motion-02: motion.duration.reduced-fade = 200ms
- STD-accessibility-motion-02: reduced:motion.transition.enter = {"duration": "{motion.duration.reduced-fade}", "delay": {"value": 0, "unit": "ms"}, "timingFunction": [0.25, 0.1, 0.25, 1]}
- STD-accessibility-motion-02: reduced:motion.transition.exit = {"duration": "{motion.duration.reduced-fade}", "delay": {"value": 0, "unit": "ms"}, "timingFunction": [0.25, 0.1, 0.25, 1]}
- STD-accessibility-motion-02: reduced:motion.transition.expand = {"duration": "{motion.duration.reduced-fade}", "delay": {"value": 0, "unit": "ms"}, "timingFunction": [0.25, 0.1, 0.25, 1]}
- STD-accessibility-motion-05: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-06: followed; it sets no values
- STD-accessibility-motion-07: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-08: followed; it sets no values (DESIGN.md and review carry it)
- STD-accessibility-motion-09: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-10: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-11: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-12: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-13: followed; it sets no values (DESIGN.md and review carry it)
- STD-accessibility-motion-15: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-16: followed; it sets no values (DESIGN.md and review carry it)
- STD-accessibility-motion-17: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-18: followed; it sets no values
- STD-accessibility-motion-20: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-23: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-24: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-26: followed; it sets no values (DESIGN.md carries it)
- STD-accessibility-motion-27: followed; it sets no values (DESIGN.md and review carry it)
- STD-components-toasts-drawers-03: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-07: motion.duration.toast = 400ms
- STD-components-toasts-drawers-07: motion.easing.toast = [0.25, 0.1, 0.25, 1]
- STD-components-toasts-drawers-10: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-11: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-12: component.toast.gap = 14px
- STD-components-toasts-drawers-13: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-14: component.toast.visible = 3
- STD-components-toasts-drawers-15: component.toast.duration = 4000ms
- STD-components-toasts-drawers-16: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-17: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-18: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-25: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-29: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-30: component.toast.offset.desktop = 32px
- STD-components-toasts-drawers-30: component.toast.offset.mobile = 16px
- STD-components-toasts-drawers-33: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-34: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-37: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-40: motion.easing.drawer = [0.32, 0.72, 0, 1]
- STD-components-toasts-drawers-44: motion.gesture.drag-lock-after-scroll = 100ms
- STD-components-toasts-drawers-45: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-48: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-65: followed; it sets no values
- STD-components-toasts-drawers-72: followed; it sets no values (DESIGN.md carries it)
- STD-components-toasts-drawers-77: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-02: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-03: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-05: motion.scale.press = 0.97
- STD-mobile-touch-05: motion.duration.micro = 100ms
- STD-mobile-touch-06: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-07: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-08: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-09: size.target.touch = 44px
- STD-mobile-touch-09: size.target.min = 44px
- STD-mobile-touch-10: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-11: font.size.input = 16px
- STD-mobile-touch-13: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-14: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-15: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-16: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-17: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-18: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-19: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-20: followed; it sets no values (DESIGN.md and review carry it)
- STD-mobile-touch-21: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-24: followed; it sets no values
- STD-mobile-touch-28: followed; it sets no values (DESIGN.md carries it)
- STD-mobile-touch-70: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-01: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-02: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-03: followed; it sets no values (DESIGN.md and review carry it)
- STD-visual-details-04: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-05: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-06: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-07: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-08: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-09: followed; it sets no values (DESIGN.md and review carry it)
- STD-visual-details-10: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-11: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-13: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-14: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-15: followed; it sets no values (DESIGN.md and review carry it)
- STD-visual-details-16: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-17: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-18: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-19: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-20: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-21: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-24: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-25: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-26: followed; it sets no values (DESIGN.md and review carry it)
- STD-visual-details-27: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-28: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-29: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-30: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-31: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-32: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-33: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-34: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-35: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-36: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-37: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-38: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-39: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-40: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-41: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-42: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-43: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-44: followed; it sets no values
- STD-visual-details-45: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-46: followed; it sets no values
- STD-visual-details-47: followed; it sets no values
- STD-visual-details-48: followed; it sets no values
- STD-visual-details-49: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-50: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-51: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-55: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-56: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-57: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-59: followed; it sets no values (DESIGN.md carries it)
- STD-visual-details-64: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-01: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-02: followed; it sets no values
- STD-process-review-taste-03: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-04: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-05: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-06: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-07: followed; it sets no values
- STD-process-review-taste-08: followed; it sets no values
- STD-process-review-taste-09: followed; it sets no values
- STD-process-review-taste-10: followed; it sets no values
- STD-process-review-taste-11: followed; it sets no values
- STD-process-review-taste-12: followed; it sets no values
- STD-process-review-taste-13: followed; it sets no values
- STD-process-review-taste-14: followed; it sets no values
- STD-process-review-taste-15: followed; it sets no values
- STD-process-review-taste-16: followed; it sets no values
- STD-process-review-taste-17: followed; it sets no values
- STD-process-review-taste-18: followed; it sets no values
- STD-process-review-taste-19: followed; it sets no values
- STD-process-review-taste-20: followed; it sets no values
- STD-process-review-taste-21: followed; it sets no values
- STD-process-review-taste-22: followed; it sets no values
- STD-process-review-taste-23: followed; it sets no values
- STD-process-review-taste-24: followed; it sets no values
- STD-process-review-taste-25: followed; it sets no values
- STD-process-review-taste-26: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-27: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-28: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-29: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-30: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-31: followed; it sets no values
- STD-process-review-taste-32: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-33: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-34: followed; it sets no values
- STD-process-review-taste-35: followed; it sets no values
- STD-process-review-taste-36: followed; it sets no values (DESIGN.md carries it)
- STD-process-review-taste-37: followed; it sets no values
- STD-process-review-taste-38: followed; it sets no values
- STD-process-review-taste-39: followed; it sets no values
- STD-process-review-taste-40: followed; it sets no values (review carries it)
- STD-process-review-taste-41: followed; it sets no values (review carries it)
- STD-process-review-taste-42: followed; it sets no values
- STD-process-review-taste-43: followed; it sets no values
- STD-process-review-taste-44: followed; it sets no values
- STD-process-review-taste-45: followed; it sets no values
- STD-process-review-taste-46: followed; it sets no values
- STD-process-review-taste-47: followed; it sets no values
- STD-process-review-taste-48: followed; it sets no values
- STD-process-review-taste-49: followed; it sets no values
- STD-process-review-taste-50: followed; it sets no values
- STD-process-review-taste-51: followed; it sets no values
- STD-process-review-taste-52: followed; it sets no values
- STD-process-review-taste-53: followed; it sets no values
- STD-process-review-taste-54: followed; it sets no values
- STD-process-review-taste-55: followed; it sets no values
- STD-process-review-taste-56: followed; it sets no values
- STD-process-review-taste-57: followed; it sets no values
- STD-process-review-taste-58: followed; it sets no values
- STD-process-review-taste-59: followed; it sets no values
- STD-process-review-taste-60: followed; it sets no values
- STD-process-review-taste-62: followed; it sets no values
- STD-process-review-taste-63: followed; it sets no values
- STD-process-review-taste-64: followed; it sets no values
- STD-process-review-taste-65: followed; it sets no values
- STD-process-review-taste-66: followed; it sets no values
- STD-process-review-taste-67: followed; it sets no values (DESIGN.md carries it)

## D-0008 · context.market.analogous = "TeamSnap / Spond (sports team apps: roster, availability, event sign-ups)"
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: same job in another field: a casual group checking roster and sign-ups on phones
- previous value: ""

## D-0009 · context.market.competitors = ["WowAudit", "Raid-Helper", "Warcraft Logs"]
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: WoW guild tools to beat: WowAudit for roster, Raid-Helper for sign-ups
- previous value: []

## D-0010 · context.market.analogous = "team sports apps like TeamSnap and Spond: roster, availability and event sign-ups for casual groups on phones"
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: D-0008 · source_ref: none
- reason: asked me to pick or mix; they don't want a heavy spreadsheet feel
- previous value: "TeamSnap / Spond (sports team apps: roster, availability, event sign-ups)"

## D-0011 · context.market.competitors = ["WowAudit", "Raid-Helper", "Warcraft Logs"]
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: D-0009 · source_ref: none
- reason: WoW guild tools as the baseline to beat
- previous value: ["WowAudit", "Raid-Helper", "Warcraft Logs"]

## D-0012 · taste.dislikes = ["a heavy, full-on spreadsheet look (their words)"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: not too unaccessible, like a heavy full on spreadsheet

## D-0013 · context.market.analogous = "TeamSnap / Spond (team roster and availability apps for casual groups)"
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: D-0010 · source_ref: none
- reason: they said 'you pick' and don't want a heavy spreadsheet; mix of new and old players
- previous value: "team sports apps like TeamSnap and Spond: roster, availability and event sign-ups for casual groups on phones"

## D-0014 · context.market.competitors = ["WowAudit", "Raid-Helper", "Warcraft Logs"]
- set_by: delegated · locked: no · date: 2026-11-04 · supersedes: D-0011 · source_ref: none
- reason: the WoW tools to beat
- previous value: ["WowAudit", "Raid-Helper", "Warcraft Logs"]

## D-0015 · answers.Q-aud-01 = "regular"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: guild members check in regularly; mix of new and experienced players; they don't want a dense spreadsheet
- also set: dials.density = 50 (from Q-aud-01)

## D-0016 · answers.Q-theme-01 = "light-dark-toggle"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0005 · source_ref: none
- reason: they want it dark themed like night mode, and asked earlier for a switch; dark is what it opens in
- previous value: "system-light-dark"
- also set: raw.flags.darkMode = true (from Q-theme-01)
- also set: raw.defaultTheme = "system" (from Q-theme-01)

## D-0017 · raw.defaultTheme = "dark"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: they want it dark themed, like night mode
- previous value: "system"

## D-0018 · context.product = "a roster, raid sign-up and profession tracker for Loot Goblins, a Horde guild on WoW Forever"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: D-0002 · source_ref: none
- reason: from their words and README
- previous value: "A small web app for the Loot Goblins WoW Forever guild: roster and levelling, professions, raid readiness, and raid attendance and loot."

## D-0019 · context.purpose = "help a mixed guild of new and experienced players see who is ready for raids and who can craft what"
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: from their words
- previous value: ""

## D-0020 · context.goals = ["every member keeps their own character up to date", "new players understand it at a glance", "the guild is raid-ready for the December raids"]
- set_by: assumed · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: from their words and the app they built
- previous value: []

## D-0021 · raw.brandColor = "#d4a24c"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: sketch: Level 0 answer

## D-0022 · macros = ["deferential", "minimal"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: sketch: Level 0 answer (their words: calm, minimal)
- previous value: []

## D-0023 · taste.feelWords = ["calm", "minimal"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: sketch: the person's own feel words

## D-0024 · taste.brief = "dark, like night mode, with a touch of Horde; we are Loot Goblins after all"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: sketch: the person's picture of the look

## D-0025 · answers.Q-scope-06 = ["guild app:operate"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: sketch: Level 0 answer
- also set: context.surfaces = [{"name": "guild app", "mode": "Operate"}] (from Q-scope-06)
- also set: raw.productType = "work-tool" (from Q-scope-06)
- also set: raw.marketingSurfaces = false (from Q-scope-06)

## D-0026 · context.goals = ["every member keeps their own character up to date", "new players understand it at a glance", "later: be raid-ready when raids open (kept low-key for now)"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0020 · source_ref: none
- reason: raids are a long way off and it's unclear which new players will stick around, so raid readiness is toned down for now
- previous value: ["every member keeps their own character up to date", "new players understand it at a glance", "the guild is raid-ready for the December raids"]

## D-0027 · answers.Q-voice-01 = "custom"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: bare and functional: just labels, no personality; basic is good. Traits: plain, short, functional; no jokes, no hype
- also set: hooks.H-voice.status = "placeholder" (from Q-voice-01)

## D-0028 · answers.Q-aud-01 = "regular"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0015 · source_ref: none
- reason: they'll update their character every few days when they make progress
- previous value: "regular"
- also set: dials.density = 50 (from Q-aud-01)

## D-0029 · context.goals = ["every member keeps their own character up to date", "new players understand it at a glance", "see each other's goals so people can group up and do things together", "later: be raid-ready when raids open (kept low-key for now)"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0026 · source_ref: none
- reason: they want to see people's goals to find others to group up with
- previous value: ["every member keeps their own character up to date", "new players understand it at a glance", "later: be raid-ready when raids open (kept low-key for now)"]

## D-0030 · project standard PRJ-01 (non-negotiable): Product words are bare and functional: no exclamation marks; no 'Awesome', 'Oops', 'Let's', 'Embark on your journey'; no hype words (epic, seamless, unleash); no emoji in labels or messages; no over-explaining
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: the person dislikes the AI-generated tone: all of these habits

## D-0031 · taste.dislikes = ["AI-generated tone: exclamation marks, Oops/Awesome, hype words, emoji in labels, over-explaining", "heavy full-on spreadsheet look"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0012 · source_ref: none
- reason: their words
- previous value: ["a heavy, full-on spreadsheet look (their words)"]

## D-0032 · answers.Q-voice-03 = "title-headings"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: title case for headings and menus, sentence case for buttons
- also set: overrides.content.capitalization = "title-case" (from Q-voice-03)

## D-0033 · answers.Q-voice-04 = "labels-2-4"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: everyday words, buttons of 2-4 words starting with a verb; no explanatory notes everywhere

## D-0034 · answers.Q-dir-01 = "flat2"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: Quiet flat: the clean look they liked, in the dark
- also set: preset = "flat2" (from Q-dir-01)

## D-0035 · project standard PRJ-02 (non-negotiable): Show a character's level as a plain number beside the role (e.g. 'Tank · 60'). No progress bars or countdowns toward level 60
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: it's about the journey; the app shouldn't pressure anyone to hit 60 fast

## D-0036 · answers.Q-color-09 = "hue-matched"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: they like the warm gold-tinted surfaces of 'Warm tonal' with the layout of 'Quiet flat'
- also set: raw.neutralTint = "brand" (from Q-color-09)

## D-0037 · answers.Q-color-03 = "tonal"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: the coloured look of Warm tonal
- also set: dials.colorfulness = 45 (from Q-color-03)

## D-0038 · raw.neutralBase = "#4a3b25"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: they like the gold-tinted surfaces of Warm tonal; greys warmed toward loot gold

## D-0039 · answers.Q-type-01 = "open-custom"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: Figtree for everything, plus Alegreya Sans SC for page titles only
- also set: raw.textFace = "=openClass" (from Q-type-01)
- also set: raw.displayFace = "=textFace" (from Q-type-01)

## D-0040 · raw.textFace = "Figtree"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0004 · source_ref: none
- reason: calm, readable, numbers line up
- previous value: "=openClass"

## D-0041 · raw.displayFace = "Alegreya Sans SC"
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: one small WoW touch on page titles, the font they installed
- previous value: "=textFace"

## D-0042 · project standard PRJ-03 (non-negotiable): The website only shows what happens in game; it never offers actions the game handles, like joining a group. Looking for Group is display-only: goal, who, role, level, when, and 'Whisper <name> in game'
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: grouping happens in game, not on the website

## D-0043 · project standard PRJ-04 (non-negotiable): WoW Forever characters have a first and a last name (e.g. 'Clark Clark'). Show the full name everywhere; forms ask for first name and last name; name fields fit two names without cutting off
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: game rule in WoW Forever; their character is Clark Clark

## D-0044 · project standard PRJ-05 (non-negotiable): Profession skill shows a progress bar to 300, with marks where each rank ends (75, 150, 225) and gold when maxed. This is the only progress bar; character level stays a plain number
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: a bar to 300 makes sense for professions; levels stay pressure-free

## D-0045 · project standard PRJ-06 (non-negotiable): Dungeon goals are picked from a list of WoW Forever dungeons sorted by level, each showing its level range (e.g. 'Shadowfang Keep · levels 20-26'); other goals are free text
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04; dungeon list from Warcraft Tavern
- reason: easier than typing every dungeon; shows the level range

## D-0046 · project standard PRJ-07 (non-negotiable): Journey keeps in-game and website events apart: 'Joined Loot Goblins in game' uses a date the player enters (optional); 'Added to the roster' is recorded automatically when they sign up on the site
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: joining the guild in game can be a different day from signing up on the website

## D-0047 · project standard PRJ-08 (non-negotiable): Goals have three tabs with counts: Open (default), Done, All. Ticking a goal moves it to Done; each tab has a plain empty message. Dungeon names show without a '(new)' marker
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: a tab to see completed, all or unticked goals; remove the (new)

## D-0048 · project standard PRJ-09 (non-negotiable): Journey wording: 'Joined Loot Goblins' (date the player enters, optional) and 'Added to the roster' (recorded when a character or alt is created on the site)
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: leave 'Joined Loot Goblins' without 'in game'; 'Added to the roster' when they create their character or alt

## D-0049 · project standard PRJ-10 (non-negotiable): Profiles have an Availability section: a week grid (Mon-Sun) by Afternoon, Evening and Late, shown in the viewer's time zone. Notes stay free text and don't carry availability
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: notes stay notes; add an availability section

## D-0050 · project standard PRJ-11 (non-negotiable): Goal types: Dungeon (pick from list, shows level range), Battleground (pick from list), Profession (pick profession + rank to reach), Level (reach level N), Something else (free text). Each goal shows a small type tag
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: could do battlegrounds, or think of different types of goals

## D-0051 · project standard PRJ-12 (non-negotiable): Times have a Perth / Sydney switch (players are in both). Label by city, not AEST/AWST, because Sydney changes with daylight saving (+3h Oct-Apr, +2h otherwise)
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: players on both time zones

## D-0052 · project standard PRJ-13 (non-negotiable): Times are always shown in the viewer's own time zone, read from their device; no time zone switch. Availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am); availability is stored as real times so the shaded squares move, never the labels. Profiles say 'Plays from <city>'
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: it's weird that the afternoon times change depending on where you are; there must be a better way

## D-0053 · project standard PRJ-14 (non-negotiable): Exception to the bare voice: the free-text goal box shows rotating playful example placeholders ('Gank some noobs', 'Ninja loot something shiny', etc.). Labels, buttons and messages stay bare
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: the 'something else' example could rotate through things like 'Gank some noobs' or 'ninja loot'

## D-0054 · remove PRJ-03 (project standard)
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0042 · source_ref: none
- reason: replaced: Looking for Group now has a site-level Join (notice board), the person's choice
- rule was: The website only shows what happens in game; it never offers actions the game handles, like joining a group. Looking for Group is display-only: goal, who, role, level, when, and 'Whisper <name> in game'
- it set no values

## D-0055 · remove PRJ-07 (project standard)
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0046 · source_ref: none
- reason: superseded by PRJ-09 (wording without 'in game')
- rule was: Journey keeps in-game and website events apart: 'Joined Loot Goblins in game' uses a date the player enters (optional); 'Added to the roster' is recorded automatically when they sign up on the site
- it set no values

## D-0056 · remove PRJ-12 (project standard)
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0051 · source_ref: none
- reason: superseded by PRJ-13 (viewer's own time, no switch)
- rule was: Times have a Perth / Sydney switch (players are in both). Label by city, not AEST/AWST, because Sydney changes with daylight saving (+3h Oct-Apr, +2h otherwise)
- it set no values

## D-0057 · project standard PRJ-15 (non-negotiable): Looking for Group is a notice board: one card per goal, a Join button adds you to the card (site only; grouping happens in game). Cards show role gaps against the usual 1 tank, 1 healer, 3 DPS ('Needs a tank') as guidance only: anyone can join, any mix or size. Each card shows the best time from members' availability. Discord posting is a later option
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: it should say needs a tank etc, but it shouldn't be restricted; Join is better than Me too; option A for now, Discord later

## D-0058 · project standard PRJ-16 (non-negotiable): Battleground goals are split by 10-level bracket (10-19, 20-29 ... 50-59, 60), one card per bracket; Join only in your own bracket ('Not your bracket' otherwise). 'Suits my level' shows dungeons near your level and only your battleground bracket. The Roster's group panel has the same small Join / Leave button
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: brackets are 20-29, 30-39 etc, make sure they suit as well; a small join button for the roster

## D-0059 · context.later = ["Trade orders: post what you need crafted, crafters pick it up", "Post Looking for Group requests to the guild Discord (webhook)", "Raid sign-ups and calendar, once people near 60", "Finished goals appear in Journey automatically (asked, not answered)"]
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: none · source_ref: none
- reason: ideas the person wants later

## D-0060 · project standard PRJ-17 (non-negotiable): Privacy: show character names only, never real names. Don't display the Google account name or email anywhere, and don't store real names on character records. Alts read 'Alt of <character name>'
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: leave real names out for privacy; 'Clark Clark' is fine because it's a character name

## D-0061 · remove PRJ-13 (project standard)
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0052 · source_ref: none
- reason: replaced by the time zone picker rule
- rule was: Times are always shown in the viewer's own time zone, read from their device; no time zone switch. Availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am); availability is stored as real times so the shaded squares move, never the labels. Profiles say 'Plays from <city>'
- it set no values

## D-0062 · project standard PRJ-18 (non-negotiable): Each person picks an Australian time zone in Edit character: Western (Perth), Central (Darwin), Central with daylight saving (Adelaide), Eastern (Brisbane), Eastern with daylight saving (Sydney). Profiles show it as '<City> time'. All times show in the viewer's own zone; availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am) and the shaded squares move
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: a time zone selection with (Perth) or (Sydney) shown, Australian time zones; they live in Geraldton, not Perth

## D-0063 · remove PRJ-18 (project standard)
- set_by: chosen · locked: no · date: 2026-11-04 · supersedes: D-0062 · source_ref: none
- reason: replaced: abbreviation picker with a daylight saving tick box
- rule was: Each person picks an Australian time zone in Edit character: Western (Perth), Central (Darwin), Central with daylight saving (Adelaide), Eastern (Brisbane), Eastern with daylight saving (Sydney). Profiles show it as '<City> time'. All times show in the viewer's own zone; availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am) and the shaded squares move
- it set no values

## D-0064 · project standard PRJ-19 (non-negotiable): Time zone in Edit character: AWST (Perth), ACST (Adelaide) or AEST (Sydney), plus a 'Daylight saving' tick box for ACST and AEST (WA has none). All times show in the viewer's own zone; availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am) and the shaded squares move
- set_by: standard · locked: no · date: 2026-11-04 · supersedes: none · source_ref: person, 2026-11-04
- reason: their words: do AEST for example, with a daylight savings tick box

## D-0065 · name = "Blood and Tears"
- set_by: chosen · locked: no · date: 2026-11-06 · supersedes: none · source_ref: none
- reason: guild renamed from Loot Goblins
- previous value: "Loot Goblins"

## D-0066 · raw.brandColor = "#b8282a"
- set_by: chosen · locked: no · date: 2026-11-06 · supersedes: D-0021 · source_ref: none
- reason: site rebranded to Blood and Tears red
- previous value: "#d4a24c"

## D-0067 · raw.neutralBase = "#171515"
- set_by: chosen · locked: no · date: 2026-11-06 · supersedes: D-0038 · source_ref: none
- reason: picked direction A, Obsidian: near-black greys so the red is the only strong colour (audit row 1)
- previous value: "#4a3b25"

## D-0068 · remove PRJ-10 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0049 · source_ref: none
- reason: Availability was cut from the site
- rule was: Profiles have an Availability section: a week grid (Mon-Sun) by Afternoon, Evening and Late, shown in the viewer's time zone. Notes stay free text and don't carry availability
- it set no values

## D-0069 · remove PRJ-09 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0048 · source_ref: none
- reason: Guild renamed to Blood and Tears
- rule was: Journey wording: 'Joined Loot Goblins' (date the player enters, optional) and 'Added to the roster' (recorded when a character or alt is created on the site)
- it set no values

## D-0070 · project standard PRJ-20 (non-negotiable): Journey wording: 'Joined Blood and Tears' (date the player enters, optional) and 'Added to the roster' (recorded when a character is created on the site)
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-06
- reason: guild renamed from Loot Goblins

## D-0071 · remove PRJ-15 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0057 · source_ref: none
- reason: Availability and Discord posting are gone from Looking for Group
- rule was: Looking for Group is a notice board: one card per goal, a Join button adds you to the card (site only; grouping happens in game). Cards show role gaps against the usual 1 tank, 1 healer, 3 DPS ('Needs a tank') as guidance only: anyone can join, any mix or size. Each card shows the best time from members' availability. Discord posting is a later option
- it set no values

## D-0072 · project standard PRJ-21 (non-negotiable): Groups is a notice board: one card per post, a Join button adds you to the card (site only; grouping happens in game). Cards show role gaps against the usual 1 tank, 1 healer, 3 DPS ('Needs a tank') as guidance only. Posts can have an optional time and note; the poster or an officer can mark them Done, Edit them or Stop looking
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-06
- reason: availability and events were cut; a group with a time replaces events

## D-0073 · remove PRJ-19 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0064 · source_ref: none
- reason: Availability rows are gone; time zones now only affect group times
- rule was: Time zone in Edit character: AWST (Perth), ACST (Adelaide) or AEST (Sydney), plus a 'Daylight saving' tick box for ACST and AEST (WA has none). All times show in the viewer's own zone; availability rows stay fixed (Afternoon 12-5pm, Evening 5-9pm, Late 9pm-12am) and the shaded squares move
- it set no values

## D-0074 · project standard PRJ-22 (non-negotiable): Time zone in Edit character: AWST (Perth), ACST (Adelaide) or AEST (Sydney), plus a 'Daylight saving' tick box for ACST and AEST (WA has none). Group times show in the viewer's own zone
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-04
- reason: times on group posts need the right zone

## D-0075 · remove PRJ-01 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0030 · source_ref: none
- reason: the person asked for more fun and flavour (game slang, Ding, card flavour text)
- rule was: Product words are bare and functional: no exclamation marks; no 'Awesome', 'Oops', 'Let's', 'Embark on your journey'; no hype words (epic, seamless, unleash); no emoji in labels or messages; no over-explaining
- it set no values

## D-0076 · project standard PRJ-23 (non-negotiable): Labels, buttons and messages are bare and functional: no exclamation marks; no 'Awesome', 'Oops', 'Let's'; no hype words; no emoji; no over-explaining. Game flavour is the exception and lives in content only: Guild Feed slang ('dinged 24', 'looted', 'is LFG for'), the level-up 'Ding!' moment, card flavour text, the Hall of Firsts and Duels. Game terms like Epic are item names, not hype
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-06
- reason: the person asked for a focus on fun and flavour, then approved each of these

## D-0077 · context.product = "a roster, groups, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever"
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0018 · source_ref: none
- reason: the site grew past a roster tracker; raid sign-ups are still later
- previous value: "a roster, raid sign-up and profession tracker for Loot Goblins, a Horde guild on WoW Forever"

## D-0078 · context.later = ["Raid sign-ups and calendar, once people near 60 (raids open 9 December)", "Discord posts and slash commands (built, switched off until there are permissions)", "Glow-up pictures of a character at each 10 levels (needs saved armory pictures)", "Winter Veil look in December", "Feed reactions (maybe)", "Dungeon passport (being mocked up)"]
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0059 · source_ref: none
- reason: updated with the person, 7 Nov
- previous value: ["Trade orders: post what you need crafted, crafters pick it up", "Post Looking for Group requests to the guild Discord (webhook)", "Raid sign-ups and calendar, once people near 60", "Finished goals appear in Journey automatically (asked, not answered)"]

## D-0079 · context.market.analogous = "Strava clubs and Raider.IO guild pages (a group of members, a weekly leaderboard and an activity feed), plus trading-card games for the cards"
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0013 · source_ref: none
- reason: references used in the second design pass
- previous value: "TeamSnap / Spond (team roster and availability apps for casual groups)"

## D-0080 · remove PRJ-21 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0072 · source_ref: none
- reason: group posting was cut: groups happen in game and on Discord
- rule was: Groups is a notice board: one card per post, a Join button adds you to the card (site only; grouping happens in game). Cards show role gaps against the usual 1 tank, 1 healer, 3 DPS ('Needs a tank') as guidance only. Posts can have an optional time and note; the poster or an officer can mark them Done, Edit them or Stop looking
- it set no values

## D-0081 · project standard PRJ-24 (non-negotiable): The site is hands-off: everything fills itself from the armory or is optional fun. Nothing asks people to sign up, post or keep something up to date (trade orders, availability, events and group posts were cut for this reason; groups are sorted in game and on Discord). The Dungeons page only shows who's the right level for each dungeon and when raids open
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-07
- reason: the person wants the site as hands-off as possible, with only optional fun extras

## D-0082 · project standard PRJ-25 (non-negotiable): Dungeon Passport: owners tap a dungeon on their character page to stamp it (tap again to remove). Optional and just for fun; the card back has Stats and Passport tabs
- set_by: standard · locked: no · date: 2026-11-07 · supersedes: none · source_ref: person, 2026-11-07
- reason: the person chose tabs and accepts that stamps are filled in by hand

## D-0083 · remove PRJ-06 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0045 · source_ref: none
- reason: Remove all the useless stuff then please (the goals card was cut earlier)
- rule was: Dungeon goals are picked from a list of WoW Forever dungeons sorted by level, each showing its level range (e.g. 'Shadowfang Keep · levels 20-26'); other goals are free text
- it set no values

## D-0084 · remove PRJ-08 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0047 · source_ref: none
- reason: Remove all the useless stuff then please (the goals card was cut earlier)
- rule was: Goals have three tabs with counts: Open (default), Done, All. Ticking a goal moves it to Done; each tab has a plain empty message. Dungeon names show without a '(new)' marker
- it set no values

## D-0085 · remove PRJ-11 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0050 · source_ref: none
- reason: Remove all the useless stuff then please (the goals card was cut earlier)
- rule was: Goal types: Dungeon (pick from list, shows level range), Battleground (pick from list), Profession (pick profession + rank to reach), Level (reach level N), Something else (free text). Each goal shows a small type tag
- it set no values

## D-0086 · remove PRJ-14 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0053 · source_ref: none
- reason: Remove all the useless stuff then please (the goals card was cut earlier)
- rule was: Exception to the bare voice: the free-text goal box shows rotating playful example placeholders ('Gank some noobs', 'Ninja loot something shiny', etc.). Labels, buttons and messages stay bare
- it set no values

## D-0087 · remove PRJ-16 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0058 · source_ref: none
- reason: Remove all the useless stuff then please (the goals card was cut earlier)
- rule was: Battleground goals are split by 10-level bracket (10-19, 20-29 ... 50-59, 60), one card per bracket; Join only in your own bracket ('Not your bracket' otherwise). 'Suits my level' shows dungeons near your level and only your battleground bracket. The Roster's group panel has the same small Join / Leave button
- it set no values

## D-0088 · remove PRJ-22 (project standard)
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0074 · source_ref: none
- reason: Remove all the useless stuff then please (time zone was only for group and event times, both cut)
- rule was: Time zone in Edit character: AWST (Perth), ACST (Adelaide) or AEST (Sydney), plus a 'Daylight saving' tick box for ACST and AEST (WA has none). Group times show in the viewer's own zone
- it set no values

## D-0089 · context.product = "a roster, dungeons, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever"
- set_by: chosen · locked: no · date: 2026-11-07 · supersedes: D-0077 · source_ref: none
- reason: group posting was cut; the menu is Roster, Dungeons, Cards and Professions
- previous value: "a roster, groups, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever"

## D-0090 · raw.brandColor = "#a3213f"
- set_by: chosen · locked: no · date: 2026-11-12 · supersedes: D-0066 · source_ref: none
- reason: New guild tabard (Nov 2026): wine banner, gingerbread man, green trim. Owner picked the Tabard direction: wine buttons, gingerbread links and title, green trim line under the header.
- previous value: "#b8282a"

## D-0091 · raw.neutralBase = "#161012"
- set_by: chosen · locked: no · date: 2026-11-12 · supersedes: D-0067 · source_ref: none
- reason: Neutrals lean wine-brown to sit with the tabard.
- previous value: "#171515"
