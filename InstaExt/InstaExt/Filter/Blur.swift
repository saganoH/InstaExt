import UIKit

class Blur: Filter {
    func process(value: CGFloat, image: UIImage) -> UIImage {
        let orientation = image.imageOrientation
        guard let inputCIImage = CIImage(image: image) else {
            fatalError("CIImageへの変換に失敗")
        }
        
        // 画像の縁の引き伸ばし処理
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setValue(inputCIImage, forKey: "inputImage")
        affineClampFilter.setValue(CGAffineTransform(scaleX: 1, y: 1), forKey: "inputTransform")
        let affineClampedImage = affineClampFilter.outputImage
        
        // ぼかし処理
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(affineClampedImage, forKey: "inputImage")
        blurFilter.setValue(value, forKey: "inputRadius")
        let bluredImage = blurFilter.outputImage
        
        // クロップ処理後、CGImageへ変換
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(bluredImage, forKey: "inputImage")
        cropFilter.setValue(inputCIImage.extent, forKey: "inputRectangle")
        guard let croppedImage = cropFilter.outputImage,
              let cgImage = CIContext().createCGImage(croppedImage, from: croppedImage.extent) else { fatalError("CGImageの書き出しに失敗") }
        
        let resultImage = UIImage(cgImage: cgImage, scale: 0, orientation: orientation)
        return resultImage
    }
}
