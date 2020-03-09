//
//  RSPlayCollectionViewCell.swift
//  RSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import UIKit

var count = 0

class RSPlayCollectionViewCell: RSPlayCellBase {
    
    let label = UILabel()
    let countlabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addConstraints([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        self.backgroundView = RSPlayCollectionViewCell.Background(borderColor: .gray)
        self.selectedBackgroundView = RSPlayCollectionViewCell.Background(borderColor: .red)
        
        count += 1
        self.addSubview(countlabel)
        countlabel.frame = .init(origin: .init(x: 0, y: 0), size: .init(width: 100, height: 100))
        countlabel.text = "\(count)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func update(with: IndexPath, dataSourceElement: RSPlayModelBase) {
        label.text = dataSourceElement.description
    }
    
    
    class Background: UIView {
        
        init(borderColor: UIColor) {
            super.init(frame: .init(x: 10, y: 10, width: 100, height: 100))
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
