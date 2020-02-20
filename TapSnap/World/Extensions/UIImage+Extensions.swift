//
//  UIImage+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/20/20.
//

import UIKit

extension UIImage {
    func scale(to width: CGFloat) -> UIImage? {
        let oldWidth = size.width
        let scaleFactor = width / oldWidth

        let newHeight = size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
