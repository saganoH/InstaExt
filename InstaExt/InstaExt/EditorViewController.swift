import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedFilter: FilterType?
    var editingImage: UIImage!
    
    private var filterImage: UIImage!
    private let mainViewController = MainViewController()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
    }
    
    // MARK: - @IBAction
    
    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    // MARK: - private
    
    private func prepareTool() {
        filterImageView.image = editingImage
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
        filterImage = selectedFilter?.filter().process(value: CGFloat(toolSlider.value), image: editingImage)
        filterImageView.image = filterImage
    }
}

