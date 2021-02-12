import UIKit

class ImageComposition {
    func process(sourceImageView: UIImageView, filterImageView: UIImageView) -> UIImage? {
        guard let sourceImage = sourceImageView.image else {
            return sourceImageView.image
        }

        UIGraphicsBeginImageContextWithOptions(sourceImageView.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
//        sourceImageView.layer.render(in: context)
        filterImageView.layer.render(in: context)

//        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        guard let resultImage = drawedImage else {
//            return sourceImage
//        }
//        return resultImage

        // ------------------------------------------------------

        // ImageViewそのままを画像化(上下左右の余白を含む)
        let maskedFilterViewImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // マスク画像のみ取得(余白の除去)
        let onlyMaskedImage = maskedFilterViewImage.croppedWithAspect(image: sourceImage)
        // 元画像の大きさにリサイズ
        let resizedBySourceSize = onlyMaskedImage?.resize(size: sourceImage.size)

        // 元画像とマスク画像の描画
        UIGraphicsBeginImageContextWithOptions(sourceImage.size, false, 0)
        sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: sourceImage.size))
        resizedBySourceSize?.draw(in: CGRect(origin: CGPoint.zero, size: sourceImage.size))

        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resultImage = drawedImage else {
            return sourceImage
        }
        return resultImage
    }

}

extension UIImage {
    // アスペクト比算出
    func aspectRatio() -> CGFloat {
        return size.width / size.height
    }

    // 画像のアスペクト比の通りに画像を切り抜く
    func croppedWithAspect(image: UIImage) -> UIImage? {
        let aspect = image.aspectRatio()
        let rect: CGRect
        if aspect >= 1 {
            rect = CGRect(x: 0,
                          y: (size.height - size.width / aspect) / 2,
                          width: size.width,
                          height: size.width / aspect)
        } else {
            rect = CGRect(x: (size.width - size.height * aspect) / 2,
                          y: 0,
                          width: size.height * aspect,
                          height: size.height)
        }

        return cropping(to: rect)
    }

    // https://qiita.com/takabosoft/items/391b7593f0b9ef7d77a5
    func cropping(to: CGRect) -> UIImage {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }

        UIGraphicsBeginImageContextWithOptions(to.size, opaque, scale)
        draw(at: CGPoint(x: -to.origin.x, y: -to.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }

    // https://qiita.com/ruwatana/items/473c1fb6fc889215fca3
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

}
