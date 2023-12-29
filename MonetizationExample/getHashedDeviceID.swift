//
//  getHashedDeviceID.swift
//  MonetizationExample
//
//  Created by Mark on 22.12.23.
//

import Foundation
import AppKit
import CommonCrypto

fileprivate func getHardwareUUID() -> String? {
    let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    if platformExpert != 0 {
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformUUID" as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        return serialNumberAsCFString?.takeRetainedValue() as? String
    }
    return nil
}

func getHashedDeviceID()-> String {
    guard let udid = getHardwareUUID(), let hashedDeviceID = udid.sha256() else {
        fatalError("Cannot retrieve hardware UUID")
    }
    return hashedDeviceID 
}


extension String {
    func sha256() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
