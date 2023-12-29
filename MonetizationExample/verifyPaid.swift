//
//  verifyPaid.swift
//  MonetizationExample
//
//  Created by Mark on 22.12.23.
//

import Foundation

func verifyPaid() async -> Bool {
    let url = URL(string: "http://localhost:3000/publicKey")!
    let request = URLRequest(url: url)
    
    do {
        let (publicKeyData, _) = try await URLSession.shared.data(for: request)
        let url = URL(string: "http://localhost:3000/verifyPaid")!
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let hashedDeviceID = getHashedDeviceID()
        let payload: [String: String] = ["hashedDeviceID": hashedDeviceID]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                return false
            }
            
            let signatureFromServer = String(decoding: data, as: UTF8.self)
            
            guard let publicKey = loadPublicKey(from: publicKeyData) else {
                print("Cannot load public key")
                return false
            }
            
            return verifySignature(message: "paid:\(hashedDeviceID)", signature: signatureFromServer, publicKey: publicKey)

        }
        catch {
            print("Error: \(error)")
            return false
        }
    }
    catch {
        print("Error: \(error)")
        return false
    }
}

func loadPublicKey(from publicKeyData: Data) -> SecKey? {
    
    guard let pemString = String(data: publicKeyData, encoding: .utf8) else {
        return nil
    }

    let lines = pemString.components(separatedBy: "\n").filter { !$0.hasPrefix("-----") }
    let keyString = lines.joined()
    
    guard let pemData = Data(base64Encoded: keyString) else {
        return nil
    }

    let options: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits as String: 4096
    ]

    return SecKeyCreateWithData(pemData as CFData, options as CFDictionary, nil)
}

func verifySignature(message: String, signature: String, publicKey: SecKey) -> Bool {
    
    guard let messageData = message.data(using: .utf8),
          let signatureData = Data(base64Encoded: signature) else {
        return false
    }

    let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256

    guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
        return false
    }

    var error: Unmanaged<CFError>?
    let result = SecKeyVerifySignature(publicKey, algorithm, messageData as CFData, signatureData as CFData, &error)

    return result
}
