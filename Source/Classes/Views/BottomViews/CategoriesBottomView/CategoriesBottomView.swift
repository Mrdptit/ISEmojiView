//
//  CategoriesBottomView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let MinCellSize = CGFloat(35)

internal protocol CategoriesBottomViewDelegate: class {
    
    func categoriesBottomViewDidSelecteCategory(_ category: Category, bottomView: CategoriesBottomView)
    func categoriesBottomViewDidPressChangeKeyboardButton(_ bottomView: CategoriesBottomView)
    func categoriesBottomViewDidPressDeleteBackwardButton(_ bottomView: CategoriesBottomView)
    
}

final internal class CategoriesBottomView: UIView {
    
    // MARK: - Internal variables
    
    internal weak var delegate: CategoriesBottomViewDelegate?
    
    // MARK: - Private variables
    
    private var categories: [Category]!
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var changeKeyboardButtonView: UIView!
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        }
    }
    
    @IBOutlet private var collectionViewToSuperViewLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Init functions
    
    static internal func loadFromNib(with categories: [Category], needToShowChangeKeyboardButton: Bool) -> CategoriesBottomView {
        let nibName = String(describing: CategoriesBottomView.self)
        
        guard let nib = Bundle.podBundle.loadNibNamed(nibName, owner: nil, options: nil) as? [CategoriesBottomView] else {
            fatalError()
        }
        
        guard let bottomView = nib.first else {
            fatalError()
        }
        
        bottomView.categories = categories
        
        let indexPath = IndexPath(item: 0, section: 0)
        bottomView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        bottomView.changeKeyboardButtonView.isHidden = !needToShowChangeKeyboardButton
        
        if needToShowChangeKeyboardButton {
            bottomView.collectionViewToSuperViewLeadingConstraint.priority = .defaultHigh
        }
        
        return bottomView
    }
    
    // MARK: - Override functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            var size = collectionView.bounds.size
            
            if categories.count < Category.count - 2 {
                size.width = MinCellSize
            } else {
                size.width = collectionView.bounds.width/CGFloat(categories.count)
            }
            
            layout.itemSize = size
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Internal functions
    
    internal func updateCurrentCategory(_ category: Category) {
        guard let item = categories.index(where: { $0 == category }) else {
            return
        }
        
        (0..<categories.count).forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    // MARK: - IBActions
    
    @IBAction private func changeKeyboard() {
        delegate?.categoriesBottomViewDidPressChangeKeyboardButton(self)
    }
    
    @IBAction private func deleteBackward() {
        delegate?.categoriesBottomViewDidPressDeleteBackwardButton(self)
    }
    
}

// MARK: - UICollectionViewDataSource

extension CategoriesBottomView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.setEmojiCategory(categories[indexPath.item])
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension CategoriesBottomView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoriesBottomViewDidSelecteCategory(categories[indexPath.item], bottomView: self)
    }
    
}
