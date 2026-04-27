import Foundation

enum EnvironmentDevelopment {
    case development
    case production
}

struct APIConfig {
    static let environment: EnvironmentDevelopment = .development // Swap to .production for release
    
    static var baseURL: URL {
        switch environment {
        case .development:
            return URL(string: "https://cubiko_api-staging.diegoivan-mae.workers.dev")!
        case .production:
            // Change to your actual production URL when ready
            return URL(string: "https://cubiko_api-staging.diegoivan-mae.workers.dev")!
        }
    }
}
