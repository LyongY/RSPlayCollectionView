//
//  RSPlayCollectionView.swift
//  RSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import UIKit

@objc protocol RSPlayCollectionViewDelegate: NSObjectProtocol {
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, willDisappearArray: [Int])
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, didDisappearArray: [Int])
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, didAppearArray: [Int])

    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, selectIndex: Int)
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, deselectIndex: Int)
    
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, selectedItem selectedIndex: Int, moveTo index: Int)
    
    @objc optional func rsplayCollectionView(_ collectionView: RSPlayCollectionView, cleanIndex: Int)
}

class RSPlayCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    weak var delegate: RSPlayCollectionViewDelegate? {
        didSet {
            delegate?.rsplayCollectionView?(self, didAppearArray: appearArray)
            if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
                delegate?.rsplayCollectionView?(self, selectIndex: selectedIndex)
            } else {
                delegate?.rsplayCollectionView?(self, selectIndex: 0)
            }
        }
    }
    
    private var maxSpliteMode: RSPlayCollectionView.SpliteMode
    @objc var spliteMode: RSPlayCollectionView.SpliteMode {
        willSet {
            lastAppearArray = appearArray
        }
        didSet {
            if spliteMode.rawValue > maxSpliteMode.rawValue {
                spliteMode = maxSpliteMode
            }
            if spliteMode != .one {
                lastSplitMode = spliteMode
            }
            longPress.isEnabled = spliteMode != .one
            var selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item ?? 0
            if selectedIndex >= filterDataSource.count {
                selectedIndex = filterDataSource.count - 1
                collectionView.selectItem(at: .init(item: selectedIndex, section: 0), animated: true, scrollPosition: .bottom)
            }
            collectionView.setCollectionViewLayout(layout, animated: false)
            self.collectionView.setContentOffset(.init(x: CGFloat(selectedIndex / self.spliteMode.rawValue) * self.collectionView.bounds.size.width, y: 0), animated: false)
            
            reflashPageIndex()
            reflashTotalPage()
            
            let appearIndexPathArray = appearArray.map { (index) in
                IndexPath(item: index, section: 0)
            }
            appearIndexPathArray.forEach { (indexPath) in
                let cell = collectionView.cellForItem(at: indexPath) as? RSPlayCellBase
                cell?.update(with: self, indexPath: indexPath, dataSourceElement: dataSource.array[indexPath.item])
            }
            
            let disappearArray = lastAppearArray.filter { (item) -> Bool in
                !appearArray.contains(item)
            }
            let currentAppearArray = appearArray.filter { (item) -> Bool in
                !lastAppearArray.contains(item)
            }
            if disappearArray.count != 0 { delegate?.rsplayCollectionView?(self, willDisappearArray: disappearArray) }
            if currentAppearArray.count != 0 { delegate?.rsplayCollectionView?(self, didAppearArray: currentAppearArray) }
            if disappearArray.count != 0 { delegate?.rsplayCollectionView?(self, didDisappearArray: disappearArray) }
            lastAppearArray = appearArray
        }
    }
    
    @objc var currentCellModels: [RSPlayModelBase] { // 当前出现在CollectionView上的的CellModels
        appearArray.map { (index) in
            dataSource.array[index]
        }
    }
    
    var dataSource: RSArray {
        didSet {
            filterDataSource = RSPlayCollectionView.filterRealExistence(dataSource.array)
            resetData()
        }
    }

    private var layout: UICollectionViewLayout {
        let layout = RSPlayCollectionLayout(mode: spliteMode)
        return layout
    }
    private lazy var collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: layout)

    private var registClass: RSPlayCellBase.Type // 单元格所使用的类
    private var filterDataSource: Array<Bool> // 切屏用的无多余无用的数据源
    private var emptyElement: () -> RSPlayModelBase // 需增加数据源的回调

    private (set) var totalPage: Int {
        didSet {
            pageLabel.text = "\(pageIndex + 1)/\(totalPage)"
        }
    }
    private (set) var pageIndex: Int {
        didSet {
            pageLabel.text = "\(pageIndex + 1)/\(totalPage)"
        }
    }
    
    private var lastAppearArray: Array<Int> = [] // 保存即将消失的index
    private var appearArray: [Int] { // 计算要出现的index
        var arr: [Int] = []
        for item in (pageIndex * spliteMode.rawValue) ..< ((pageIndex + 1) * spliteMode.rawValue) {
            arr.append(item)
        }
        return arr
    }
    
    private var beginDragCell: UICollectionViewCell! // 长按时选中的单元格
    private var dragView = UIImageView() // 视觉欺骗
    private let pageLabel = UILabel() // 总页数及当前页
    private let deleteView = RSPlayCollectionView.DeleteView() // 垃圾篓

    private var lastSplitMode: RSPlayCollectionView.SpliteMode = .four // 上一次的分屏模式, 用于双击放大后, 再次双击恢复
    private var lastDataSourceCount: Int // 布局改变, 用来判断是否需补充数据源

    init(_ dataSource: RSArray, registClass: RSPlayCellBase.Type, maxSpliteMode: RSPlayCollectionView.SpliteMode, emptyElement: @escaping () -> RSPlayModelBase) {
        self.emptyElement = emptyElement
        self.registClass = registClass
        self.dataSource = dataSource
        self.maxSpliteMode = maxSpliteMode
        filterDataSource = RSPlayCollectionView.filterRealExistence(dataSource.array)
        spliteMode = .one
        totalPage = 1
        pageIndex = 0
        lastDataSourceCount = dataSource.array.count
        super.init(frame: .zero)
        setupSubviews()
        self.resetData()
    }
    
    @objc convenience init(_ dataSource: RSArray, registClass: RSPlayCellBase.Type, maxSpliteMode: RSPlayCollectionView.SpliteMode, spliteModel: RSPlayCollectionView.SpliteMode, selectedIndex: Int, delegate: RSPlayCollectionViewDelegate?, emptyElement: @escaping () -> RSPlayModelBase) {
        self.init(dataSource, registClass: registClass, maxSpliteMode: maxSpliteMode, emptyElement: emptyElement)
        resizabrrr(spliteModel: spliteModel, selectedIndex: selectedIndex, delegate: delegate)
    }
    
    private func resizabrrr(spliteModel: RSPlayCollectionView.SpliteMode, selectedIndex: Int, delegate: RSPlayCollectionViewDelegate?) {
        self.spliteMode = spliteModel
        self.setSelectedIndex(selectedIndex)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var lastFrame: CGRect = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.frame.equalTo(lastFrame) {
            lastFrame = self.frame
            collectionView.contentOffset = .init(x: CGFloat(pageIndex) * collectionView.bounds.size.width, y: 0)
        }
    }
        
    private var longPress: UILongPressGestureRecognizer!
    private func setupSubviews() {
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.register(registClass, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        self.addConstraints([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressMoving(longPress:)))
        collectionView.addGestureRecognizer(longPress)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(doubleTapGesture:)))
        doubleTap.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(doubleTap)
        
        self.addSubview(pageLabel)
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            pageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            pageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        deleteView.backgroundColor = .gray
        deleteView.state = .inactive
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deleteView)
        self.addConstraints([
            deleteView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            deleteView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            deleteView.widthAnchor.constraint(equalToConstant: 200),
            deleteView.heightAnchor.constraint(equalToConstant: 50),
        ])

    }
}

