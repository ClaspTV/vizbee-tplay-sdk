# VizbeeTPlayKit Integration Guide for the T-Play App

The VizbeeTPlayKit SDK is designed specifically to integrate video casting into the T-Play iOS application. It is built on top of the robust Vizbee Continuity SDK and provides a simplified API and a customizable user interface tailored for the T-Play experience.

## Features

- **Simplified Casting API**: A clean, modern API using `async/await` to handle device discovery, connection, and video playback within T-Play.
- **Customizable UI**: Easily customize the cast button and device selection dialog to match the T-Play app\'s branding.
- **Rich Analytics**: A comprehensive analytics listener to track the entire user journey within T-Play, from device discovery to playback events.
- **Multi-App Support**: Designed to work in aggregator app environments like T-Play, allowing the SDK to be started and stopped as needed.

## Installation

Add the SDK to the T-Play project using Swift Package Manager.

1.  In Xcode, go to **File > Add Packages...**
2.  In the search bar, enter the repository URL: `https://github.com/ClaspTV/vizbee-tplay-sdk`
3.  Select the `vizbee-tplay-sdk` package and set the **Dependency Rule** to **Up to Next Major Version**.
4.  Click **Add Package**.

The SDK has the following dependencies which will be automatically added by SPM:
- `VizbeeKit`
- `VizbeeHomeOSKit`
- `GoogleCastSDK`

## Configuration

To enable device discovery on the local network, you must configure the T-Play project\'s entitlements and `Info.plist`.

### 1. Enable Multicast Networking

In the T-Play app’s `.entitlements` file, add the `com.apple.developer.networking.multicast` key with a Boolean value of `true`. If the project does not have an `.entitleaments` file, create one by enabling any capability in the "Signing & Capabilities" tab of the target.

```xml
<key>com.apple.developer.networking.multicast</key>
<true/>
```

### 2. Configure Info.plist for Local Network Access

Add the following keys to the T-Play `Info.plist` file to allow the SDK to discover devices on the local network.

- **`NSBonjourServices`**: An array of service types the app will browse for.
- **`NSLocalNetworkUsageDescription`**: A message that tells the user why T-Play needs access to the local network.

```xml
<key>NSBonjourServices</key>
<array>
    <string>_googlecast._tcp</string>
    <string>_B0A50485._googlecast._tcp</string> <!-- NOTE: Replace \'B0A50485\' with the T-Play receiver appid -->
    <string>_viziocast._tcp</string>
    <string>_amzn-wplay._tcp</string>
</array>
<key>NSLocalNetworkUsageDescription</key>
<string>T-Play needs access to your local network to discover and connect to streaming devices like Smart TVs.</string>
```

## Integration Guide

Integrating the SDK into the T-Play app involves three simple steps.

### Step 1: Initialize the SDK

Initialize the SDK once at app startup, typically in the T-Play `AppDelegate` or the `init()` method of its SwiftUI `App` struct.

```swift
import VizbeeTPlayKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let vizbeeAppId = "YOUR_VIZBEE_APP_ID" // Replace with T-Play\'s actual Vizbee App ID
        VizbeeTPlay.init(appId: vizbeeAppId)
        
        return true
    }
}
```

### Step 2: Add the Cast Button

The SDK provides a `VTPCastButton.SwiftUIView` that automatically reflects the current casting state. Add it to the T-Play app\'s user interface, such as a top navigation bar.

```swift
import SwiftUI
import VizbeeTPlayKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                // T-Play content here
            }
            .navigationBarItems(trailing:
                VTPCastButton.SwiftUIView(size: .init(width: 44, height: 44))
                    .foregroundColor(.black)
            )
            .navigationBarTitle("T-Play", displayMode: .inline)
        }
    }
}
```

### Step 3: Start Video Playback

When a user selects a video to play within T-Play, call the `startVideo()` method. This function handles the entire casting flow, including showing a device picker if necessary. Use `async/await` to handle the result.

```swift
import VizbeeTPlayKit

func playVideo() async {
    let videoInfo = VTPVideoInfo(
        mobileDeepLinkUrl: "https://tplay.com/watch/123", // T-Play deep link
        title: "My Awesome Video",
        subtitle: "Episode 1",
        imageUrl: "https://tplay.com/thumbnail.jpg"
    )

    do {
        let result = try await VizbeeTPlay.startVideo(with: videoInfo)
        switch result.destination {
        case .TV:
            print("Video is casting to the TV.")
        case .MOBILE:
            print("User chose to watch on the phone. Proceed with local playback in T-Play.")
        }
    } catch {
        // Handle different error types from the VTPError enum
        print("Could not start video playback. Error: \(error)")
    }
}
```

## Customizing the UI

### 1. Custom Cast Icons

To replace the default cast icons, add the custom images to the T-Play app\'s `Assets.xcassets` file. Ensure the names match the names used in the SDK\'s assets. The easiest way to do this is to refer to the asset names in the `vizbee-internal-t-play-app-ios` sample project.

### 2. Custom Theme (Colors and Fonts)

The colors and fonts used in the device selection dialog can be customized to match the T-Play branding.

1.  Copy the `TPlayStyle.swift` file from the `vizbee-internal-t-play-app-ios` sample project into the T-Play project.
2.  Modify the colors and fonts in this file to match the T-Play app\'s branding.
3.  Pass an instance of the custom style to the `init()` method.

```swift
// In the custom TPlayStyle.swift for T-Play
struct TPlayTheme: TPlayStyle {
    var primaryColor: Color = .magenta // Example T-Play color
    // ... other style properties
}

// In the T-Play AppDelegate
VizbeeTPlay.init(appId: vizbeeAppId, style: TPlayTheme())
```

## Analytics

The SDK provides a comprehensive set of analytics events for the T-Play integration. To receive them, create a class that conforms to the `VTPAnalyticsListener` protocol and register it with the `VTPAnalyticsManager`.

1.  **Create an Analytics Handler:**

```swift
import Foundation
import VizbeeTPlayKit

class TPlayAnalytics: VTPAnalyticsListener {
    
    static let shared = TPlayAnalytics()
    
    private init() {}
    
    func start() {
        VTPAnalyticsManager.getInstance().addListener(self)
    }
    
    func stop() {
        VTPAnalyticsManager.getInstance().removeListener(self)
    }

    func onEvent(_ event: VTPAnalyticsEvent) {
        print("T-Play Analytics Event Received: \(event)")
        
        switch event {
        // Handle specific events for T-Play\'s analytics service
        case .deviceSelectionDialogShown(let devices):
            print("Device selection dialog was shown with \(devices.count) devices.")
            
        case .tvConnected(let device):
            print("Successfully connected to \(device.friendlyName).")
            
        case .videoStateChanged(let title, _, let state, _, _, _):
            print("Video \'\(title)\' state changed to \(state).")
            
        default:
            break
        }
    }
}
```

2.  **Start Listening:**

Register the listener when the T-Play app starts.

```swift
// In the T-Play AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let vizbeeAppId = "YOUR_VIZBEE_APP_ID"
    VizbeeTPlay.init(appId: vizbeeAppId)
    
    // Start listening for analytics events
    TPlayAnalytics.shared.start()
    
    return true
}
```
