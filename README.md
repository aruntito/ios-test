# Pocket Tasks — native iOS sample

A deliberately small native iOS app built with **SwiftUI**. This repository is a hands-on codebase sample, not a web wrapper.

## Open in Xcode

1. Open `ios-test.xcodeproj`.
2. Select the `ios-test` scheme and an iOS 17+ simulator or device.
3. Press Run.

## What it demonstrates

- A SwiftUI app entry point and a `NavigationStack`
- Reusable row views and native system controls
- State-driven UI with `@State` and `@Binding`
- Local persistence with `UserDefaults` and `Codable`
- Add, complete, and swipe-to-delete interactions
- A sheet-based form and an empty state

## Project layout

```
ios-test/
├── IOSTestApp.swift
└── ContentView.swift
ios-test.xcodeproj/
└── project.pbxproj
```

No third-party dependencies, backend, account, or network access required. Minimum deployment target: iOS 17.
