
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

public func overLay2(image1: UIImage, image2: UIImage) -> RGBA {
    let rgba1 = RGBA(image: image1)!
    
    
    let rgba2 = RGBA(image: image2)!
    for y in 0..<rgba1.height {
        for x in 0..<rgba1.width {
            
            let index = y * rgba1.width + x
            
            var pixel1 = rgba1.pixels[index]
            let pixel2 = rgba2.pixels[index]
            let newRed = Int(pixel1.red) + Int(Double(pixel2.red)/Double(1.5))
            let newBlue = Int(pixel1.blue) + Int(Double(pixel2.blue)/Double(1.5))
            let newGreen = Int(pixel1.green) + Int(Double(pixel2.green)/Double(1.5))
            
            if (newRed <= 255){
                
                pixel1.red = UInt8(newRed)
            }
            if (newBlue <= 255){
                
                pixel1.blue = UInt8(newBlue)
            }
            if (newGreen <= 255){
                
                pixel1.green = UInt8(newGreen)
            }
            
            rgba1.pixels[index] = pixel1
        }
    }
    
    return rgba1
}

public func overLay(images: [UIImage]) -> RGBA {
    let rgba1 = RGBA(image: images[0])!
    
    for z in 1..<images.count{
        print(z)
        let rgba2 = RGBA(image: images[z])!
        for y in 0..<rgba1.height {
            for x in 0..<rgba1.width {
                
                let index = y * rgba1.width + x
                
                var pixel1 = rgba1.pixels[index]
                let pixel2 = rgba2.pixels[index]
                let newRed = Int(pixel1.red) + Int(Double(pixel2.red)/Double(z))
                let newBlue = Int(pixel1.blue) + Int(Double(pixel2.blue)/Double(z))
                let newGreen = Int(pixel1.green) + Int(Double(pixel2.green)/Double(z))
                
                if (newRed <= 255){
                    
                    pixel1.red = UInt8(newRed)
                }
                if (newBlue <= 255){
                    
                    pixel1.blue = UInt8(newBlue)
                }
                if (newGreen <= 255){
                    
                    pixel1.green = UInt8(newGreen)
                }
                
                rgba1.pixels[index] = pixel1
            }
        }
    }
    return rgba1
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



public func addImages(images: [UIImage]) -> RGBA {
    let newImage = RGBA(image: images[0])!
    var falseImage = [unsetPixel]()
    let imageTotal = images.count
    
    
    for z in 1...images.count{
        let rgba = RGBA(image: images[z])!
        
        for _ in 0..<rgba.height*rgba.width{
            falseImage.append(unsetPixel.init(redSum: 0, blueSum: 0, greenSum: 0, alphaSum: 0))
        }
        
        for y in 0..<rgba.height {
            for x in 0..<rgba.width {
                
                let index = y * rgba.width + x
                let pixel = rgba.pixels[index]
                let red = UInt8(pixel.red)
                let blue = UInt8(pixel.green)
                let green = UInt8(pixel.blue)
                let alpha = UInt8(pixel.alpha)
                
                var myUnsetPixel = falseImage[index]
                
                myUnsetPixel.redSum += UInt32(red*red)
                myUnsetPixel.blueSum += UInt32(blue*blue)
                myUnsetPixel.greenSum += UInt32(green*green)
                myUnsetPixel.alphaSum += UInt32(alpha*alpha)
                falseImage[index] = myUnsetPixel
                
            }
        }
        if z == images.count{
            for y in 0..<rgba.height {
                for x in 0..<rgba.width {
                    let index = y * rgba.width + x
                    let myUnsetPixel = falseImage[index]
                    let pixelCount : Double = Double(rgba.width * rgba.height)
                    
                    newImage.pixels[index].red = UInt8(max(min(255, sqrt(Double(myUnsetPixel.redSum)/(pixelCount*Double(imageTotal)))), 0))
                    newImage.pixels[index].green = UInt8(max(min(255, sqrt(Double(myUnsetPixel.blueSum)/(pixelCount*Double(imageTotal)))), 0))
                    newImage.pixels[index].blue = UInt8(max(min(255, sqrt(Double(myUnsetPixel.greenSum)/(pixelCount*Double(imageTotal)))), 0))
                    newImage.pixels[index].alpha = UInt8(max(min(255, sqrt(Double(myUnsetPixel.alphaSum)/(pixelCount*Double(imageTotal)))), 0))
                }
            }
        }
    }
    
    return newImage
}

public func contrast3(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    var brightPix : Pixel = rgba.pixels[0]
    
    var brightestPixelValue = Double(0)
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            
            let red = Double(pixel.red)
            let blue = Double(pixel.blue)
            let green = Double(pixel.green)
            let pixelAverage = (red + blue + green)/3.0
            
            if (brightestPixelValue < (pixelAverage)){
                brightestPixelValue = (pixelAverage)
                brightPix = pixel
            }
        }
    }
    
    let brightRed = Double(brightPix.red)
    let brightBlue = Double(brightPix.blue)
    let brightGreen = Double(brightPix.green)
    
    
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            var red = Double(pixel.red)
            var blue = Double(pixel.blue)
            var green = Double(pixel.green)
            
            red = max(min(brightRed, red),0)
            blue = max(min(brightBlue, blue),0)
            green = max(min(brightGreen, green),0)
            
            red = max(min(((red)/(brightRed))*255, 255),0)
            blue = max(min(((blue)/(brightBlue))*255, 255),0)
            green = max(min(((green + 10)/(brightGreen))*255, 255),0)
            
            
            pixel.red = UInt8(red)
            pixel.green = UInt8(blue)
            pixel.blue = UInt8(green)
            
            rgba.pixels[index] = pixel
        }
    }
    return rgba
}



public func contrast2(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    var brightPix : Pixel = rgba.pixels[0]
    var dimPix : Pixel = rgba.pixels[0]
    var brightestPixelValue = Double(0)
    var dimmestPixelValue = Double(0)
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            
            let red = Double(pixel.red)
            let blue = Double(pixel.blue)
            let green = Double(pixel.green)
            let pixelAverage = (red + blue + green)/3.0
            
            if (brightestPixelValue < (pixelAverage)){
                brightestPixelValue = (pixelAverage)
                brightPix = pixel
            }
            if (dimmestPixelValue > (pixelAverage)){
                dimmestPixelValue = (pixelAverage)
                dimPix = pixel
            }
        }
    }
    
    let brightRed = Double(brightPix.red)
    let brightBlue = Double(brightPix.blue)
    let brightGreen = Double(brightPix.green)
    let dimRed = Double(dimPix.red)
    let dimBlue = Double(dimPix.blue)
    let dimGreen = Double(dimPix.green)
    
    
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            var red = Double(pixel.red)
            var blue = Double(pixel.blue)
            var green = Double(pixel.green)
            
            red = max(min(brightRed, red),0)
            blue = max(min(brightBlue, blue),0)
            green = max(min(brightGreen, green),0)
            
            red = max(min(((red-dimRed)/(brightRed - dimRed))*255, 255),0)
            blue = max(min(((blue-dimBlue)/(brightBlue - dimBlue))*255, 255),0)
            green = max(min(((green-dimGreen)/(brightGreen - dimGreen))*255, 255),0)
            
            pixel.red = UInt8(red)
            pixel.green = UInt8(blue)
            pixel.blue = UInt8(green)
            
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

