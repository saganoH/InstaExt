import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var editingImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedFilter: FilterType?
    var editingImage: UIImage!
    
    private var filteringImage: UIImage!
    private let mainViewController = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    private func prepareTool() {
        editingImageView.image = editingImage
        toolSlider.isContinuous = false
        navigationItem.title = selectedFilter?.rawValue
        
        guard let selectedFilter = selectedFilter else {
            return
        }
        toolSlider.maximumValue = selectedFilter.max()
        toolSlider.minimumValue = selectedFilter.min()
        toolSlider.value = selectedFilter.mid()
              
        processFilter()
    }
    
    private func processFilter() {
            filteringImage = selectedFilter?.filter().process(value: CGFloat(toolSlider.value), image: editingImage)
            // 動きが見えるように一旦viewにセットしている
            editingImageView.image = filteringImage
    }
}

