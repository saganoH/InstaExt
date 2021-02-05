import UIKit

class MaskView: UIView {
    
    static func process(to: UIView) {
        let maskView = MaskView(frame: to.frame)
        maskView.imageView.frame = to.bounds
        to.superview?.addSubview(maskView)
        to.mask = maskView.imageView
        print(maskView.frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageView = UIImageView()
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
        let lineWidth: CGFloat = 40
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        if let ctx = UIGraphicsGetCurrentContext() {
            maskImage.draw(at: .zero)
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(.round)
            ctx.setStrokeColor(UIColor.green.cgColor)
            
            ctx.move(to: from)
            ctx.addLine(to: to)
            ctx.strokePath()
            maskImage = UIGraphicsGetImageFromCurrentImageContext()!
        }
        UIGraphicsEndImageContext()
        imageView.image = maskToAlpha(maskImage)
    }
    
    func maskToAlpha(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else {
            return UIImage()
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIMaskToAlpha")!
        filter.setValue(inputImage, forKeyPath: "inputImage")
        return UIImage(ciImage: filter.outputImage!)
    }
}
