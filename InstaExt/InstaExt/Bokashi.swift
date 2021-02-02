import UIKit

class Bokashi {
    
    func makeBokashi(value: CGFloat, image: UIImage) -> UIImage {
        let orientation = image.imageOrientation
        let inputImage = CIImage(image: image)
        
        // 画像の縁の引き伸ばし処理
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setValue(inputImage, forKey: "inputImage")
        affineClampFilter.setValue(CGAffineTransform(scaleX: 1, y: 1), forKey: "inputTransform")
        guard let affineClampedImage = affineClampFilter.outputImage else { return image }
        
        // ぼかし処理
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(affineClampedImage, forKey: "inputImage")
        blurFilter.setValue(value, forKey: "inputRadius")
        let bluredImage = blurFilter.outputImage
        
        // クロップ処理
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(bluredImage, forKey: "inputImage")
        cropFilter.setValue(inputImage?.extent, forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!
        
        let cgImage = CIContext().createCGImage(croppedImage, from: croppedImage.extent)!
        let resultImage = UIImage(cgImage: cgImage, scale: 0, orientation: orientation)
        return resultImage
    }
}
