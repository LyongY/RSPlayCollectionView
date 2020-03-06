//
//  RSPlayCollectionLayout.swift
//  RSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import UIKit

class RSPlayCollectionLayout: UICollectionViewLayout {
    var arr = Array<UICollectionViewLayoutAttributes>()
    var mode: RSPlayCollectionView.SpliteMode
    
    init(mode: RSPlayCollectionView.SpliteMode) {
        self.mode = mode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        arr.removeAll()
        
        guard let count = self.collectionView?.numberOfItems(inSection: 0) else {
            return
        }
    
        for item in 0 ..< count {
            let indexPath = IndexPath(item: item, section: 0)
            guard let attr = self.layoutAttributesForItem(at: indexPath) else {
                continue
            }
            arr.append(attr)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let offsetX = self.collectionView?.contentOffset.x, let width = self.collectionView?.bounds.size.width, let height = self.collectionView?.bounds.size.height  else {
            return arr
        }
        let temp = arr.filter { (attr) -> Bool in
            CGRect(x: offsetX, y: 0, width: width, height: height).intersects(attr.frame)
        }
        return temp
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var countOfPerLine = Int(sqrt(Double(mode.rawValue))) //每行有几个item
        
        guard let collectionViewWidth = self.collectionView?.bounds.size.width else { return nil }
        guard let collectionViewHeight = self.collectionView?.bounds.size.height else { return nil }
        var width = collectionViewWidth / CGFloat(countOfPerLine)
        var height = collectionViewHeight / CGFloat(countOfPerLine)
        
        let page = indexPath.item / mode.rawValue //在第几页
        var indexInPerLine = indexPath.item % countOfPerLine //横排第几个
        var indexInRow = (indexPath.item - page * mode.rawValue) / countOfPerLine //在第几行
        
        if mode == .six || mode == .eight {
            countOfPerLine = mode == .six ? 3 : 4
            
            width = collectionViewWidth / CGFloat(countOfPerLine)
            height = collectionViewHeight / CGFloat(countOfPerLine)
            
            indexInPerLine = indexPath.item % countOfPerLine
            indexInRow = (indexPath.item - page * mode.rawValue) / countOfPerLine
            
            if indexPath.item % mode.rawValue < mode.rawValue / 2 { // 最后一排为总数的一半
                indexInPerLine = indexPath.item % mode.rawValue == 0 ? 0 : countOfPerLine - 1;
                indexInRow = indexPath.item % mode.rawValue > 0 ? indexPath.item % mode.rawValue - 1 : 0;
                if (indexPath.item % mode.rawValue == 0) {
                    width = width * CGFloat(countOfPerLine - 1);
                    height = height * CGFloat(countOfPerLine - 1);
                }
            } else {
                indexInRow += countOfPerLine - 2;
            }
        }
        
        let originX = CGFloat(page) * collectionViewWidth + width * CGFloat(indexInPerLine)
        let originY = height * CGFloat(indexInRow)
        let frame = CGRect(x: originX, y: originY, width: width, height: height)
        
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.frame = frame
        return attr
    }
    
    override var collectionViewContentSize: CGSize {
        var page = arr.count / mode.rawValue
        page = (arr.count % mode.rawValue) == 0 ? page : page + 1
        guard let width = self.collectionView?.bounds.size.width else {
            return .zero
        }
        return .init(width: width * CGFloat(page), height: 0)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
//        print("\(previousIndexPath)   \(position)")
        return self.collectionView?.indexPathForItem(at: position) ?? previousIndexPath
    }
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attr = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
//        print("\(indexPath)    \(position)  \(attr.frame)")
        return attr
    }
}