// MARK:- 交互
extension RSPlayCollectionView {
    // MARK: 设置选中
    @objc func setSelectedIndex(_ index: Int) {
        lastAppearArray = appearArray
        
        if let lastSelectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            delegate?.rsplayCollectionView?(self, deselectIndex: lastSelectedIndex)
        }
        
        collectionView.selectItem(at: .init(item: index, section: 0), animated: false, scrollPosition: .left)
        collectionView.contentOffset = .init(x: CGFloat(index / spliteMode.rawValue) * collectionView.bounds.size.width, y: 0)
        reflashPageIndex()
        
        if !lastAppearArray.elementsEqual(appearArray) {
            delegate?.rsplayCollectionView?(self, willDisappearArray: lastAppearArray)
            delegate?.rsplayCollectionView?(self, didAppearArray: appearArray)
            delegate?.rsplayCollectionView?(self, didDisappearArray: lastAppearArray)
            lastAppearArray = appearArray
        }
        
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            delegate?.rsplayCollectionView?(self, selectIndex: selectedIndex)
        }
    }

    // MARK: 双击
    @objc private func doubleTap(doubleTapGesture: UITapGestureRecognizer) {
        let point = doubleTapGesture.location(in: doubleTapGesture.view)
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }
        setSelectedIndex(indexPath.item)
        if spliteMode != .one {
            spliteMode = .one
        } else {
            spliteMode = lastSplitMode
        }
    }

    // MARK: 拖拽
    @objc private func longPressMoving(longPress: UILongPressGestureRecognizer) {
        let point = longPress.location(in: longPress.view)
        
        var pointInDeleteView = false
        
        if let point = longPress.view?.convert(point, to: deleteView), deleteView.layer.contains(point) {
            pointInDeleteView = true
        }
        
        if #available(iOS 9, *) {
            switch longPress.state {
            case .began:
                pageLabel.isHidden = true
                guard let indexPath = collectionView.indexPathForItem(at: point) else {
                    return
                }
                guard let cell = collectionView.cellForItem(at: indexPath) else {
                    return
                }
                self.setSelectedIndex(indexPath.item)
//                collectionView.beginInteractiveMovementForItem(at: indexPath)
                beginDragCell = cell
                
                cell.isHidden = true
                dragView.frame = cell.frame
                collectionView.addSubview(dragView)
                UIGraphicsBeginImageContext(cell.bounds.size)
                cell.drawHierarchy(in: cell.bounds, afterScreenUpdates: false)
                dragView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                deleteView.state = pointInDeleteView ? .in : .out
            case .changed:
//                collectionView.updateInteractiveMovementTargetPosition(point)
                dragView.center = point
                deleteView.state = pointInDeleteView ? .in : .out
            case .ended:
                if pointInDeleteView {
                    if let pressIndex = collectionView.indexPathsForSelectedItems?.first?.item {
                        delegate?.rsplayCollectionView?(self, cleanIndex: pressIndex)
                        reflashFilterAndRealDataSource()
                        self.beginDragCell = nil
                        self.dragView.removeFromSuperview()
                        collectionView.cancelInteractiveMovement()
                        if let cell = collectionView.cellForItem(at: IndexPath(item: pressIndex, section: 0)) {
                            cell.isHidden = false
                        }
                        deleteView.state = .inactive
                        collectionView.reloadItems(at: [IndexPath(item: pressIndex, section: 0)])
                        return
                    }
                }
                deleteView.state = .inactive
                
                reflashPageIndex()
                pageLabel.isHidden = false
                guard let layout = collectionView.collectionViewLayout as? RSPlayCollectionLayout else {
                    self.beginDragCell = nil
                    self.dragView.removeFromSuperview()
                    return
                }
                
                var optionEndIndex: Int?
                for index in 0..<layout.arr.count {
                    let attr = layout.layoutAttributesForItem(at: .init(item: index, section: 0))
                    if attr!.frame.contains(point) {
                        optionEndIndex = index
                    }
                }
                
                guard let endIndex = optionEndIndex  else {
                    self.beginDragCell = nil
                    self.dragView.removeFromSuperview()
                    collectionView.cancelInteractiveMovement()
                    if let pressIndex = collectionView.indexPathsForSelectedItems?.first?.item,
                        let cell = collectionView.cellForItem(at: IndexPath(item: pressIndex, section: 0)) {
                        cell.isHidden = false
                    }
                    return
                }
                if !appearArray.contains(endIndex) {
                    self.beginDragCell = nil
                    self.dragView.removeFromSuperview()
                    collectionView.cancelInteractiveMovement()
                    if let pressIndex = collectionView.indexPathsForSelectedItems?.first?.item,
                        let cell = collectionView.cellForItem(at: IndexPath(item: pressIndex, section: 0)) {
                        cell.isHidden = false
                    }
                    return
                }
                let endIndexPath = IndexPath(item: endIndex, section: 0)
                let endframe = layout.layoutAttributesForItem(at: endIndexPath)!.frame
                
                let supperStartRect = collectionView.convert(self.dragView.frame, to: collectionView.superview)
                let supperEndRect = collectionView.convert(endframe, to: collectionView.superview)
                collectionView.superview?.addSubview(self.dragView)
                self.dragView.frame = supperStartRect

//                let pressIndex = self.collectionView.indexPathsForSelectedItems!.first!.item

                UIView.animate(withDuration: 0.3, animations: {
                    self.dragView.frame = supperEndRect
                }) { (finish) in
                    self.beginDragCell = nil
                    self.dragView.removeFromSuperview()
                    if let pressIndex = self.collectionView.indexPathsForSelectedItems?.first?.item,
                        let cell = self.collectionView.cellForItem(at: IndexPath(item: pressIndex, section: 0)) {
                        cell.isHidden = false
                        self.delegate?.rsplayCollectionView?(self, deselectIndex: pressIndex)
                        let pressDataSource = self.dataSource.array[pressIndex]
                        self.dataSource.array[pressIndex] = self.dataSource.array[endIndex]
                        self.dataSource.array[endIndex] = pressDataSource
                        self.filterDataSource = RSPlayCollectionView.filterRealExistence(self.dataSource.array)
                        self.collectionView.reloadData()
                        // reloadData后, 选中会被清除
                        self.collectionView.selectItem(at: endIndexPath, animated: false, scrollPosition: .left)
                        self.collectionView.contentOffset = .init(x: CGFloat(endIndex / self.spliteMode.rawValue) * self.collectionView.bounds.size.width, y: 0)
                        self.delegate?.rsplayCollectionView?(self, selectIndex: endIndex)
                    }
                }

                collectionView.endInteractiveMovement()
                
            default:
                deleteView.state = .inactive
                reflashPageIndex()
                pageLabel.isHidden = false
                collectionView.cancelInteractiveMovement()
                beginDragCell = nil
                dragView.removeFromSuperview()
            }
        }
    }
}

