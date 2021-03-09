import UIKit

class MaskView: UIView {
    
    private(set) var maskImageView = UIImageView()
    private var maskImage = UIImage()
    private var previousPosition: CGPoint = .zero

    private let drawLineWidth: CGFloat = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("使用しないケースのため未実装")
    }
   
    // MARK: - @objc
    
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

    // MARK: - public
    // 動作確認未実施、次カードだった
    func drawCycle(faceBounds: [CGRect]) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        if let context = UIGraphicsGetCurrentContext() {
            maskImage.draw(at: .zero)
            context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))

            for faceBound in faceBounds {
                context.fillEllipse(in: faceBound)
            }
            maskImage = UIGraphicsGetImageFromCurrentImageContext()!
        }

        UIGraphicsEndImageContext()
        maskImageView.image = maskToAlpha(maskImage)
    }
    
    // MARK: - private
    
    private func drawLine(from: CGPoint, to: CGPoint){
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        if let context = UIGraphicsGetCurrentContext() {
            maskImage.draw(at: .zero)
            context.setLineWidth(drawLineWidth)
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
    
    private func maskToAlpha(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return UIImage()
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        let alphaFilter = CIFilter(name: "CIMaskToAlpha")!
        alphaFilter.setValue(inputImage, forKeyPath: "inputImage")

        guard let resultImage = alphaFilter.outputImage else {
            fatalError("CIImageの生成に失敗")
        }
        return UIImage(ciImage: resultImage)
    }
}
