# Tell Time 🇬🇧⏰

⚠️ The `main` branch is now unstable. ⚠️

It's using a Beta version of Xcode and SwiftUI. For a stable releasable branch, checkout [Legacy branch](https://github.com/renaudjenny/telltime/tree/legacy).

![Unit Tests](https://github.com/renaudjenny/telltime/workflows/Xcode%20Unit%20Test/badge.svg)

>As a French guy in London, when people told me the time, I was always lost. Now thanks to this app, I can confirm what I hear and what I should say to tell the time 😄.

A tiny iOS Swift project with SwiftUI.

📲 App Store: https://apps.apple.com/gb/app/tell-time-uk/id1496541173

## Screenshots

![Screenshots of the application from an iPhone](docs/assets/iPhoneScreenshots.png)

## Features

* 🐰 Time is written in British english, like **It's twenty past seven AM** for 07:20
* ⏰ Nice clock gives you the selected time
* 👆 You can move the clock arms to set the time
* 🕰 Customise the design of the clock (Classic, Art Nouveau or Drawing Style)
* ⏱  Display minute/hour indicators or limited hour as your convenience
* 🗣 Time can be heard with a British accent
* 🐢 You can slow down the spoken utterance in configuration (Speech rate)
* 👾 Today Widget gives you the current time

## Minimum required

Works with Xcode 12 Beta.
For a the legacy branch working with Xcode 11, please checkout [Legacy branch](https://github.com/renaudjenny/telltime/tree/legacy)

## Libraries used

* ⏰ [SwiftClockUI](https://github.com/renaudjenny/SwiftClockUI): SwiftUI library that provide the Clock, with draggable arms and different design and options
* 🇬🇧 [SwiftPastTen](https://github.com/renaudjenny/SwiftPastTen): Swift framework to provide you the British way to tell the time by passing a "HH:mm" formatted string
* 📸 [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing): Snapshort testing library from **Point-Free** to test views

## TODO

* ✅ Improve UI for iPad format
