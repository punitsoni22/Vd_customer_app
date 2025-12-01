import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // API key is securely loaded from Secrets.xcconfig via Info.plist
      if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
          GMSServices.provideAPIKey(apiKey)
      } else {
          print("⚠️ Warning: GOOGLE_MAPS_API_KEY not found in Info.plist")
      }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
