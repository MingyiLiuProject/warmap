import Foundation

enum PBKDF2Error: Error {
    case derivationFailed
}

enum PBKDF2 {
    static func deriveKey(
        password: String,
        salt: Data,
        iterations: Int,
        keyByteCount: Int = 32
    ) throws -> Data {
        let passwordData = Data(password.utf8)
        var key = Data(count: keyByteCount)

        let status = key.withUnsafeMutableBytes { keyBytes in
            salt.withUnsafeBytes { saltBytes in
                passwordData.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.bindMemory(to: Int8.self).baseAddress,
                        passwordData.count,
                        saltBytes.bindMemory(to: UInt8.self).baseAddress,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        keyBytes.bindMemory(to: UInt8.self).baseAddress,
                        keyByteCount
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw PBKDF2Error.derivationFailed
        }
        return key
    }
}
