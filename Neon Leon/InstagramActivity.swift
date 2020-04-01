import Foundation
import UIKit

private let InstagramAppURL = URL(string: "instagram://app")!

class InstagramActivity: UIActivity, UIDocumentInteractionControllerDelegate {
    override class var activityCategory: UIActivity.Category { return .share }
    override var activityType: UIActivity.ActivityType? { return UIActivity.ActivityType("postToInstagram") }
    override var activityTitle: String? { return "Instagram" }
    override var activityImage: UIImage? { return #imageLiteral(resourceName: "instagram_activity") }

    var isPerformed = false

    var imageUrl: URL!
    var text: String?

    var document: UIDocumentInteractionController!

    weak var viewController: UIViewController?
    let presentFrom: PresentFrom

    init(with presentFrom: PresentFrom, in vc: UIViewController) {
        viewController = vc
        self.presentFrom = presentFrom
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        guard UIApplication.shared.canOpenURL(InstagramAppURL),
            let image = activityItems.first(where: { $0 is UIImage }) as? UIImage,
            let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = image.jpegData(compressionQuality: 0.7) else { return false }

        imageUrl = docsUrl.appendingPathComponent("to-share.ig")
        do {
            try data.write(to: imageUrl)
            return true
        } catch {
            print("Error writing image", error.localizedDescription)
            return false
        }
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        text = activityItems.first(where: { $0 is String }) as? String
    }

    override func perform() {
        document = UIDocumentInteractionController(url: imageUrl)
        document.uti = "com.instagram.photo"
        document.delegate = self

        guard text != nil else {
            presentDoc(doc: document)
            return
        }

        UIPasteboard.general.string = text

        let alert = UIAlertController(title: nil, message: "Caption has been copied into clipboard. You can paste it into Instagram", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.presentDoc(doc: self.document)
        })
        viewController?.present(alert, animated: true, completion: nil)
    }

    private func presentDoc(doc: UIDocumentInteractionController) {
        switch presentFrom {
        case .barButtonItem(let barButtonItem):
            doc.presentOpenInMenu(from: barButtonItem, animated: true)
        case let .view(view, rect):
            doc.presentOpenInMenu(from: rect, in: view, animated: true)
        }
    }

    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        isPerformed = true
    }

    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        activityDidFinish(isPerformed)
    }

    enum PresentFrom {
        case barButtonItem(UIBarButtonItem)
        case view(UIView, CGRect)
    }
}
