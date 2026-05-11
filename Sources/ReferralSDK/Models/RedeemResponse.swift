import Foundation

public struct RedeemResponse: Decodable, Sendable {
    public let valid: Bool
    public let result: String
    public let message: String?
    public let referral: ReferralDetail?

    public struct ReferralDetail: Decodable, Sendable {
        public let objectId: String
        public let referrerId: String
        public let refereeId: String
        public let status: String
        public let platform: String?
    }
}
