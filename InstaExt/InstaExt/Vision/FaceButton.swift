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
        fatalError("init(coder:) has not been implemented")
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

        delegate?.didTapFace(isOn: isOn, face: frame)
    }

    private func setButtonAppearance() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
    }
}

// MARK: - FaceButtonDelegate protocol

protocol FaceButtonDelegate {
    func didTapFace(isOn: Bool, face: CGRect)
}
