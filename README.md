# Performance Hud for SwiftUI

![CleanShot 2025-06-19 at 09 29 09@2x](https://github.com/user-attachments/assets/566fe067-d86e-4177-8959-eb47c18f47f6)

Tiny overlay for SwiftUI that shows live FPS and memory so you can spot frame drops before users do. Inspired by React Native’s Perf Monitor, built with only public iOS APIs.

## Usage

```swift
import PerformanceHUD


.overlay {
    PerfHUD() // init also exposes position and chart type
}
```
