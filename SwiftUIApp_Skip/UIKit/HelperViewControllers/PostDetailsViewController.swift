//
//  PostDetailsViewContr5oller.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 18.03.2025.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    @IBOutlet private weak var postView: PostView!
    
    func config(with post: PostModel.PostData){
        postView.config(result: post)
    }
}
