import CryptoKit
import Foundation
import Security

enum ArchiveCryptoError: LocalizedError {
    case invalidPassword
    case invalidArchive
    case randomGenerationFailed

    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "密码不正确，或文件已损坏。"
        case .invalidArchive:
            return "这不是有效的 Warmap 加密备份。"
        case .randomGenerationFailed:
            return "无法安全生成加密随机数，请重试。"
        }
    }
}

enum ArchiveCryptoService {
    static let iterations = 310_000

    static func encrypt(_ archive: WarmapArchive, password: String) throws -> Data {
        let salt = try randomData(count: 16)
        let keyData = try PBKDF2.deriveKey(
            password: password,
            salt: salt,
            iterations: iterations
        )
        let key = SymmetricKey(data: keyData)
        let plaintext = try JSONEncoder.warmap.encode(archive)
        let sealed = try AES.GCM.seal(plaintext, using: key)

        let envelope = EncryptedArchiveEnvelope(
            iterations: iterations,
            salt: salt,
            nonce: Data(sealed.nonce),
            ciphertext: sealed.ciphertext,
            tag: sealed.tag
        )
        return try JSONEncoder.warmap.encode(envelope)
    }

    static func decrypt(_ data: Data, password: String) throws -> WarmapArchive {
        guard let envelope = try? JSONDecoder.warmap.decode(
            EncryptedArchiveEnvelope.self,
            from: data
        ),
        envelope.format == "warmap-aes-gcm",
        envelope.version == 1,
        envelope.salt.count == 16,
        (100_000...2_000_000).contains(envelope.iterations) else {
            throw ArchiveCryptoError.invalidArchive
        }

        do {
            let keyData = try PBKDF2.deriveKey(
                password: password,
                salt: envelope.salt,
                iterations: envelope.iterations
            )
            let nonce = try AES.GCM.Nonce(data: envelope.nonce)
            let box = try AES.GCM.SealedBox(
                nonce: nonce,
                ciphertext: envelope.ciphertext,
                tag: envelope.tag
            )
            let plaintext = try AES.GCM.open(box, using: SymmetricKey(data: keyData))
            return try JSONDecoder.warmap.decode(WarmapArchive.self, from: plaintext)
        } catch {
            throw ArchiveCryptoError.invalidPassword
        }
    }

    private static func randomData(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            throw ArchiveCryptoError.randomGenerationFailed
        }
        return Data(bytes)
    }
}

private extension JSONEncoder {
    static var warmap: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var warmap: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
