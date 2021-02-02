import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var editingImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedEditorName: String?
    var editingImage: UIImage!
    private let mainViewController = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toolSlider.isHidden = true
        prepareTool()
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        print(sender)
    }
    
    private func prepareTool() {
        editingImageView.image = editingImage
        
        switch selectedEditorName {
        case Optional("bokashi"):
            toolSlider.isHidden = false
            print("ぼかしを用意")
        case Optional("mozaiku"):
            toolSlider.isHidden = false
            print("モザイクを用意")
        case Optional("monokuro"):
            toolSlider.isHidden = false
            print("モノクロを用意")
        default:
            break
        }
    }
}

