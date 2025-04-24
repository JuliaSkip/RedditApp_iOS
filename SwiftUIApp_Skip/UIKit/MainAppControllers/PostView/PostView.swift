import UIKit

class PostView: UIView {
    
    struct Const {
        static let contentXibName = "PostView"
    }

    @IBOutlet private weak var postView: UIView!
    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var timePassed: UILabel!
    @IBOutlet private weak var domain: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var rating: UILabel!
    @IBOutlet private weak var commentsCount: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var username: UILabel!
    @IBOutlet private weak var saveMarkView: SaveMarkView!
    private var currentPost:PostModel.PostData?

    
    @IBAction func saveButton(_ sender: UIButton) {
        handleSave()
    }
    
    func handleSave () {
        guard var post = self.currentPost else { return }
        
        var loadedPosts = PostsManager().loadPostsFromFile()
        
        if let index = loadedPosts.firstIndex(where: { $0 == post }) {
            loadedPosts.remove(at: index)
            post.isSaved = false
        } else {
            post.isSaved = true
            loadedPosts.append(post)
        }
        
        PostsManager().writePostsToFile(posts: loadedPosts)
        
        let image = UIImage(systemName: post.isSaved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        self.saveButton.setImage(image, for: .normal)
        self.saveButton.tintColor = .label
        
        NotificationCenter.default.post(name: NSNotification.Name("PostUpdated"), object: nil, userInfo: ["post": post])
        
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        guard let viewController = self.findViewController() else { return }
        guard let post = self.currentPost else { return }
        let activityVC = UIActivityViewController(activityItems: [post.url ?? " "], applicationActivities: nil)
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
        
    func commonInit() {
        Bundle.main.loadNibNamed(Const.contentXibName, owner: self, options: nil)
        postView.fixInView(self)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tapRecognizer.numberOfTapsRequired = 2
        self.postImage.isUserInteractionEnabled = true
        self.postImage.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func doubleTap() {
        handleSave()

        self.saveMarkView.isHidden = true
        
        UIView.transition(
            with: self.saveMarkView,
            duration: 0.5,
            options: .transitionCrossDissolve)
        {
            self.saveMarkView.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.saveMarkView.isHidden = true
        }
    }
    
    func prepare(){
        self.postImage.image = nil
    }
    
    func config(result: PostModel.PostData) {
                
        self.saveMarkView.isHidden = true
        self.currentPost = result
                        
        
        if let imageUrlString = result.imageUrl, let formattedUrl = URL(string: imageUrlString.replacingOccurrences(of: "&amp;", with: "&")) {
            self.postImage.kf.setImage(with: formattedUrl)
        }
        if let imageData = result.image, let imageLocal = UIImage(data: imageData) {
            self.postImage.image = imageLocal
        }
        
            
        self.username.text = result.author
        
        if result.createdUTC != nil{
            self.timePassed.text = result.createdUTC
        }else{
            self.timePassed.text = DataManager().formatDate(result.createdUTCOwnPost!)
        }
        
        if let longText = result.mainText{
            self.postTitle.text = "\(result.title)\n\(longText)"
        }else{
            self.postTitle.text = result.title
        }
        
        self.domain.text = result.domain
        self.rating.text = String(result.ups + result.downs)
        self.commentsCount.text = String(result.numComments)
            
        let image = UIImage(systemName: result.isSaved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        
        self.saveButton.setImage(image, for: .normal)
        self.saveButton.tintColor = .label
    }

}
extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
