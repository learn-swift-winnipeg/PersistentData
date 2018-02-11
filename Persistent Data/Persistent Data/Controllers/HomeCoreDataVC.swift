//
//  HomeCoreDataVC.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-05.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import UIKit
import CoreData
import Foundation

enum TransactionType {
    case read
    case write
    case update
}

class HomeCoreDataVC: UIViewController {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    
    var time = 0
    var transactions = 0
    
    var timer = Timer()
    
    lazy var databaseManager = DatabaseManager.shared
    
    var transactionType: TransactionType? = nil
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.isActive = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchBar()
        setupTable()
        setupResultController()
        registerNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Setup

extension HomeCoreDataVC {
    func setupUI() {
        if let navigationBar = tabBarController?.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor.main
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.barTintColor = UIColor.main
            tabBar.tintColor = UIColor.white
        }
    }
    
    func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Quick search for entries by guid"
        
        let searchBar = searchController.searchBar
        searchBar.tintColor = UIColor.light
        searchBar.barTintColor = UIColor.light
        searchBar.delegate = self
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.main
            
            if let backgroundView = textfield.subviews.first {
                backgroundView.backgroundColor = UIColor.white
                
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }
        
        tabBarController?.navigationItem.searchController = searchController
        tabBarController?.navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        tabBarController?.navigationItem.hidesSearchBarWhenScrolling = false
        tabBarController?.definesPresentationContext = true
    }
    
    func setupTable() {
        tableView.separatorStyle = .none
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTransaction), name: NSNotification.Name("transaction-performed"), object: nil)
    }
}

// MARK: - Search management

extension HomeCoreDataVC: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        setupResultController()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setupResultController()
    }
}

// MARK: - Tableview management

extension HomeCoreDataVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            // TODO: - Report no sections found in the news table
            print("no sections found in news")
            return 0
        }
        
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SimpleDataCell")
        
        guard let sections = fetchedResultsController.sections else {
            // TODO: - Report no sections found in the news table
            return UITableViewCell(style: .subtitle, reuseIdentifier: "failCellIdentifier")
        }
        
        let sectionInfo = sections[indexPath.section]
        let rowInfo = sectionInfo.objects![indexPath.row] as! Simple
        
        cell.textLabel?.text = rowInfo.guid
        cell.detailTextLabel?.text = rowInfo.createdAt.toStringWithFormat(Configuration.detailedDateFormat)
        
        return cell
    }
}

// MARK: - Fetch results controller

extension HomeCoreDataVC: NSFetchedResultsControllerDelegate {
    func setupResultController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Simple.entityName)
        let createdAtSort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [createdAtSort]
        
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            let searchPredicate = NSPredicate(format: "guid CONTAINS[c] %@", searchController.searchBar.text!)
            
            request.predicate = searchPredicate
        }
        
        let moc = databaseManager.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
            for subview in self.tableView.subviews {
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            if fetchedResultsController.sections == nil || fetchedResultsController.sections![0].numberOfObjects == 0 {
                let emptyTableLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
                emptyTableLabel.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
                emptyTableLabel.text = "No data matching your search!"
                emptyTableLabel.numberOfLines = 0
                emptyTableLabel.textColor = UIColor.main
                emptyTableLabel.textAlignment = .center
                
                self.tableView.addSubview(emptyTableLabel)
            }
        } catch {
            // TODO: - Report error
            print(error)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Timer management

extension HomeCoreDataVC {
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

extension HomeCoreDataVC: UIGestureRecognizerDelegate {
    
    @IBAction func didStartTransactions() {
        databaseManager.isRunningTransactions = true
        
        startTimer()
        self.databaseManager.bulkGeneration()
    }
    
    @IBAction func didStopTransactions() {
        databaseManager.isRunningTransactions = false
        
        stopTimer()
        setupResultController()
    }
    
    @objc func updateTimer() {
        time += 1
        timerLabel.text = "\(time)"
    }
    
    @objc func updateTransaction() {
        DispatchQueue.main.async {
            self.transactions += 1
            self.transactionLabel.text = "\(self.transactions)"
        }
    }
}
