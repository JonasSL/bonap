//
//  GroupDetailVC.swift
//  Bonapp
//
//  Created by Jonas Larsen on 12/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Firebase
import Charts

class GroupDetailVC: UITableViewController {

    var groupReceipts: [Receipt] = []
    var group: Group!
    var groupUsers: [(String,String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: Constants.Fonts.headerFont]
        navigationItem.title = group.key

        tableView.register(UINib(nibName: "ReceiptCell", bundle: nil), forCellReuseIdentifier: "receiptCell")
        tableView.register(UINib(nibName: "ChartCell", bundle: nil), forCellReuseIdentifier: "chartCell")

        // Setup listener for group receipts
        
        // Get db ref for that user's receipts
        let receiptsRef = FIRDatabase.database().reference(withPath: "groups/\(group.key)/receipts")
        
        // Start listener
        receiptsRef.observe(.value, with: { snapshot in
            
            // Get list of receipts
            let newReceipts = snapshot.children.map { child in
                (child as! FIRDataSnapshot).key
            }
            
            self.groupReceipts.removeAll()
            for receiptId in newReceipts {
                FirebaseUtility.read(receiptId: receiptId) { (receipt: Receipt) in
                    self.groupReceipts.append(receipt)
                    // Reload table if this is the last receipt
                    if newReceipts.last == receiptId {
                        self.tableView.reloadSections([1], with: .automatic)
                        self.tableView.reloadSections([0], with: .automatic)

                    }
                }
            }
        })
        
        let userRef = FIRDatabase.database().reference(withPath: "groups/\(group.key)/members")
        
        // Start listener
        userRef.observe(.value, with: { snapshot in
            
            // Get list of new users
            let newUsers = snapshot.children.flatMap { child in
                ((child as! FIRDataSnapshot).key ,(child as! FIRDataSnapshot).value as! String)
            }
            
            self.groupUsers = newUsers
            
            self.tableView.reloadSections([2], with: .automatic)
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return groupReceipts.count
        case 2:
            return groupUsers.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        
        // Status
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell") as! ChartCell
            
            var dataEntries: [PieChartDataEntry] = []
            
            guard !groupUsers.isEmpty && !groupReceipts.isEmpty else {
                return cell
            }
            
            // Find how much each member has payed
            for user in groupUsers {
                let payedAmount = getPayedAmount(for: user.0)
                let entry = PieChartDataEntry(value: payedAmount, label: user.1)
                dataEntries.append(entry)
            }
            
            let julieEntry: [PieChartDataEntry] = [PieChartDataEntry(value: 354, label: "Jonas"), PieChartDataEntry(value: 847, label: "Julie"),PieChartDataEntry(value: 1000, label: "Mor"),PieChartDataEntry(value: 250, label: "Far")]


            let dataSet = PieChartDataSet(values: dataEntries, label: nil)
            dataSet.sliceSpace = 3
            dataSet.colors = [Constants.Colors.green, UIColor.lightGray, UIColor.lightGray, UIColor.lightGray]
            
            let chartData = PieChartData(dataSet: dataSet)
            chartData.setValueTextColor(UIColor.black)
            chartData.setValueFont(Constants.Fonts.textFont)
            let formatter = NumberFormatter()
            formatter.positiveSuffix = " kr."
            
//            jonasData.setValueFormatter(formatter as! IValueFormatter)
            
            cell.pieChartView.data = chartData
            cell.pieChartView.centerText = "Betalt"
            cell.pieChartView.descriptionText = ""
            cell.pieChartView.animate(xAxisDuration: 2, easingOption: .easeOutExpo)
            return cell
            
            
        // Receipts
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell") as! ReceiptCell
            
            let receiptForRow = groupReceipts[indexPath.row]
            cell.titleLabel.text = receiptForRow.storeName
            cell.dateLabel.text = receiptForRow.timestamp.formatted(withDateStyle: .medium, andTimeStyle: .medium)
            cell.priceLabel.text = receiptForRow.total?.description
            cell.userLabel.text = "Jonas"
            return cell
            
        // Users
        case 2:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = groupUsers[indexPath.row].1
            cell.textLabel?.font = Constants.Fonts.textFont
            return cell
        default:
            break
        }
        
        
        // Use default cell
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Not implemented"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Status"
        case 1:
            return "Bonner"
        case 2:
            return "Medlemmer"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300
        case 1:
            return 55
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        
        // Receipts
        case 1:
            
            let selectedReceipt = groupReceipts[indexPath.row]
            
            let storyBoard = UIStoryboard(name: "Receipts", bundle: nil)
            let receiptDetailVC = storyBoard.instantiateViewController(withIdentifier: "receiptDetails") as! ReceiptDetailVC
            
            // Set receipt
            receiptDetailVC.receipt = selectedReceipt
            navigationController?.pushViewController(receiptDetailVC, animated: true)
            
        default:
            break
        }
    }
    
    //MARK: - Helper methods
    private func getPayedAmount(for uid: String) -> Double {
        let payedReceipts = groupReceipts.filter { receipt in
            receipt.ownerUid == uid
        }
        
        // Count recursively starting from 0
        return payedReceipts.reduce(0) { result, current in
            result + (current.total ?? 0)
        }
    }
    
}
