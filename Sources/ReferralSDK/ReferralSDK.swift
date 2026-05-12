import Foundation

/// Erreurs retournées par le SDK
public enum ReferralSDKError: Error, LocalizedError {
    case notConfigured
    case invalidURL
    case networkError(String)
    case serverError(String)
    case httpError(Int)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:       return "ReferralSDK not configured. Call ReferralSDK.configure() first."
        case .invalidURL:          return "Invalid server URL."
        case .networkError(let m): return "Network error: \(m)"
        case .serverError(let m):  return "Server error: \(m)"
        case .httpError(let c):    return "HTTP error \(c)"
        }
    }
}

/// Client principal ReferralSDK
public final class ReferralSDK: @unchecked Sendable {

    // MARK: - Shared instance
    public static var shared: ReferralSDK?

    // MARK: - Configuration
    public struct Configuration: Sendable {
        public let apiKeyPublic: String
        public let hmacSecret: String
        /// URL du proxy API (défaut : https://api.referralsdk.com)
        /// Ne modifiez pas sauf pour les tests en local.
        public let serverURL: String

        public init(
            apiKeyPublic: String,
            hmacSecret: String,
            serverURL: String = "https://api.referralsdk.com"
        ) {
            self.apiKeyPublic = apiKeyPublic
            self.hmacSecret   = hmacSecret
            self.serverURL    = serverURL
        }
    }

    private let config: Configuration
    private let apiClient: APIClient

    // MARK: - Init
    private init(config: Configuration) {
        self.config = config
        self.apiClient = APIClient(serverURL: config.serverURL)
    }

    /// Configure le SDK. A appeler une fois au démarrage de l'app (AppDelegate ou @main).
    @discardableResult
    public static func configure(_ configuration: Configuration) -> ReferralSDK {
        let sdk = ReferralSDK(config: configuration)
        shared = sdk
        return sdk
    }

    // MARK: - Private helpers

    private func buildPayload(bodyJSON: String, extra: [String: Any] = [:]) -> [String: Any] {
        let (signature, timestamp) = HMACHelper.sign(bodyJSON: bodyJSON, hmacSecret: config.hmacSecret)
        var payload: [String: Any] = [
            "apiKeyPublic": config.apiKeyPublic,
            "signature":    signature,
            "timestamp":    timestamp,
        ]
        if let bodyDict = (try? JSONSerialization.jsonObject(with: Data(bodyJSON.utf8))) as? [String: Any] {
            payload.merge(bodyDict) { _, new in new }
        }
        payload.merge(extra) { _, new in new }
        return payload
    }

    // MARK: - Public API

    /// Génère (ou retourne) le code de parrainage d'un utilisateur.
    /// - Parameters:
    ///   - referrerId: Identifiant opaque du parrain (UUID stable de l'appareil)
    ///   - programKey: Clé publique du programme (prk_xxx — visible dans le dashboard)
    ///   - customCode: Code personnalisé optionnel (ex: "ALEX25")
    ///   - referrerEmail: Email du parrain (pour l'affichage dans le dashboard et le paiement)
    public func generateReferralCode(
        referrerId: String,
        programKey: String,
        customCode: String? = nil,
        referrerEmail: String? = nil
    ) async throws -> ReferralCodeResponse {
        let bodyJSON = JSONBuilder.generateCode(referrerId: referrerId, programKey: programKey, customCode: customCode)
        var extra: [String: Any] = ["platform": "ios"]
        if let email = referrerEmail { extra["referrerEmail"] = email }
        let payload  = buildPayload(bodyJSON: bodyJSON, extra: extra)
        return try await apiClient.call(function: "generateReferralCode", payload: payload)
    }

    /// Valide un code de parrainage saisi par un nouvel utilisateur.
    /// - Parameters:
    ///   - code: Code saisi ou extrait d'un lien deep link
    ///   - refereeId: Identifiant opaque du nouvel utilisateur
    ///   - deviceId: Identifiant stable de l'appareil (automatique si nil)
    public func redeemReferralCode(
        code: String,
        refereeId: String,
        deviceId: String? = nil
    ) async throws -> RedeemResponse {
        let resolvedDeviceId = deviceId ?? KeychainDeviceID.value
        let bodyJSON = JSONBuilder.redeemCode(code: code, refereeId: refereeId, deviceId: resolvedDeviceId)
        let payload  = buildPayload(bodyJSON: bodyJSON, extra: ["platform": "ios"])
        return try await apiClient.call(function: "redeemReferralCode", payload: payload)
    }

    /// Crée un parrainage directement (sans code).
    /// - Parameters:
    ///   - referrerId: Identifiant opaque du parrain
    ///   - refereeId: Identifiant opaque du filleul
    ///   - programId: ObjectId du programme
    ///   - metadata: Données optionnelles (plan, montant...)
    ///   - idempotencyKey: Clé d'idempotence pour éviter les doublons
    public func createReferral(
        referrerId: String,
        refereeId: String,
        programId: String,
        metadata: [String: Any]? = nil,
        idempotencyKey: String? = nil
    ) async throws -> ReferralResponse {
        let bodyJSON = JSONBuilder.createReferral(
            referrerId: referrerId,
            refereeId:  refereeId,
            programId:  programId,
            metadata:   metadata,
            idempotencyKey: idempotencyKey
        )
        let payload = buildPayload(bodyJSON: bodyJSON)
        return try await apiClient.call(function: "createReferral", payload: payload)
    }
}
