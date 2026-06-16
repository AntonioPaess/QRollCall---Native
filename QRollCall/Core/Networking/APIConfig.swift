import Foundation

enum APIConfig {
    static let baseURL: URL = {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "QRollCallAPIBaseURL") as? String,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "https://137.131.230.45.sslip.io")!
    }()
}
