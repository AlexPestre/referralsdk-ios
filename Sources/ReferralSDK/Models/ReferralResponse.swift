import Foundation

public struct ReferralResponse: Decodable, Sendable {
    public let objectId: String
    public let referrerId: String
    public let refereeId: String
    public let status: String
    public let platform: String?
    public let duplicate: Bool?
    public let createdAt: String?
}
