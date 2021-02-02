import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var editingImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedEditorName: String?
    var editingImage: UIImage!
    
    private var filteringImage: UIImage!
    private let mainViewController = MainViewController()
    private let bokashi = Bokashi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        switch selectedEditorName {
        case Optional("bokashi"):
            filteringImage = bokashi.makeBokashi(value: CGFloat(toolSlider.value), image: editingImage)
            // 動きが見えるように一旦viewにセットしている
            editingImageView.image = filteringImage
            
        case Optional("mozaiku"):
            print("モザイクを用意")
        case Optional("monokuro"):
            print("モノクロを用意")
        default:
            break
        }
    }
    
    private func prepareTool() {
        editingImageView.image = editingImage
        toolSlider.minimumValue = 0
        toolSlider.maximumValue = 20
        toolSlider.value = 10
        toolSlider.isContinuous = false
        
        switch selectedEditorName {
        case Optional("bokashi"):
            navigationItem.title = "ぼかし"
        case Optional("mozaiku"):
            navigationItem.title = "モザイク"
        case Optional("monokuro"):
            navigationItem.title = "モノクロ"
        default:
            break
        }
    }
}

