
import UIKit

struct Pixel {
    var value: UInt32
    
    var red: UInt8 {
        get { return UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    var green: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    var alpha: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
    
}

struct unsetPixel {
    var redSum: UInt32 = 0
    var blueSum: UInt32 = 0
    var greenSum: UInt32 = 0
    var alphaSum: UInt32 = 0
}

public struct RGBA {
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var width: Int
    var height: Int
    
    init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint(x: 0,y :0), size: image.size))
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        guard let cgImage = imageContext!.makeImage() else {return nil}
        let image = UIImage(cgImage: cgImage)
        return image
    }
}

public func average(image1: UIImage, image2: UIImage) - UIImage{
    
    
}

public func monoColor(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            let average = UInt8((Double(pixel.red) + Double(pixel.blue) + Double(pixel.green))/3.0)
            
            pixel.red = average
            pixel.green = average
            pixel.blue = average
            rgba.pixels[index] = pixel
        }
    }
    return rgba
}




public func contrast(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            totalRed += Int(pixel.red)
            totalGreen += Int(pixel.green)
            totalBlue += Int(pixel.blue)
        }
    }
    
    let pixelCount = rgba.width * rgba.height
    let avgRed = totalRed / pixelCount
    let avgGreen = totalGreen / pixelCount
    let avgBlue = totalBlue / pixelCount
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            let redDelta = Int(pixel.red) - avgRed
            let greenDelta = Int(pixel.green) - avgGreen
            let blueDelta = Int(pixel.blue) - avgBlue
            pixel.red = UInt8(max(min(255, avgRed + 2 * redDelta), 0))
            pixel.green = UInt8(max(min(255, avgGreen + 2 * greenDelta), 0))
            pixel.blue = UInt8(max(min(255, avgBlue + 2 * blueDelta), 0))
            rgba.pixels[index] = pixel
        }
    }
    return rgba
}

public func invert(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            totalRed += Int(pixel.red)
            totalGreen += Int(pixel.green)
            totalBlue += Int(pixel.blue)
        }
    }
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            pixel.red = 255-pixel.red
            pixel.green = 255 - pixel.green
            pixel.blue = 255 - pixel.blue
            rgba.pixels[index] = pixel
        }
    }
    return rgba
}

