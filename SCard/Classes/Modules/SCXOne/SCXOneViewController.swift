import Foundation
import WebKit
import UIKit
import SoraUIKit

final class SCXOneViewController: UIViewController {

    private let viewModel: SCXOneViewModel


    private var rootView: WKWebView {
        view as! WKWebView
    }

    init(viewModel: SCXOneViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = WKWebView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.loadHTMLString(viewModel.xOneHtmlString, baseURL: nil)
        rootView.navigationDelegate = self
        viewModel.checkStatus()
    }
}

extension SCXOneViewController: LoadableViewProtocol, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStartLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didStopLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didStopLoading()
    }
}
