//
//  Data+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/14/20.
//

import UIKit

extension Data {
    func updateMetadata() -> Data? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
            let ref = CGImageSourceGetType(source),
            let copiedMetadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        
        var metadata = copiedMetadata
        
        if let currentAddress = Current.currentAddressSubject.value {
            metadata[kCGImagePropertyExifDictionary as String] = [kCGImagePropertyExifCameraOwnerName: "hello",
                                                                  kCGImagePropertyExifUserComment: currentAddress]
        }
        
        if let currentLocation = Current.currentLocationSubject.value {
            metadata[kCGImagePropertyGPSDictionary as String] = [kCGImagePropertyGPSLatitudeRef: currentLocation.coordinate.latitude < 0 ? "S" : "N",
                                                                 kCGImagePropertyGPSLatitude: fabs(currentLocation.coordinate.latitude),
                                                                 kCGImagePropertyGPSLongitudeRef: currentLocation.coordinate.longitude < 0 ? "W" : "E",
                                                                 kCGImagePropertyGPSLongitude: fabs(currentLocation.coordinate.longitude),
                                                                 kCGImagePropertyGPSAltitudeRef: currentLocation.altitude < 0 ? 1 : 0,
                                                                 kCGImagePropertyGPSAltitude: fabs(currentLocation.altitude)]
        }
        
        let destinationData = NSMutableData(data: self)
        guard let destination = CGImageDestinationCreateWithData(destinationData, ref, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        if !CGImageDestinationFinalize(destination) {
            return nil
        }
        return destinationData as Data
    }
}




