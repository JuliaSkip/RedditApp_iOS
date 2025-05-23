//
//  PostCell.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 17.03.2025.
//

import UIKit

class PostCell: UITableViewCell{
    
            
    @IBOutlet private weak var postView: PostView!
    
    override func prepareForReuse(){
        super.prepareForReuse()
        self.postView.prepare()
    }
    
    func config(with post: PostModel.PostData){
        self.postView.config(result: post)
    }
}
