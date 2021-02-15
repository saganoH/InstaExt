import UIKit

class ImageComposition {
    func process(sourceImageView: UIImageView, filterImageView: UIImageView) -> UIImage? {
        guard let sourceImage = sourceImageView.image else {
            return sourceImageView.image
        }
      
        // 空白を含むマスク画像の生成
        UIGraphicsBeginImageContext(filterImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        filterImageView.layer.render(in: context)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()


        let resizedMaskImage = resize(maskedImage: maskedImage!, sourceImage: sourceImage)
        
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
    
    func resize(maskedImage: UIImage, sourceImage: UIImage) -> UIImage {
        if sourceImage.size.width > sourceImage.size.height {
            let scale = sourceImage.size.width / maskedImage.size.width
            let resizedImage = maskedImage.scaleImage(scaleSize: scale)
            let spaceSize = (resizedImage.size.height - sourceImage.size.height ) / 2
            let trimmingArea = CGRect(x: 0, y: spaceSize, width: sourceImage.size.width, height: sourceImage.size.height)
            return resizedImage.cropping(to: trimmingArea)
            
        } else {
            let scale = sourceImage.size.height / maskedImage.size.height
            return maskedImage.scaleImage(scaleSize: scale)
        }
    }
    
    func trimmingImage(_ image: UIImage, trimmingArea: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: trimmingArea)
        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return drawedImage!
    }
}

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
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
}
