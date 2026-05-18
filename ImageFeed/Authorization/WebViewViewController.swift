//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupProgressObservation()
        
        loadAuthView()
        updateProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup

    private func setupWebView() {
        webView.navigationDelegate = self
    }

    private func setupProgressObservation() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, _ in
            self?.updateProgress()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: APIEndpoints.authorizeURLString) else {
            print("[WebView] ❌ Failed to create URLComponents for authorize URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: APIQueryKeys.clientId, value: APIConstants.accessKey),
            URLQueryItem(name: APIQueryKeys.redirectURI, value: APIConstants.redirectURI),
            URLQueryItem(name: APIQueryKeys.responseType, value: APIQueryKeys.responseTypeCode),
            URLQueryItem(name: APIQueryKeys.scope, value: APIConstants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("[WebView] ❌ Failed to create authorize URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == APIEndpoints.Paths.oauthAuthorizeNative,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == APIQueryKeys.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

