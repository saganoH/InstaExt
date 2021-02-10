import UIKit

class ImageComposition {
    func process(sourceImageView: UIImageView, filterImageView: UIImageView) -> UIImage {
        guard let sourceImage = sourceImageView.image, let filterImage = filterImageView.image  else {
            return sourceImageView.image!
        }
        let frameSize = sourceImageView.frame.size
        
        UIGraphicsBeginImageContext(frameSize)
        
        sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: frameSize))
        filterImage.draw(in: CGRect(origin: CGPoint.zero, size: frameSize))
        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resultImage = drawedImage else {
            return sourceImage
        }
        return resultImage
    }
}