// MARK:- ScrollViewDelegate
extension RSPlayCollectionView {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastAppearArray = appearArray
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reflashPageIndex()
        
        if !lastAppearArray.elementsEqual(appearArray) {
            delegate?.rsplayCollectionView?(self, willDisappearArray: lastAppearArray)
            delegate?.rsplayCollectionView?(self, didAppearArray: appearArray)
            delegate?.rsplayCollectionView?(self, didDisappearArray: lastAppearArray)
            lastAppearArray = appearArray
            
            self.setSelectedIndex(pageIndex * spliteMode.rawValue)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            reflashPageIndex()
            
            if !lastAppearArray.elementsEqual(appearArray) {
                delegate?.rsplayCollectionView?(self, willDisappearArray: lastAppearArray)
                delegate?.rsplayCollectionView?(self, didAppearArray: appearArray)
                delegate?.rsplayCollectionView?(self, didDisappearArray: lastAppearArray)
                lastAppearArray = appearArray
                
                self.setSelectedIndex(pageIndex * spliteMode.rawValue)
            }
        }
    }
}

// MARK:- Help
extension RSPlayCollectionView {
    private static func filterRealExistence(_ array: [RSPlayModelBase]) -> [Bool] {
        var temp = Array(array)
        while true {
            if let last = temp.last {
                if last.realExistence() {
                    return temp.map { $0.realExistence() }
                }
            } else {
                return []
            }
            temp.removeLast()
        }
    }

