import UIKit

class ImageComposition {
    func process(source: UIImageView, filter: UIImageView) -> UIImage? {
        guard let sourceImage = source.image else {
            return source.image
        }
        
        // 余白を含むマスク画像の生成
        UIGraphicsBeginImageContext(filter.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        filter.layer.render(in: context)
        guard let maskedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return sourceImage
        }
        UIGraphicsEndImageContext()
        
        // マスク画像の余白を削除
        let resizedMaskImage = maskedImage.cutout(adjustTo: sourceImage)
        
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
    func cutout(adjustTo source: UIImage) -> UIImage {
        let scale: CGFloat
        let resizedImage: UIImage
        let spaceSize: CGFloat
        let trimmingArea: CGRect
        
        // 元画像の向きを判断しトリミングエリアを決定
        if source.size.width > source.size.height {
            scale = source.size.width / size.width
            resizedImage = resize(scale: scale)
            spaceSize = (resizedImage.size.height - source.size.height ) / 2
            trimmingArea = CGRect(x: 0,
                                  y: spaceSize,
                                  width: source.size.width,
                                  height: source.size.height)
        } else {
            scale = source.size.height / size.height
            resizedImage = resize(scale: scale)
            spaceSize = (resizedImage.size.width - source.size.width ) / 2
            trimmingArea = CGRect(x: spaceSize,
                                  y: 0,
                                  width: source.size.width,
                                  height: source.size.height)
        }
        return resizedImage.cropping(to: trimmingArea)
    }
    
    func resize(scale: CGFloat) -> UIImage {
        let toSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(toSize, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        guard let reSizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return reSizedImage
    }
    
    func cropping(to trimmingArea: CGRect) -> UIImage {
        var isOpaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .none, .noneSkipLast, .noneSkipFirst:
                isOpaque = true
            default:
                break
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(trimmingArea.size, isOpaque, scale)
        draw(at: CGPoint(x: -trimmingArea.origin.x, y: -trimmingArea.origin.y))
        guard let croppedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
