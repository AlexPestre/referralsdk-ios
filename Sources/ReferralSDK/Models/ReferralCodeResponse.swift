import Foundation

public struct ReferralCodeResponse: Decodable, Sendable {
    public let objectId: String
    public let code: String
    public let referrerId: String
    public let status: String
    public let createdAt: String?
}
