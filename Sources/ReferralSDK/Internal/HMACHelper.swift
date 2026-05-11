import CryptoKit
import Foundation

enum HMACHelper {
    static func sign(bodyJSON: String, hmacSecret: String) -> (signature: String, timestamp: String) {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let bodyHash = SHA256.hash(data: Data(bodyJSON.utf8))
            .map { String(format: "%02x", $0) }.joined()
        let message = "\(timestamp).POST.\(bodyHash)"
        let key = SymmetricKey(data: Data(hmacSecret.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        let signature = Data(mac).map { String(format: "%02x", $0) }.joined()
        return (signature, timestamp)
    }
}