    private func resetData() {
        // 切模式
        if filterDataSource.count <= 1 {
            spliteMode = .one
        } else if filterDataSource.count <= 4 {
            spliteMode = .four
        } else if filterDataSource.count <= 6 {
            spliteMode = .six
        } else if filterDataSource.count <= 8 {
            spliteMode = .eight
        } else if filterDataSource.count <= 9 {
            spliteMode = .night
        } else {
            spliteMode = .sixteen
        }
        
        // 回到 Point(0, 0)
        collectionView.contentOffset = .zero
        
        // 当前页 0
        pageIndex = 0
        
        // 选中 0
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
        
        lastDataSourceCount = dataSource.array.count
    }
    
    private func reflashPageIndex() {
        let index = Int(collectionView.contentOffset.x / collectionView.bounds.size.width)
        pageIndex = index

    }
    
    private func reflashTotalPage() {
        // 总页数
        let isFull = filterDataSource.count % spliteMode.rawValue == 0;
        let tempTotalPage = filterDataSource.count / spliteMode.rawValue;
        totalPage = isFull ? tempTotalPage : tempTotalPage + 1;
    }
    
    private func reflashFilterAndRealDataSource() {
        while true {
            if let last = filterDataSource.last {
                if last {
                    break
                }
            } else {
                filterDataSource = []
                break
            }
            filterDataSource.removeLast()
        }
    }
        
