//
//  ViewController.swift
//  RSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import UIKit

class Model: RSPlayModelBase {
    var num: Int
    
    init(num: Int) {
        self.num = num
    }
    
    override func realExistence() -> Bool {
        num <= 10
    }
    
    override var description: String {
        "\(num)"
    }
}

class ViewController: UIViewController {
    
    var collection: RSPlayCollectionView!
    
    var array = RSArray(with: [
        Model(num: 1),
        Model(num: 2),
        Model(num: 3),
        Model(num: 4),
        Model(num: 5),
        Model(num: 6),
        Model(num: 7),
        Model(num: 8),
        Model(num: 9),
        Model(num: 10),
        Model(num: 11),
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection = RSPlayCollectionView(array, registClass: RSPlayCollectionViewCell.self, maxSpliteMode: .eight, spliteModel: .four, selectedIndex: 5, delegate: self, emptyElement: {
            Model(num: 9999)
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
        let rr = array.array[cleanIndex] as! Model
        rr.num = 9999
    }
}

