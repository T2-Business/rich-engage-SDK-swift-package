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
    Task {
        try? await RICH_PROMIZE_SDK.shared.updateDeviceToken(deviceToken: token)
    }
}
```

### User Management

#### Create or Update User

```swift
// Create a user with basic information
let user = User(
    email: "john.doe@example.com",
    localId: "unique-user-id",
    name: "John Doe",
    mobile: "+1234567890"
)

// Create or update the user
Task {
    do {
        try await RICH_PROMIZE_SDK.shared.createUser(user: user)
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
        try await RICH_PROMIZE_SDK.shared.addEvent(
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
        try await RICH_PROMIZE_SDK.shared.addEvent(
            name: "FinancingApplication",
            type: .event,
            data: [
                "stageName": "Submitted",
                "stageStatus": "Pending",
                "applicationStatus": "Under Review",
                "applicationId": "987654321",
                "loanAmount": "25000.5"
            ]
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
                try await RICH_PROMIZE_SDK.shared.trackNotificationActivity(
                    notificationId: notificationId,
                    activityType: .clicked
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
                try await RICH_PROMIZE_SDK.shared.trackNotificationActivity(
                    notificationId: notificationId,
                    activityType: .delivered
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
// Persist FCM/APNs token and sync device info for the current user
Task {
    do {
        try await RICH_PROMIZE_SDK.shared.updateDeviceToken(deviceToken: fcmToken)
    } catch {
        print("Error updating device token: \(error)")
    }
}

// Or sync device info explicitly (uses stored user id as customer_id)
Task {
    do {
        try await RICH_PROMIZE_SDK.shared.updateDeviceInfo(deviceToken: fcmToken)
    } catch {
        print("Error updating device info: \(error)")
    }
}
```

## API Reference

### RichPromizeSDK

The main class for interacting with the Rich Promize platform.

#### Methods

- `initialize(apiKey: String, siteId: String, baseUrl: String, pushEnabled: Bool, appVersion: String, isSubscribed: Bool)` - Initialize the SDK
- `createUser(user: User) async throws` - Create a user (`email`, `local_id`, `name`, `mobile`)
- `updateUser(user: User) async throws` - Update a user
- `getUser() -> User?` - Get the current user
- `logout() async throws` - Log out the current user
- `addEvent(name: String, type: EventType, data: [String: Any]?) async throws` - Track an event (uses current `localId` as `identifier`)
- `updateDeviceToken(deviceToken: String) async throws` - Save FCM/APNs token and sync device info
- `updateDeviceInfo(deviceToken: String?) async throws` - Sync device info (`platform`, `customer_id`, `device_token`, `attributes`)
- `trackNotificationActivity(notificationId: String, activityType: NotificationAction) async throws` - Track notification actions

### Models

#### User
```swift
struct User {
    let email: String
    let localId: String // API field: local_id
    let name: String
    let mobile: String
}
```

#### DeviceInfo
```swift
struct DeviceInfo {
    let platform: String // "iOS"
    let deviceToken: String?
    let attributes: Attributes?
}
```

#### Attributes
```swift
struct Attributes {
    let deviceOs: String
    let deviceModel: String
    let deviceLocale: String
    let pushEnabled: Bool
    let pushToken: String?
    let pioSdkVersion: String?
    let appVersion: String?
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

## Error Handling

The SDK throws errors for various scenarios. Always use try-catch blocks to handle potential errors:

```swift
do {
    try await RICH_PROMIZE_SDK.shared.addEvent(name: "Event Name", type: .event, data: nil)
} catch {
    // Handle the error
    print("Error: \(error)")
}
```

## License

RichPromizeSDK is available under the MIT license. See the LICENSE file for more info. 
