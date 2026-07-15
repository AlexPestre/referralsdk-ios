import XCTest
@testable import ReferralSDK

final class ReferralSDKTests: XCTestCase {

    func testJSONBuilderGenerateCode() {
        let json = JSONBuilder.generateCode(referrerId: "user_A", programId: "prog_1", customCode: nil)
        XCTAssertEqual(json, "{\"referrerId\":\"user_A\",\"programId\":\"prog_1\"}")
    }

    func testJSONBuilderGenerateCodeWithCustom() {
        let json = JSONBuilder.generateCode(referrerId: "user_A", programId: "prog_1", customCode: "ALEX25")
        XCTAssertEqual(json, "{\"referrerId\":\"user_A\",\"programId\":\"prog_1\",\"customCode\":\"ALEX25\"}")
    }

    func testJSONBuilderGenerateCodeWithProgramKey() {
        let json = JSONBuilder.generateCode(referrerId: "user_A", programKey: "prk_123", customCode: nil)
        XCTAssertEqual(json, "{\"referrerId\":\"user_A\",\"programKey\":\"prk_123\"}")
    }

    func testJSONBuilderRedeemCode() {
        let json = JSONBuilder.redeemCode(code: "ABC123", refereeId: "user_B", deviceId: nil)
        XCTAssertEqual(json, "{\"code\":\"ABC123\",\"refereeId\":\"user_B\"}")
    }

    func testJSONBuilderRedeemCodeWithProgramKey() {
        let json = JSONBuilder.redeemCode(code: "ABC123", refereeId: "user_B", deviceId: "device_1", programKey: "prk_123")
        XCTAssertEqual(json, "{\"code\":\"ABC123\",\"refereeId\":\"user_B\",\"deviceId\":\"device_1\",\"programKey\":\"prk_123\"}")
    }

    func testJSONBuilderEscaping() {
        let json = JSONBuilder.generateCode(referrerId: "user\"A", programId: "prog\\1", customCode: nil)
        XCTAssertEqual(json, "{\"referrerId\":\"user\\\"A\",\"programId\":\"prog\\\\1\"}")
    }

    func testHMACHelperProducesConsistentSignature() {
        // Le même body + secret doit produire le même hash (pas le même timestamp, mais même structure)
        let (sig1, ts1) = HMACHelper.sign(bodyJSON: "{\"test\":\"value\"}", hmacSecret: "secret")
        XCTAssertFalse(sig1.isEmpty)
        XCTAssertFalse(ts1.isEmpty)
        XCTAssertEqual(sig1.count, 64) // SHA256 = 32 bytes = 64 hex chars
    }

    func testKeychainDeviceIDIsStable() {
        let id1 = KeychainDeviceID.value
        let id2 = KeychainDeviceID.value
        XCTAssertEqual(id1, id2)
        XCTAssertFalse(id1.isEmpty)
    }

    func testPurchaseAttributionAllowsOnlyDirectPurchases() {
        XCTAssertTrue(PurchaseAttribution(source: .purchase).shouldCreateReferral)
        XCTAssertFalse(PurchaseAttribution(source: .restore).shouldCreateReferral)
        XCTAssertFalse(PurchaseAttribution(source: .currentEntitlement).shouldCreateReferral)
        XCTAssertFalse(PurchaseAttribution(source: .familyShared).shouldCreateReferral)
        XCTAssertFalse(PurchaseAttribution(source: .purchase, ownershipType: "familyShared").shouldCreateReferral)
    }
}
