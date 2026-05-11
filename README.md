# ReferralSDK — iOS Swift Package

Official iOS SDK for [ReferralSDK](https://referralsdk.com) — add a referral programme to your iOS app in minutes.

## Requirements

- iOS 16+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**

```
https://github.com/AlexPestre/referralsdk-ios
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AlexPestre/referralsdk-ios", from: "1.0.0")
]
```

## Quick Start

```swift
import ReferralSDK

// Initialize (AppDelegate or @main)
ReferralSDK.configure(
    publicKey: "YOUR_PUBLIC_KEY",
    apiURL: "https://api.referralsdk.com"
)

// Register a referral
try await ReferralSDK.shared.registerReferral(
    referrerId: "user_abc",
    refereeId: "user_xyz"
)

// Redeem a referral code
let result = try await ReferralSDK.shared.redeemCode(
    "ALEX24",
    userId: "user_xyz"
)
```

## Documentation

Full documentation and integration guides are available in your [ReferralSDK dashboard](https://referralsdk.com/apps).

## License

Proprietary — © Alexandre Pestre Conseil et Édition
