import SwiftUI

/// Observable wrapper pour utiliser ReferralSDK dans SwiftUI.
///
/// Usage :
/// ```swift
/// @StateObject var referral = ReferralEnvironment()
///
/// Button("Partager mon code") {
///     Task { await referral.loadCode(referrerId: userId, programId: programId) }
/// }
/// Text(referral.referralCode ?? "Chargement...")
/// ```
@MainActor
public final class ReferralEnvironment: ObservableObject {
    @Published public var referralCode: String?
    @Published public var isLoading = false
    @Published public var error: String?
    @Published public var lastRedeemResult: RedeemResponse?

    private var sdk: ReferralSDK {
        guard let s = ReferralSDK.shared else {
            fatalError("ReferralSDK not configured. Call ReferralSDK.configure() first.")
        }
        return s
    }

    public init() {}

    public func loadCode(referrerId: String, programId: String, customCode: String? = nil) async {
        isLoading = true
        error = nil
        do {
            let response = try await sdk.generateReferralCode(referrerId: referrerId, programId: programId, customCode: customCode)
            referralCode = response.code
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    public func redeem(code: String, refereeId: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await sdk.redeemReferralCode(code: code, refereeId: refereeId)
            lastRedeemResult = response
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
