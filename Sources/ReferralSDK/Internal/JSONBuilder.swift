import Foundation

enum JSONBuilder {
    // Echappe les caractères spéciaux JSON dans une string
    static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
         .replacingOccurrences(of: "\"", with: "\\\"")
         .replacingOccurrences(of: "\n", with: "\\n")
         .replacingOccurrences(of: "\r", with: "\\r")
         .replacingOccurrences(of: "\t", with: "\\t")
    }

    // generateReferralCode body
    static func generateCode(referrerId: String, programId: String, customCode: String?) -> String {
        var s = "{\"referrerId\":\"\(escape(referrerId))\",\"programId\":\"\(escape(programId))\""
        if let c = customCode { s += ",\"customCode\":\"\(escape(c))\"" }
        s += "}"
        return s
    }

    // redeemReferralCode body
    static func redeemCode(code: String, refereeId: String, deviceId: String?) -> String {
        var s = "{\"code\":\"\(escape(code))\",\"refereeId\":\"\(escape(refereeId))\""
        if let d = deviceId { s += ",\"deviceId\":\"\(escape(d))\"" }
        s += "}"
        return s
    }

    // createReferral body
    static func createReferral(referrerId: String, refereeId: String, programId: String, metadata: [String: Any]?, idempotencyKey: String?) -> String {
        var s = "{\"referrerId\":\"\(escape(referrerId))\",\"refereeId\":\"\(escape(refereeId))\",\"programId\":\"\(escape(programId))\""
        if let meta = metadata,
           let metaData = try? JSONSerialization.data(withJSONObject: meta),
           let metaStr = String(data: metaData, encoding: .utf8) {
            s += ",\"metadata\":\(metaStr)"
        }
        if let key = idempotencyKey { s += ",\"idempotencyKey\":\"\(escape(key))\"" }
        s += "}"
        return s
    }
}
