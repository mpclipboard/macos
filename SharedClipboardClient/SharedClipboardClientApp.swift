//
//  SharedClipboardClientApp.swift
//  SharedClipboardClient
//
//  Created by Ilya on 27/05/2025.
//

import SwiftUI

@main
struct SharedClipboardClientApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
