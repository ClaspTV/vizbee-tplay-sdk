# VizbeeTPlay iOS SDK

A Swift wrapper SDK for Vizbee Continuity SDK that enables seamless video casting from mobile to TV devices.

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` or add via Xcode:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/VizbeeTPlay-iOS.git", .upToNextMajor(from: "1.0.0"))
]
```

## Setup

### 1. Initialize the SDK

Initialize the SDK once at app startup (typically in `AppDelegate` or `App` struct):

```swift
import VizbeeTPlay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Initialize VizbeeTPlay SDK
        VizbeeTPlay.initialize(
            appId: "vzb2379701350",
            options: VizbeeTPlayOptions(debugMode: true)
        )
        
        return true
    }
}
```

### 2. Add Cast Button

#### UIKit - Programmatically

```swift
import VizbeeTPlay

class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let castButton = CastButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    }
}
```

#### UIKit - Storyboard/XIB

1. Add a `UIButton` to your view
2. Set the custom class to `CastButton` in Identity Inspector
3. The button will automatically manage its state

#### SwiftUI

```swift
import SwiftUI
import VizbeeTPlay

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Your content
            Text("Hello, World!")
                .navigationBarItems(trailing: CastButtonRepresentable())
        }
    }
}

struct CastButtonRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CastButton {
        return CastButton()
    }
    
    func updateUIView(_ uiView: CastButton, context: Context) {
        // No updates needed
    }
}
```

### 3. Start Video Playback

When a user wants to watch content, call `startVideo`:

```swift
import VizbeeTPlay

func playVideo() {
    let videoInfo = TPlayVideoInfo(
        mobileDeepLinkUrl: "myapp://watch/123",
        tvDeepLinkUrl: "plex://video/123",
        title: "My Amazing Video",
        subtitle: "Episode 1",
        imageUrl: "https://example.com/thumbnail.jpg",
        isLive: false,
        provider: .plex
    )
    
    Task {
        let result = await VizbeeTPlay.shared.startVideo(
            in: self,
            videoInfo: videoInfo
        )
        
        switch result {
        case .success(let destination):
            switch destination {
            case .tv:
                print("Video will play on TV")
            case .mobile:
                print("Video will play on mobile")
            }
            
        case .failure(let error):
            switch error {
            case .deviceSelectionCancelled:
                // User dismissed device selection - no action needed
                break
                
            case .deviceConnectionCancelled:
                // User cancelled connection - no action needed
                break
                
            case .deviceConnectionError(_, let reason):
                // Show error to user
                showError(message: "Failed to connect: \(reason)")
                
            case .unknownError(let message):
                // Show error to user
                showError(message: message)
            }
        }
    }
}
```

## Video Info Configuration

### TPlayVideoInfo

```swift
public struct TPlayVideoInfo {
    /// Unique identifier (optional, will be auto-generated from TV deep link)
    public var id: String
    
    /// Deep link URL for mobile app playback
    public let mobileDeepLinkUrl: String
    
    /// Deep link URL for TV app playback
    public let tvDeepLinkUrl: String
    
    /// Title of the content
    public let title: String
    
    /// Optional subtitle/description
    public let subtitle: String?
    
    /// Optional thumbnail URL
    public let imageUrl: String?
    
    /// Whether this is live content
    public let isLive: Bool
    
    /// Content provider
    public var provider: Provider?
}
```

### Supported Providers

```swift
public enum Provider {
    case plex
    case tbs
    case tnt
}
```

## Analytics

To track analytics events, implement the `VizbeeTPlayAnalyticsListener` protocol:

```swift
import VizbeeTPlay

class MyAnalytics: VizbeeTPlayAnalyticsListener {
    
    init() {
        VizbeeTPlayAnalyticsManager.shared.addListener(self)
    }
    
    func onEvent(_ event: VizbeeTPlayAnalyticsEvent) {
        switch event {
        case .deviceSelectionShown(let devices):
            print("Device selection shown with \(devices.count) devices")
            
        case .tvSelected(let device):
            print("User selected TV: \(device.friendlyName)")
            
        case .mobileSelected:
            print("User selected mobile playback")
            
        case .tvConnected(let device):
            print("Connected to TV: \(device.friendlyName)")
            
        // Handle other events...
        default:
            break
        }
    }
}
```

## Customization

### Debug Mode

Enable debug logging:

```swift
VizbeeTPlay.initialize(
    appId: "your_app_id",
    options: VizbeeTPlayOptions(debugMode: true)
)
```

### Supported Apps

Configure which apps are supported:

```swift
let options = VizbeeTPlayOptions(
    debugMode: true,
    supportedApps: [
        "plex": "vzb6537171225",
        "tbs": "vzb9390280478"
    ]
)

VizbeeTPlay.initialize(appId: "your_app_id", options: options)
```

## Troubleshooting

### Cast Button Not Showing

- Ensure SDK is initialized before creating CastButton
- Check that devices are on the same network
- Enable debug mode to see detailed logs

### Connection Failures

- Verify network connectivity
- Ensure TV apps are installed on target devices
- Check that deep link URLs are correctly formatted

### Deep Link Format

For Plex:
```
plex://play?guid=<guid>&server=<server_id>
```

## License

Copyright © 2024 Vizbee. All rights reserved.
