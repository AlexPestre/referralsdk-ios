import Foundation

struct APIClient {
    /// URL du proxy ReferralSDK (les credentials Parse restent côté serveur)
    let serverURL: String

    func call<T: Decodable>(function: String, payload: [String: Any]) async throws -> T {
        guard let url = URL(string: "\(serverURL)/functions/\(function)") else {
            throw ReferralSDKError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Le SDK injecte la plateforme — les credentials Parse sont gérés par le proxy
        request.setValue("ios",              forHTTPHeaderField: "X-RK-Platform")
        var payloadWithPlatform = payload
        payloadWithPlatform["platform"] = "ios"
        request.httpBody = try JSONSerialization.data(withJSONObject: payloadWithPlatform)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ReferralSDKError.networkError("Invalid response")
        }

        // Parse Server renvoie { "result": {...} } ou { "error": "..." }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let error = json["error"] as? String {
                throw ReferralSDKError.serverError(error)
            }
            if let result = json["result"] {
                let resultData = try JSONSerialization.data(withJSONObject: result)
                return try JSONDecoder().decode(T.self, from: resultData)
            }
        }

        guard http.statusCode == 200 else {
            throw ReferralSDKError.httpError(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
