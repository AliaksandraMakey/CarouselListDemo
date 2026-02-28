//
//  String+Localization.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

extension String {

    /// Returns the localized string for the receiver key from Localizable.strings.
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Returns a localized string with the given format arguments.
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
