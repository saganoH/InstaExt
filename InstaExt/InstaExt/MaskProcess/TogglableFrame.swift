import UIKit

class TogglableFrame: UIButton {

    weak var delegate: TogglableFrameDelegate?

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

        delegate?.didTapFrame(isOn, frame: frame)
    }

    private func setButtonAppearance() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
    }
}

// MARK: - TogglableFrameDelegate protocol

protocol TogglableFrameDelegate: AnyObject {
    func didTapFrame(_ isOn: Bool, frame: CGRect)
}
