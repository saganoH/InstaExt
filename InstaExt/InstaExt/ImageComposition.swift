import UIKit

class ImageComposition {
    func process(sourceImageView: UIImageView, filterImageView: UIImageView) -> UIImage? {
        guard let sourceImage = sourceImageView.image else {
            return sourceImageView.image
        }
        
        // 余白を含むマスク画像の生成
        UIGraphicsBeginImageContext(filterImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        filterImageView.layer.render(in: context)
        guard let maskedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return sourceImage
        }
        UIGraphicsEndImageContext()
        
        // マスク画像の余白を削除
        let resizedMaskImage = maskedImage.cutout(sourceImage: sourceImage)
        
        // 元画像とマスク画像の合成処理
        UIGraphicsBeginImageContext(sourceImage.size)
        sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: sourceImage.size))
        resizedMaskImage.draw(in: CGRect(origin: CGPoint.zero, size: sourceImage.size))
        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resultImage = drawedImage else {
            return sourceImage
        }
        return resultImage
    }
}

extension UIImage {
    func cutout(sourceImage: UIImage) -> UIImage {
        let scale: CGFloat
        let resizedImage: UIImage
        let spaceSize: CGFloat
        let trimmingArea: CGRect
        
        // 元画像の向きを判断しトリミングエリアを決定
        if sourceImage.size.width > sourceImage.size.height {
            scale = sourceImage.size.width / size.width
            resizedImage = scaleImage(scaleSize: scale)
            spaceSize = (resizedImage.size.height - sourceImage.size.height ) / 2
            trimmingArea = CGRect(x: 0,
                                  y: spaceSize,
                                  width: sourceImage.size.width,
                                  height: sourceImage.size.height)
        } else {
            scale = sourceImage.size.height / size.height
            resizedImage = scaleImage(scaleSize: scale)
            spaceSize = (resizedImage.size.width - sourceImage.size.width ) / 2
            trimmingArea = CGRect(x: spaceSize,
                                  y: 0,
                                  width: sourceImage.size.width,
                                  height: sourceImage.size.height)
        }
        return resizedImage.cropping(to: trimmingArea)
    }
    
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: size.width * scaleSize, height: size.height * scaleSize)
        
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        guard let reSizeImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    func cropping(to: CGRect) -> UIImage {
        var isOpaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .none, .noneSkipLast, .noneSkipFirst:
                isOpaque = true
            default:
                break
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(to.size, isOpaque, scale)
        draw(at: CGPoint(x: -to.origin.x, y: -to.origin.y))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return result
    }
}
