import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedFilter: FilterType?
    var editingImage: UIImage!
    
    private var filterImage: UIImage!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
        processFilter()
    }
    
    // MARK: - @IBAction
    
    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    // MARK: - private
    
    private func prepareTool() {
        guard let selectedFilter = selectedFilter else {
            return
        }
        
        filterImageView.image = editingImage
        navigationItem.title = selectedFilter.rawValue
        
        toolSlider.isContinuous = false
        toolSlider.maximumValue = selectedFilter.max()
        toolSlider.minimumValue = selectedFilter.min()
        toolSlider.value = selectedFilter.mid()
    }
    
    private func processFilter() {
        filterImage = selectedFilter?.filter().process(value: CGFloat(toolSlider.value), image: editingImage)
        filterImageView.image = filterImage
    }
}

