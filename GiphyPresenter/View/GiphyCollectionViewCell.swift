//
//  GiphyCollectionViewCell.swift
//  GiphyPresenter
//
//  Created by Omnicron on 2/18/18.
//  Copyright © 2018 Eugeniya. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GiphyCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var animatedImageView: FLAnimatedImageView!
    
    var url: URL? {
        didSet {
            self.setupAnimatedImage()
        }
    }
    
    override func awakeFromNib() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    private func setupAnimatedImage() {
        guard let url = self.url else { return }
        if let img = RuntimeStorage.sharedInstance.imageForKey(url.absoluteString) {
            self.animatedImageView.animatedImage = img
        } else
            if let imageData = try? Data(contentsOf: url) {
                let animatedImage = FLAnimatedImage(animatedGIFData: imageData, optimalFrameCacheSize: 0, predrawingEnabled: true)
                self.animatedImageView.animatedImage = animatedImage
        }
        self.animatedImageView.backgroundColor = .lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.animatedImageView.animatedImage = nil
    }
    
}
