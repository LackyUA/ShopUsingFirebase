//
//  CartVC.swift
//  ShopApp
//
//  Created by Dmytro Dobrovolskyy on 1/10/19.
//  Copyright © 2019 YellowLeaf. All rights reserved.
//

import UIKit
import Firebase

class CartVC: UIViewController {

    // MARK: - Properties
    private var items = [CartItem]()
    private var itemsReference: DatabaseReference?
    private var currentUserReference: DatabaseReference?
    private var selectedCellIndexPath: IndexPath?
    
    // MARK: - Constants
    private let currentUser = CurrentUser()
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegation()
        getDataFromFirebase()
    }
    private func delegation() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Calculate total price
    func totalPrice() -> Double {
        var totalPrice = 0.0
        for item in items {
            totalPrice += item.price
        }
        
        return round(totalPrice * 100) / 100
    }
    
    // MARK: - Get data from Firebase
    private func getDataFromFirebase() {
        if
            let currentUser = CurrentUser(),
            let reference = createFirebaseReference(components: [FirebasePaths.users.rawValue, currentUser.uid, FirebaseUserKeys.cart.rawValue])
        {
            let path = currentUser.path()
            
            self.itemsReference = reference
            
            self.currentUserReference = Database.database().reference(withPath: path)
            self.currentUserReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                
                if LoggedUser(snapshot: snapshot) != nil {
                    self.itemsReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                        
                        var itemsFromSnapshot = [CartItem]()
                        for itemSnapshot in snapshot.children {
                            if let item = CartItem(snapshot: itemSnapshot as! DataSnapshot) {
                                itemsFromSnapshot.append(item)
                            }
                        }
                        DispatchQueue.global().async {
                            self.items = itemsFromSnapshot
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.totalPriceLabel.text = "Total price: \(self.totalPrice())$"
                            }
                        }
                    })
                }
            })
        }
    }
}

// MARK: - Configure table view delegate
extension CartVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        print("My index is... \(indexPath.row)!")
    }
    
}

// MARK: - Configure table view data source
extension CartVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableIdentifiers.cartItemCell, for: indexPath) as? CartItemCell {
            
            cell.configureCell(item: items[indexPath.row])
            cell.delegate = self
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}

// MARK: - Configure deleting item from cart
extension CartVC: CartCellDelegate {
    
    func removeCell(_ sender: CartItemCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        items[tappedIndexPath.row].removeFromFirebase()
        items.remove(at: tappedIndexPath.row)
        tableView.deleteRows(at: [tappedIndexPath], with: .automatic)
        totalPriceLabel.text = "Total price: \(totalPrice())$"
    }
    
    func changeSize(_ sender: CartItemCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        selectedCellIndexPath = tappedIndexPath
        
        presentAlert()
    }
    
    func changeColor(_ sender: CartItemCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        selectedCellIndexPath = tappedIndexPath
        
        presentAlert()
    }
    
    private func presentAlert() {
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "CartAlertIdentifier") as! CartAlertView
        alert.providesPresentationContextTransitionStyle = true
        alert.definesPresentationContext = true
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.delegate = self
        
        if let indexPath = selectedCellIndexPath {
            alert.itemIdentifier = items[indexPath.row].uid
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Configure size/color choosing
extension CartVC: AlertViewDelegate {
    
    func optionButtonTapped(selectedState: (UIColor?, String?)) {
        if selectedState.0 != nil {
            if let indexPath = selectedCellIndexPath {
                var item = items[indexPath.row].toDictionary()
                item[FirebaseUserKeys.color.rawValue] = selectedState.0?.getHexColor()
                
                currentUser?.updateCartItem (
                    uid: items[indexPath.row].uid,
                    value: item
                )
            }
        } else {
            print("size choosed")
        }
    }
}

// MARK: - Cart cell delegate protocol
protocol CartCellDelegate: class {
    func removeCell(_ sender: CartItemCell)
    func changeSize(_ sender: CartItemCell)
    func changeColor(_ sender: CartItemCell)
}
