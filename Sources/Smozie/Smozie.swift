//
//  Smozie.swift
//  Smozie
//
//  Created by spbiphones on 17.12.2025.
//

import UIKit
import SwiftUI

/// Главный класс библиотеки Smozie (аналог Upmob для Android)
/// Используйте этот класс для инициализации и запуска SDK
public final class Smozie {
    
    // MARK: - Properties
    
    /// Слушатель ошибок
    public weak var onFailListener: OnFailListener?
    
    /// Параметры инициализации
    private let token: String
    private let apiKey: String
    private let userId: String
    private let deviceId: String
    
    // MARK: - Initialization
    
    /// Инициализирует SDK и сразу открывает WebView
    /// - Parameters:
    ///   - viewController: ViewController для презентации
    ///   - token: Токен авторизации
    ///   - apiKey: API ключ
    ///   - userId: ID пользователя (опционально)
    ///   - onFailListener: Слушатель ошибок
    public init(
        viewController: UIViewController,
        token: String,
        apiKey: String,
        userId: String = "",
        onFailListener: OnFailListener
    ) {
        self.token = token
        self.apiKey = apiKey
        self.userId = userId
        self.onFailListener = onFailListener
        
        // Получаем Device ID (аналог ANDROID_ID)
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        // Сразу открываем WebView (как в Android версии)
        presentWebView(from: viewController)
    }
    
    // MARK: - Private Methods
    
    private func presentWebView(from viewController: UIViewController) {
        let webViewController = SmozieWebViewController(
            token: token,
            apiKey: apiKey,
            userId: userId,
            deviceId: deviceId,
            onFailListener: onFailListener
        )
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        
        viewController.present(navigationController, animated: true)
    }
}

// MARK: - SwiftUI Support

/// SwiftUI View для отображения Smozie WebView
@available(iOS 14.0, *)
public struct SmozieView: UIViewControllerRepresentable {
    
    private let token: String
    private let apiKey: String
    private let userId: String
    private let deviceId: String
    private weak var onFailListener: OnFailListener?
    @Binding private var isPresented: Bool
    
    /// Создаёт SmozieView
    /// - Parameters:
    ///   - token: Токен авторизации
    ///   - apiKey: API ключ
    ///   - userId: ID пользователя (опционально)
    ///   - onFailListener: Слушатель ошибок
    ///   - isPresented: Binding для управления отображением
    public init(
        token: String,
        apiKey: String,
        userId: String = "",
        onFailListener: OnFailListener?,
        isPresented: Binding<Bool>
    ) {
        self.token = token
        self.apiKey = apiKey
        self.userId = userId
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        self.onFailListener = onFailListener
        self._isPresented = isPresented
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let webViewController = SmozieWebViewController(
            token: token,
            apiKey: apiKey,
            userId: userId,
            deviceId: deviceId,
            onFailListener: onFailListener
        )
        webViewController.onDismiss = {
            isPresented = false
        }
        let navigationController = UINavigationController(rootViewController: webViewController)
        return navigationController
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - View Extension

@available(iOS 14.0, *)
public extension View {
    
    /// Показывает Smozie WebView как fullScreenCover
    func smozie(
        isPresented: Binding<Bool>,
        token: String,
        apiKey: String,
        userId: String = "",
        onFailListener: OnFailListener?
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            SmozieView(
                token: token,
                apiKey: apiKey,
                userId: userId,
                onFailListener: onFailListener,
                isPresented: isPresented
            )
            .ignoresSafeArea()
        }
    }
}
