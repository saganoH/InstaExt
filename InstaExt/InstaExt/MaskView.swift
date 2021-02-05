import UIKit

class MaskView: UIView {
    
    static func process(to: UIView) {
        let maskView = MaskView(frame: to.frame)
        maskView.maskImageView.frame = to.bounds
        to.superview?.addSubview(maskView)
        to.mask = maskView.maskImageView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var maskImageView = UIImageView()
    private var maskImage = UIImage()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(panAction))
    }()
    
    private var previousPosition: CGPoint = .zero
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        let currentPosition = sender.location(in: sender.view)
        
        if sender.state == .began {
            previousPosition = currentPosition
        }
        
        if sender.state != .ended {
            drawLine(from: previousPosition, to: currentPosition)
        }
        previousPosition = currentPosition
    }
    
    func drawLine(from: CGPoint, to: CGPoint){
        let lineWidth: CGFloat = 30
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        if let context = UIGraphicsGetCurrentContext() {
            maskImage.draw(at: .zero)
            context.setLineWidth(lineWidth)
            context.setLineCap(.round)
            context.setStrokeColor(UIColor.white.cgColor)
            
            context.move(to: from)
            context.addLine(to: to)
            context.strokePath()
            maskImage = UIGraphicsGetImageFromCurrentImageContext()!
        }
        
        UIGraphicsEndImageContext()
        maskImageView.image = maskToAlpha(maskImage)
    }
    
    func maskToAlpha(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return UIImage()
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        let alphaFilter = CIFilter(name: "CIMaskToAlpha")!
        alphaFilter.setValue(inputImage, forKeyPath: "inputImage")
        return UIImage(ciImage: alphaFilter.outputImage!)
    }
}
