//
//  ShopVC.swift
//  ShopApp
//
//  Created by Dmytro Dobrovolskyy on 11/7/18.
//  Copyright © 2018 YellowLeaf. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ShopVC: UIViewController {

    // MARK: - Constants
    private let descriptionAttribute: [NSAttributedString.Key: Any] = [
        .backgroundColor: UIColor.clear,
        .font: UIFont.boldSystemFont(ofSize: 16),
        .foregroundColor: UIColor.black
    ]

    // MARK: - Properties
    private var ref : DatabaseReference!
    private var items = [Item]()
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegations()
        loadItemsFromFirebase()
        
    }
    private func delegations() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Firebase loader
    private func loadItemsFromFirebase() {
        ref =  Database.database().reference()
        ref.child("assortment/items").observeSingleEvent(of: .value) { snapshot in
            let json = JSON(snapshot.value as? [String : Any] ?? [:])
            json.forEach({ value in
                self.items.append(Item.fromJSON(json.dictionaryObject ?? [:], withID: value.0))
            })
            self.items.forEach({ item in
                self.collectionView.reloadData()
                print("ID: \(item.id)\nNAME: \(item.name)\nCATEGORIES: \(item.categories)\nIMAGES: \(item.images)")
            })
        }
    }

}

// MARK: - Configure collection view data source and delegate
extension ShopVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reusableIdentifiers.shopItemCell, for: indexPath) as? ShopItemCell {
            
            cell.configureCell(
                imageUrl: items[indexPath.item].images.first ?? "",
                description: NSAttributedString(string: items[indexPath.item].name, attributes: descriptionAttribute)
            )
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Constants.shopViewInsets.sectionInsets.left * (Constants.shopViewInsets.itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / Constants.shopViewInsets.itemsPerRow
        
        return CGSize(width: widthPerItem, height: Constants.shopViewInsets.itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return Constants.shopViewInsets.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.shopViewInsets.sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Details") as? ItemDetailsVC {
            detailController.item = items[indexPath.row]
            present(detailController, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.reusableIdentifiers.headerView, for: indexPath) as! HeaderReusableView
            
            reusableView.configureHeader()

            return reusableView

        default:
            assert(false, "Unexpected element kind")
        }
    }
    
}
