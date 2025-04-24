//
//  PostCellSwiftUI.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 24.04.2025.
//

import UIKit
import SwiftUI

class PostCellSwiftUI: UITableViewCell {
    
    private weak var controller : UIViewController?
    
    override func prepareForReuse(){
        super.prepareForReuse()
        self.contentView.subviews.forEach{ $0.removeFromSuperview() }
        controller?.didMove(toParent: nil)
        controller = nil
    }
    
    func config(post: PostModel.PostData, hostingController: UIViewController){

        let swiftUIViewController: UIViewController = UIHostingController(rootView: PostCardView(post: post))

        let swiftUIView: UIView = swiftUIViewController.view

        self.contentView.addSubview(swiftUIView)
        
        swiftUIView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            swiftUIView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            swiftUIView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            swiftUIView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            swiftUIView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        ])

        swiftUIViewController.didMove(toParent: hostingController)
        
        self.controller = hostingController
    }
}
