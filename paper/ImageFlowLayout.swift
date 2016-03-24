//
//  ImageFlowLayout.swift
//  Paper
//
//  Created by Andreev Ivan on 28/12/15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit

class ImageFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .Vertical
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 3
            
            let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }

}
