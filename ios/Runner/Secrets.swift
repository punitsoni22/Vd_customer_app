import Foundation

enum Secrets {
    static var googleMapsApiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String else {
            fatalError("GOOGLE_MAPS_API_KEY not found in Info.plist")
        }
        return apiKey
    }
}
