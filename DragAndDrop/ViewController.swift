//
//  ViewController.swift
//  DragAndDrop
//
//  Created by Pushpank Kumar on 09/04/20.
//  Copyright © 2020 Pushpank Kumar. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
    var leftTableView = UITableView()
    var rightTableView = UITableView()
    var leftItems = [String](repeating: "left", count: 20)
    var rightItems = [String](repeating: "right", count: 20)
    
}


// View Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLeftTableView()
        setUpRightTableView()
    }
}

// Private functions
extension ViewController {
    
    private func setUpLeftTableView() {
        
        leftTableView.frame = CGRect(x: 0, y: 40, width: 150, height: 400)
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(leftTableView)
        leftTableView.dataSource = self
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        leftTableView.dragInteractionEnabled = true
        
    }
    
    private func setUpRightTableView() {
        
        rightTableView.frame = CGRect(x: 150, y: 40, width: 150, height: 400)
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(rightTableView)
        rightTableView.dataSource = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        rightTableView.dragInteractionEnabled = true
    }
}


// TableView DataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == leftTableView ? leftItems.count : rightItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text =  tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        return cell
    }
}

// TableView DragDelegate
extension ViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let string = tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        guard let data = string.data(using: .utf8) else {
            return []
        }
        
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}


extension ViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
            
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section - 1)
            destinationIndexPath = IndexPath(row: row, section: section)
            
        }
        // atempt to load strings from the drop coordinator
        coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
            
            // convert the item provider array to a string array or boil out
            guard let strings = items as? [String] else { return }
            
            // create an empty array to track rows we have copied
            var indexPaths = [IndexPath]()
            
            // loop over all the strings we received
            
            for (index, item) in strings.enumerated() {
                // create an indexpath for this new row. moving it down depending on how many we have already inserted
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                // insert the copy into the correct way
                if tableView == self.leftTableView {
                    self.leftItems.insert(item, at: indexPath.row)
                } else {
                    self.rightItems.insert(item, at: indexPath.row)
                }
                
                // keep track of this new one
                indexPaths.append(indexPath)
            }
            //insert them all into the tableView at once
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