    private func needToIncreaseCount() -> Int {
        if filterDataSource.count % spliteMode.rawValue != 0 {
            return spliteMode.rawValue - filterDataSource.count % spliteMode.rawValue
        }
        return 0
    }
}

// MARK:- CollectionViewDelegate
extension RSPlayCollectionView {
    // MARK: 交换位置, 不再采用插入
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // dataSource
        let temp = self.dataSource.array.remove(at: sourceIndexPath.item)
        self.dataSource.array.insert(temp, at: destinationIndexPath.item)
        reflashFilterAndRealDataSource()
        delegate?.rsplayCollectionView?(self, selectedItem: sourceIndexPath.item, moveTo: destinationIndexPath.item)
    }

    // MARK: delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = filterDataSource.count
        let increase = needToIncreaseCount()
        let allCount = count + increase
        if lastDataSourceCount > allCount { // 删掉多的空的
            dataSource.array.removeLast(lastDataSourceCount - allCount)
            lastDataSourceCount = allCount
        }
        while dataSource.array.count < allCount {
            dataSource.array.append(emptyElement())
        }
        lastDataSourceCount = allCount
        return allCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RSPlayCellBase
        cell.update(with: self, indexPath: indexPath, dataSourceElement: dataSource.array[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.rsplayCollectionView?(self, selectIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.rsplayCollectionView?(self, deselectIndex: indexPath.item)
    }
        
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let point = CGPoint(x: CGFloat(pageIndex) * collectionView.bounds.size.width, y: 0)
        return point
    }
}

// MARK:- 类
extension RSPlayCollectionView {
    @objc enum SpliteMode: Int {
        case one = 1
        case four = 4
        case six = 6
        case eight = 8
        case night = 9
        case sixteen = 16
    }

    class DeleteView: UIView {
        var state: RSPlayCollectionView.DeleteView.State = .out {
            didSet {
                switch state {
                case .in:
                    self.backgroundColor = .red
                    self.isHidden = false
                case .out:
                    self.backgroundColor = .gray
                    self.isHidden = false
                default:
                    self.backgroundColor = .gray
                    self.isHidden = true
                }
            }
        }
        enum State {
            case `in`
            case out
            case inactive
        }
    }
}

@objc class RSArray: NSObject {
    @objc var array: Array<RSPlayModelBase>
    
    @objc init(with array: Array<RSPlayModelBase>) {
        self.array = array
    }
}

