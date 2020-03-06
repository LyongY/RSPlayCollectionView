//
//  ViewController.swift
//  RSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import UIKit

extension Int: RSPlayCollectionCellRealExistence {
    func realExistence() -> Bool {
        self <= 10
    }
}

extension Double: RSPlayCollectionCellRealExistence {
    func realExistence() -> Bool {
        return self <= 7.0
    }
}

class ViewController: UIViewController {
    
    var collection: RSPlayCollectionView!
    
    var array = RSArray(with: [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collection = RSPlayCollectionView(array, registClass: RSPlayCollectionViewCell.self, dataSourceCountChanged: { allCount in
//            while allCount > self.array.array.count {
//                self.array.array.append(9999)
//            }
//        })
//        collection.spliteMode = .four
//        collection.setSelectedIndex(5)
//        collection.delegate = self

        collection = RSPlayCollectionView(array, registClass: RSPlayCollectionViewCell.self, spliteModel: .four, selectedIndex: 5, delegate: self, dataSourceCountChanged: { (allCount) in
            while allCount > self.array.array.count {
                self.array.array.append(9999)
            }
        })
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)
        view.addConstraints([
            collection.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        

    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        collection.spliteMode = RSPlayCollectionView.SpliteMode(rawValue: sender.tag) ?? .one
    }
    
    
}

extension ViewController: RSPlayCollectionViewDelegate {
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, willDisappearArray: [Int]) {
        print("will disappear: \(willDisappearArray.description)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, didAppearArray: [Int]) {
        print("did appear: \(didAppearArray.description)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, didDisappearArray: [Int]) {
        print("did disappear: \(didDisappearArray.description)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, selectIndex: Int) {
        print("selected: \(selectIndex)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, deselectIndex: Int) {
        print("deselected: \(deselectIndex)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, selectedItem selectedIndex: Int, moveTo index: Int) {
        print("selectedItem: \(selectedIndex) move to: \(index)")
    }
    
    func rsplayCollectionView(_ collectionView: RSPlayCollectionView, cleanIndex: Int) {
        print("delete: \(cleanIndex)")
        array.array[cleanIndex] = 9999
    }
}

