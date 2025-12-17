//
//  OnFailListener.swift
//  Smozie
//
//  Created by spbiphones on 17.12.2025.
//

import Foundation

/// Протокол для обработки ошибок SDK
public protocol OnFailListener: AnyObject {
    /// Вызывается при возникновении ошибки
    /// - Parameter error: Описание ошибки
    func onError(_ error: String)
}

