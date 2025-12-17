//
//  SmozieWebViewController.swift
//  Smozie
//
//  Created by spbiphones on 17.12.2025.
//

import UIKit
import WebKit
import StoreKit

/// Внутренний ViewController для отображения WebView
final class SmozieWebViewController: UIViewController {
    
    // MARK: - Properties
    
    private let token: String
    private let apiKey: String
    private let userId: String
    private let deviceId: String
    private weak var onFailListener: OnFailListener?
    
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var progressObservation: NSKeyValueObservation?
    
    /// Callback вызываемый при закрытии (для SwiftUI)
    var onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        token: String,
        apiKey: String,
        userId: String,
        deviceId: String,
        onFailListener: OnFailListener?
    ) {
        self.token = token
        self.apiKey = apiKey
        self.userId = userId
        self.deviceId = deviceId
        self.onFailListener = onFailListener
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        progressObservation?.invalidate()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupJavaScriptInterface()
        loadURL()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Аналог onResume в Android
        webView.evaluateJavaScript("onResume()") { _, _ in }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка WebView
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        
        // Настройка индикатора прогресса
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemBlue
        view.addSubview(progressView)
        
        // Constraints
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Наблюдение за прогрессом загрузки
        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
            self?.progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }
    
    private func setupNavigationBar() {
        title = "Smozie"
        
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
        
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshButtonTapped)
        )
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    private func setupJavaScriptInterface() {
        let contentController = webView.configuration.userContentController
        
        // Регистрируем обработчики для JavaScript вызовов
        let handlers = [
            "showToast",
            "isAppInstalled",
            "checkInstalledNew",
            "openUrl",
            "openApp",
            "openAppWithParams",
            "copyId",
            "registrationFailed",
            "finish",
            "showReviewDialog",
            "getStringPref",
            "setStringPref"
        ]
        
        for handler in handlers {
            contentController.add(self, name: handler)
        }
        
        // Инжектируем JavaScript мост для iOS
        let script = """
        window.iOS = {
            showToast: function(message) {
                window.webkit.messageHandlers.showToast.postMessage(message);
            },
            isAppInstalled: function(packagename) {
                window.webkit.messageHandlers.isAppInstalled.postMessage(packagename);
                return false;
            },
            checkInstalledNew: function(packagename) {
                window.webkit.messageHandlers.checkInstalledNew.postMessage(packagename);
                return false;
            },
            openUrl: function(url) {
                window.webkit.messageHandlers.openUrl.postMessage(url);
            },
            openApp: function(packagename) {
                window.webkit.messageHandlers.openApp.postMessage(packagename);
            },
            openAppWithParams: function(packagename, google_user_id, order_id) {
                window.webkit.messageHandlers.openAppWithParams.postMessage({
                    packagename: packagename,
                    google_user_id: google_user_id,
                    order_id: order_id
                });
            },
            copyId: function(id, text) {
                window.webkit.messageHandlers.copyId.postMessage({id: id, text: text});
            },
            registrationFailed: function(desc) {
                window.webkit.messageHandlers.registrationFailed.postMessage(desc);
            },
            finish: function() {
                window.webkit.messageHandlers.finish.postMessage('');
            },
            showReviewDialog: function() {
                window.webkit.messageHandlers.showReviewDialog.postMessage('');
            },
            getStringPref: function(key) {
                window.webkit.messageHandlers.getStringPref.postMessage(key);
                return '';
            },
            setStringPref: function(text, key) {
                window.webkit.messageHandlers.setStringPref.postMessage({text: text, key: key});
            }
        };
        """
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
    }
    
    private func loadURL() {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        
        var urlComponents = URLComponents(string: Constants.baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "device_id", value: deviceId),
            URLQueryItem(name: "token_google", value: token),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "uniq_user_id", value: userId),
            URLQueryItem(name: "testReactJS", value: "1"),
            URLQueryItem(name: "bundle", value: bundleId),
            URLQueryItem(name: "webview_fits", value: "true"),
            URLQueryItem(name: "platform", value: "ios")
        ]
        
        guard let url = urlComponents?.url else {
            onFailListener?.onError("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
    
    @objc private func refreshButtonTapped() {
        webView.reload()
    }
    
    // MARK: - Helper Methods
    
    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func openApp(_ urlScheme: String) {
        // На iOS используем URL схемы для открытия приложений
        guard let url = URL(string: "\(urlScheme)://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyToClipboard(_ text: String, message: String) {
        UIPasteboard.general.string = text
        showToast(message)
    }
    
    private func showReviewDialog() {
        let isRatedKey = "smozie_is_rated"
        
        guard !UserDefaults.standard.bool(forKey: isRatedKey) else { return }
        
        UserDefaults.standard.set(true, forKey: isRatedKey)
        
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    private func getStringPref(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    private func setStringPref(_ text: String, key: String) {
        UserDefaults.standard.set(text, forKey: key)
    }
    
    private func finishActivity() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
    
    private func registrationFailed(_ description: String) {
        onFailListener?.onError(description)
        finishActivity()
    }
}

// MARK: - WKNavigationDelegate

extension SmozieWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.progress = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title ?? "Smozie"
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        onFailListener?.onError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        onFailListener?.onError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler (JavaScript Interface)

extension SmozieWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "showToast":
            if let text = message.body as? String {
                showToast(text)
            }
            
        case "isAppInstalled", "checkInstalledNew":
            // На iOS проверка установки приложений ограничена
            // Можно проверить только через URL схемы
            if let scheme = message.body as? String {
                let url = URL(string: "\(scheme)://")
                let isInstalled = url != nil && UIApplication.shared.canOpenURL(url!)
                webView.evaluateJavaScript("window.appInstalledResult = \(isInstalled)") { _, _ in }
            }
            
        case "openUrl":
            if let urlString = message.body as? String {
                openURL(urlString)
            }
            
        case "openApp":
            if let scheme = message.body as? String {
                openApp(scheme)
            }
            
        case "openAppWithParams":
            if let params = message.body as? [String: String],
               let scheme = params["packagename"] {
                // На iOS параметры передаются через URL схему
                var urlString = "\(scheme)://"
                if let userId = params["google_user_id"], let orderId = params["order_id"] {
                    urlString += "?google_user_id=\(userId)&order_id=\(orderId)"
                }
                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            
        case "copyId":
            if let params = message.body as? [String: String],
               let id = params["id"],
               let text = params["text"] {
                copyToClipboard(id, message: text)
            }
            
        case "registrationFailed":
            if let desc = message.body as? String {
                registrationFailed(desc)
            }
            
        case "finish":
            finishActivity()
            
        case "showReviewDialog":
            showReviewDialog()
            
        case "getStringPref":
            if let key = message.body as? String {
                let value = getStringPref(key)
                webView.evaluateJavaScript("window.prefResult = '\(value)'") { _, _ in }
            }
            
        case "setStringPref":
            if let params = message.body as? [String: String],
               let text = params["text"],
               let key = params["key"] {
                setStringPref(text, key: key)
            }
            
        default:
            break
        }
    }
}
