//
//  HomePlistVC.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-20.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import UIKit

class HomePlistVC: UIViewController {
    
    var time = 0
    var transactions = 0
    
    var timer = Timer()
    
    lazy var documentManager = DocumentManager.shared
    
    var database: FileDatabase = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        registerNotifications()
        
        loadDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Setup

extension HomePlistVC {
    func loadDatabase() {
        database = documentManager.getFileDatabase()
    }
    
    func setupTable() {
        tableView.separatorStyle = .none
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTransaction), name: NSNotification.Name("transaction-performed"), object: nil)
    }
}

// MARK: - Tableview management

extension HomePlistVC: UITableViewDataSource, UITabBarDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return database.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AnotherSimpleDataCell")
        
        let data = database[indexPath.row]
        
        cell.textLabel?.text = data.guid
        cell.detailTextLabel?.text = data.createdOn.toStringWithFormat(Configuration.detailedDateFormat)
        
        return cell
    }
}

// MARK: - Timer management

extension HomePlistVC {
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        
        time = 0
        timerLabel.text = "\(time)"
        
        transactions = 0
        transactionLabel.text = "\(transactions)"
    }
    
    func stopTimer() {
        timer.invalidate()
    }
}

// MARK: - Actions

extension HomePlistVC: UIGestureRecognizerDelegate {
    
    @IBAction func didStartTransactions() {
        documentManager.isRunningTransactions = true
        
        startTimer()
        documentManager.bulkGeneration()
    }
    
    @IBAction func didStopTransactions() {
        documentManager.isRunningTransactions = false
        
        stopTimer()
    }
    
    @objc func updateTimer() {
        time += 1
        timerLabel.text = "\(time)"
    }
    
    @objc func updateTransaction() {
        DispatchQueue.global(qos: .background).async {
            self.database = self.documentManager.getFileDatabase()
            DispatchQueue.main.async {
                self.transactions += 1
                self.transactionLabel.text = "\(self.transactions)"
                
                self.tableView.reloadData()
            }
        }
    }
}
