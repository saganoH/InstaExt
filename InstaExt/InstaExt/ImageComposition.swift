import UIKit

class ImageComposition {
    func process(sourceImageView: UIImageView, filterImageView: UIImageView) -> UIImage? {
        guard let sourceImage = sourceImageView.image else {
            return sourceImageView.image
        }
        let frameSize = sourceImageView.frame.size
        
        UIGraphicsBeginImageContext(frameSize)
        let context = UIGraphicsGetCurrentContext()!
        filterImageView.layer.render(in: context)
        let maskedFilterImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: frameSize))
        maskedFilterImage.draw(in: CGRect(origin: CGPoint.zero, size: frameSize))
        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resultImage = drawedImage else {
            return sourceImage
        }
        return resultImage
    }
}
