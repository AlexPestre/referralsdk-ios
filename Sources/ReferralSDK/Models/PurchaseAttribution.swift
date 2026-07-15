import Foundation

#if canImport(StoreKit)
import StoreKit
#endif

/// Décrit l'origine d'un achat avant de créer un parrainage.
public struct PurchaseAttribution: Sendable {
    public enum Source: String, Sendable {
        /// Achat réellement déclenché par l'utilisateur.
        case purchase
        /// Restauration explicite d'un achat passé.
        case restore
        /// Droit déjà existant relu au démarrage ou depuis Transaction.currentEntitlements.
        case currentEntitlement
        /// Droit obtenu via le partage familial Apple.
        case familyShared
    }

    public let source: Source
    public let transactionId: String?
    public let originalTransactionId: String?
    public let ownershipType: String?

    public init(
        source: Source,
        transactionId: String? = nil,
        originalTransactionId: String? = nil,
        ownershipType: String? = nil
    ) {
        self.source = source
        self.transactionId = transactionId
        self.originalTransactionId = originalTransactionId
        self.ownershipType = ownershipType
    }

    /// Seul un achat direct doit déclencher un parrainage.
    public var shouldCreateReferral: Bool {
        source == .purchase && ownershipType != "familyShared"
    }

    var metadata: [String: Any] {
        var data: [String: Any] = [
            "purchaseSource": source.rawValue,
            "referralEligiblePurchase": shouldCreateReferral,
        ]
        if let transactionId { data["transactionId"] = transactionId }
        if let originalTransactionId { data["originalTransactionId"] = originalTransactionId }
        if let ownershipType { data["ownershipType"] = ownershipType }
        return data
    }

    #if canImport(StoreKit)
    @available(iOS 15.0, macOS 12.0, *)
    public init(transaction: Transaction, source: Source) {
        let ownership: String
        switch transaction.ownershipType {
        case .purchased:
            ownership = "purchased"
        case .familyShared:
            ownership = "familyShared"
        default:
            ownership = "unknown"
        }

        self.init(
            source: ownership == "familyShared" ? .familyShared : source,
            transactionId: String(transaction.id),
            originalTransactionId: String(transaction.originalID),
            ownershipType: ownership
        )
    }
    #endif
}
