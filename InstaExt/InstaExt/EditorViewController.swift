import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var editingImageView: UIImageView!
    var selectedEditorName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedEditorName as Any)
    }


}

