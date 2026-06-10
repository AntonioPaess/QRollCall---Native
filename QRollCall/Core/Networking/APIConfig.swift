import Foundation

enum APIConfig {
    static let baseURL: URL = {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "QRollCallAPIBaseURL") as? String,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "http://localhost:8080")!
    }()
}
