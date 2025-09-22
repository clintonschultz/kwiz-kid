// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KwizKid",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "KwizKid",
            targets: ["KwizKid"]
        ),
    ],
    dependencies: [
        // AWS SDK
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git", from: "2.0.0"),
        
        // RevenueCat
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0"),
        
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        
        // JSON handling
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        
        // Image loading
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
        
        // Analytics
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Crash reporting
        .package(url: "https://github.com/bugsnag/bugsnag-cocoa.git", from: "6.0.0"),
        
        // Local storage
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.0.0"),
        
        // Testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
    ],
    targets: [
        .target(
            name: "KwizKid",
            dependencies: [
                .product(name: "AWSCore", package: "aws-sdk-ios-spm"),
                .product(name: "AWSCognitoIdentityProvider", package: "aws-sdk-ios-spm"),
                .product(name: "AWSMobileClient", package: "aws-sdk-ios-spm"),
                .product(name: "Purchases", package: "purchases-ios"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Bugsnag", package: "bugsnag-cocoa")
            ]
        ),
        .testTarget(
            name: "KwizKidTests",
            dependencies: [
                "KwizKid",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ]
        ),
    ]
)