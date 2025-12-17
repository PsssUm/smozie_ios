//
//  SmozieView.swift
//  Smozie
//
//  Created by spbiphones on 17.12.2025.
//

import SwiftUI

/// SwiftUI View для отображения Smozie WebView
/// Используйте как sheet или fullScreenCover
@available(iOS 14.0, *)
public struct SmozieView: UIViewControllerRepresentable {
    
    private let url: URL
    @Binding private var isPresented: Bool
    
    /// Создаёт SmozieView с URL по умолчанию (google.com)
    public init(isPresented: Binding<Bool>) {
        self.url = URL(string: "https://www.google.com")!
        self._isPresented = isPresented
    }
    
    /// Создаёт SmozieView с кастомным URL
    /// - Parameters:
    ///   - url: URL для загрузки
    ///   - isPresented: Binding для управления отображением
    public init(url: URL, isPresented: Binding<Bool>) {
        self.url = url
        self._isPresented = isPresented
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let webViewController = SmozieWebViewController(url: url)
        webViewController.onDismiss = {
            isPresented = false
        }
        let navigationController = UINavigationController(rootViewController: webViewController)
        return navigationController
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - View Extension для удобного использования

@available(iOS 14.0, *)
public extension View {
    
    /// Показывает Smozie WebView как fullScreenCover
    /// - Parameters:
    ///   - isPresented: Binding для управления отображением
    ///   - url: URL для загрузки (по умолчанию google.com)
    func smozie(isPresented: Binding<Bool>, url: URL = URL(string: "https://www.google.com")!) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            SmozieView(url: url, isPresented: isPresented)
                .ignoresSafeArea()
        }
    }
}

