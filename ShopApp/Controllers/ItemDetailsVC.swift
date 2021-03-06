//
//  ItemDetailsVC.swift
//  ShopApp
//
//  Created by Dmytro Dobrovolskyy on 1/3/19.
//  Copyright © 2019 YellowLeaf. All rights reserved.
//

import UIKit

class ItemDetailsVC: UIViewController {
    
    // MARK: - Properties
    var item = ShopItem()
    
    // MARK: - Constants
    let currentUser = CurrentUser()
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var availabilityLabel: UILabel!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    // MARK: - Actions
    @IBAction func backToListTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        switch sender.tag {
            
        // Favorite button
        case 0:
            print("Favorite")
            
        // Card button
        case 1:
            if Connectivity.isConnectedToInternet {
                currentUser?.addCartItem(
                    uid: item.uid,
                    value: [
                        Constants.firebaseUserKeys.size: item.sizes.first?.key ?? 37,
                        Constants.firebaseUserKeys.color: item.colors.first?.key ?? "",
                        Constants.firebaseUserKeys.price: item.price,
                        Constants.firebaseUserKeys.name: item.name,
                        Constants.firebaseUserKeys.image: item.images.first ?? "",
                        Constants.firebaseUserKeys.uid: item.uid
                    ]
                )
                self.present(UIAlertController.withMessage(message: "Item added to cart.\nYou can choose size, color and count of items in cart.\nThank you for choosing our shop."), animated: true)
            } else {
                self.present(UIAlertController.withMessage(message: "Adding item to cart failed.\nPlease check your internet connection."), animated: true)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate()
        configureInterface()
    }
    
    // MARK: - Delegations
    private func delegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Interface methods
    private func configureInterface() {
        priceLabel.text = "Price: \(item.price)$"
        if item.count != 0 {
            availabilityLabel.text = "In stock"
            availabilityLabel.textColor = .green
        } else {
            availabilityLabel.text = "Not available"
            availabilityLabel.textColor = .red
        }
        
        pageControl.numberOfPages = item.images.count
    }
    
    // MARK: - Page swipe detector
    private var currentCellIndexPath: Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return 0 }
        
        return indexPath.row
    }
    
}

// MARK: - Configure collection view data source and delegate
extension ItemDetailsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reusableIdentifiers.detailsImageCell, for: indexPath) as? DetailsImageCell {
            cell.configureCell(imageUrl: item.images[indexPath.row])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return Constants.detailViewInsets.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.detailViewInsets.sectionInsets.left
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentCellIndexPath
    }
    
}
