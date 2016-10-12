//
//  GroupsVC.swift
//  Bonapp
//
//  Created by Jonas Larsen on 10/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Firebase

class GroupsVC: UITableViewController {

    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: Constants.Fonts.headerFont]
        
        // Get user
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }

        // Get user ref
        let userRef = FIRDatabase.database().reference(withPath: "users/\(user.uid)/groups")
        
        userRef.observe(.value, with: { snapshot in
            // Get list of groups for user
            let newGroups = snapshot.children.map { child in
                (child as! FIRDataSnapshot).key
            }
            
            self.groups.removeAll()
            for groupId in newGroups {
                FirebaseUtility.read(groupId: groupId) { (group: Group) in
                    // Remove the old with the same key
                    
                    // Insert receipt and reload table
                    self.groups.append(group)
                    self.tableView.reloadSections([0], with: .automatic)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.key
        cell.textLabel?.font = Constants.Fonts.textFont
        
        cell.detailTextLabel?.text = "\(group.receipts.count)"
        cell.detailTextLabel?.font = Constants.Fonts.textFont
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        debugPrint(sender)
        if segue.identifier == "toDetail", let detailVC = segue.destination as? GroupDetailVC, let cell = sender as? UITableViewCell {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            detailVC.group = groups[indexPath.row]
        }
    }
}
