<picture>
    <source srcset="./media/logo-dark.svg" media="(prefers-color-scheme: dark)" alt="Rich by T2">
    <img src="./media/logo.svg" alt="Rich by T2">
</picture>

# RichPromizeSDK

A native iOS SDK for integrating with the Rich Promize platform. This SDK allows iOS applications to track user events, manage user profiles, and handle push notifications.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Installation

### Swift Package Manager

The RichPromizeSDK can be installed via Swift Package Manager. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/RichPromizeSDK.git", from: "1.0.0")
]
```

### CocoaPods

Add the following to your Podfile:

```ruby
pod 'RichPromizeSDK', '~> 1.0.0'
```

Then run:

```bash
pod install
```

### Manual Installation

1. Download the RichPromizeSDK.xcframework from the latest release
2. Drag and drop the framework into your project
3. Ensure the framework is added to your target's "Frameworks, Libraries, and Embedded Content" section

## Getting Started

### Initialization

Initialize the SDK in your AppDelegate or SceneDelegate:

```swift
import RichPromizeSDK

// In AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize the SDK
    RichPromizeSDK.shared.initialize(
        baseURL: "https://api.richpromize.com",
        apiKey: "YOUR_API_KEY",
        siteId: "YOUR_SITE_ID"
    )
    
    // Register for push notifications
    registerForPushNotifications()
    
    return true
}

// Register for push notifications
func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        guard granted else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

// Handle device token
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    RichPromizeSDK.shared.updateDeviceToken(token)
}
```

### User Management

#### Create or Update User

```swift
// Create a user with basic information
let user = User(
    name: "John Doe",
    email: "john.doe@example.com",
    userId: "unique-user-id"
)

// You can also add custom data
let user = User(
    name: "D.S",
    email: "D.S@example.com",
    userId: "unique-user-id",
    data: ["age": 30, "preferences": ["theme": "dark"]]
)

// Create or update the user
Task {
    do {
        try await RichPromizeSDK.shared.createOrUpdateUser(user)
        print("User created/updated successfully")
    } catch {
        print("Error creating/updating user: \(error)")
    }
}
```

### Event Tracking

```swift
// Track a screen view
Task {
    do {
        try await RichPromizeSDK.shared.trackEvent(
            name: "Product Screen",
            type: .screen,
            data: ["productId": "12345", "category": "Electronics"]
        )
    } catch {
        print("Error tracking event: \(error)")
    }
}

// Track a custom event
Task {
    do {
        try await RichPromizeSDK.shared.trackEvent(
            name: "Add to Cart",
            type: .event,
            data: ["productId": "12345", "quantity": 2, "price": 99.99]
        )
    } catch {
        print("Error tracking event: \(error)")
    }
}
```

### Handling Push Notifications

```swift
// In AppDelegate or UNUserNotificationCenterDelegate
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    // Check if this is a Rich Promize notification
    if let notificationId = userInfo["notification_id"] as? String {
        // Track that the notification was clicked
        Task {
            do {
                try await RichPromizeSDK.shared.trackNotification(
                    action: .clicked,
                    notificationId: notificationId
                )
            } catch {
                print("Error tracking notification: \(error)")
            }
        }
    }
    
    completionHandler()
}

// Track notification received
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let notificationId = userInfo["notification_id"] as? String {
        Task {
            do {
                try await RichPromizeSDK.shared.trackNotification(
                    action: .delivered,
                    notificationId: notificationId
                )
            } catch {
                print("Error tracking notification: \(error)")
            }
        }
    }
    
    completionHandler(.newData)
}
```

### Device Information

```swift
// Update device information
Task {
    do {
        let deviceInfo = DeviceInfo(
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            deviceModel: UIDevice.current.model,
            osVersion: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            // Add other relevant device information
            attributes: Attributes(
                pushEnabled: true,
                timezone: TimeZone.current.identifier
            )
        )
        
        try await RichPromizeSDK.shared.updateDeviceInfo(deviceInfo)
    } catch {
        print("Error updating device info: \(error)")
    }
}
```

## API Reference

### RichPromizeSDK

The main class for interacting with the Rich Promize platform.

#### Methods

- `initialize(baseURL: String, apiKey: String, siteId: String)` - Initialize the SDK
- `createOrUpdateUser(_ user: User) async throws` - Create or update a user
- `getUser() -> User?` - Get the current user
- `logout() throws` - Log out the current user
- `trackEvent(name: String, type: EventType, data: [String: Any]?) async throws` - Track an event
- `updateDeviceToken(_ token: String) async throws` - Update the device token for push notifications
- `trackNotification(action: NotificationAction, notificationId: String) async throws` - Track notification actions
- `updateDeviceInfo(_ deviceInfo: DeviceInfo) async throws` - Update device information
- `suppressUser(emailOrId: String) async throws` - Suppress a user (opt-out)

### Models

#### User
```swift
struct User {
    let name: String
    let email: String
    let userId: String
    var data: [String: Any]?
}
```

#### EventType
```swift
enum EventType {
    case screen
    case page
    case event
}
```

#### NotificationAction
```swift
enum NotificationAction {
    case delivered
    case clicked
    case opened
}
```

#### DeviceInfo
```swift
struct DeviceInfo {
    let appVersion: String
    let deviceModel: String
    let osVersion: String
    let attributes: Attributes
    // Other device properties
}
```

#### Attributes
```swift
struct Attributes {
    let pushEnabled: Bool
    let timezone: String
    // Other attributes
}
```

## Error Handling

The SDK throws errors for various scenarios. Always use try-catch blocks to handle potential errors:

```swift
do {
    try await RichPromizeSDK.shared.trackEvent(name: "Event Name", type: .event)
} catch {
    // Handle the error
    print("Error: \(error)")
}
```

## License

RichPromizeSDK is available under the MIT license. See the LICENSE file for more info. 
