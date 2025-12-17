//
//  Smozie.swift
//  Smozie
//
//  Created by spbiphones on 17.12.2025.
//

import UIKit
import SwiftUI

// MARK: - Re-export SwiftUI components
@available(iOS 14.0, *)
public typealias SmozieSwiftUIView = SmozieView

/// Главный класс библиотеки Smozie
/// Используйте этот класс для инициализации и запуска SDK
public final class Smozie {
    
    /// Singleton экземпляр библиотеки
    public static let shared = Smozie()
    
    /// Флаг инициализации
    private var isInitialized = false
    
    /// URL для WebView (по умолчанию google.com)
    private var webViewURL: URL = URL(string: "https://www.google.com")!
    
    private init() {}
    
    /// Инициализирует библиотеку Smozie
    /// - Parameter configuration: Опциональная конфигурация (зарезервировано для будущего использования)
    public func initialize(configuration: SmozieConfiguration = .default) {
        self.webViewURL = configuration.url
        self.isInitialized = true
        print("[Smozie] SDK инициализирован")
    }
    
    /// Открывает WebView с заданным URL
    /// - Parameter viewController: ViewController, из которого будет показан WebView
    public func present(from viewController: UIViewController) {
        guard isInitialized else {
            print("[Smozie] Ошибка: SDK не инициализирован. Вызовите Smozie.shared.initialize() перед использованием.")
            return
        }
        
        let webViewController = SmozieWebViewController(url: webViewURL)
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true)
    }
}

/// Конфигурация для инициализации Smozie SDK
public struct SmozieConfiguration {
    
    /// URL для загрузки в WebView
    public let url: URL
    
    /// Конфигурация по умолчанию (google.com)
    public static let `default` = SmozieConfiguration(url: URL(string: "https://www.google.com")!)
    
    /// Создаёт конфигурацию с кастомным URL
    /// - Parameter url: URL для загрузки в WebView
    public init(url: URL) {
        self.url = url
    }
}

