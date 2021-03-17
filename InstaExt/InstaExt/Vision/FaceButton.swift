import UIKit

class FaceButton: UIButton {
    
    var delegate: FaceButtonDelegate?
    
    private var isOn: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setButtonAppearance()
        addTarget(self, action: #selector(didTapButton), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("使用しないケースのため未実装")
    }
    
    @objc func didTapButton() {
        switch isOn {
        case true:
            isOn = false
            layer.borderColor = UIColor.orange.cgColor
        case false:
            isOn = true
            layer.borderColor = UIColor.green.cgColor
        }
        
        delegate?.didTapFace(detection: isOn, face: frame)
    }
    
    private func setButtonAppearance() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
    }
}

// MARK: - FaceButtonDelegate protocol

protocol FaceButtonDelegate {
    func didTapFace(detection isOn: Bool, face: CGRect)
}
