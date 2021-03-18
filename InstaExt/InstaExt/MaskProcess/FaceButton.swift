import UIKit

class FaceButton: UIButton {

    weak var delegate: FaceButtonDelegate?

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
        isOn.toggle()
        layer.borderColor = isOn ? UIColor.green.cgColor : UIColor.orange.cgColor

        delegate?.didTapFace(detection: isOn, face: frame)
    }

    private func setButtonAppearance() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
    }
}

// MARK: - FaceButtonDelegate protocol

protocol FaceButtonDelegate: AnyObject {
    func didTapFace(detection isOn: Bool, face: CGRect)
}
