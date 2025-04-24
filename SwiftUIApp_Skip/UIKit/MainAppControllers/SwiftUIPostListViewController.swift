//
//  SwiftUIPostListViewController.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 24.04.2025.
//

import Foundation
import SwiftUI

struct SwiftUIPostListViewController: UIViewControllerRepresentable {
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> UINavigationController {
        UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as! UINavigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // intentionally empty
    }
    
}
