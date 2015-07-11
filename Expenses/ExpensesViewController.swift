import UIKit
import SwiftyDropbox
import RealmSwift

class ExpensesViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var array = Realm().objects(Expense).sorted("date",ascending:false)
    var notificationToken: NotificationToken?
    
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var initialView: UIView!
    
    var searchController = UISearchController()
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDataSource()
        setSearchController()
        setNotificationsForRealmUpdates()
    }
    
    func setTableViewDataSource(){
        self.expensesTableView.dataSource = self;
    }
    
    func setSearchController(){
        self.searchController = UISearchController(searchResultsController: ExpensesResultsTableController())
        
        self.expensesTableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.sizeToFit()

        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
    }
    
    func setNotificationsForRealmUpdates(){
        notificationToken = Realm().addNotificationBlock { [unowned self] note, realm in
            self.updateUI()
        }
    }
    
    // MARK: viewDidAppear
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    func updateUI(){
        updateSummary()
        showInitialViewIfThereAreNoExpenses()
        expensesTableView.reloadData()
    }
    
    func updateSummary(){
        summary.text = Balance.summary()
    }
    
    func showInitialViewIfThereAreNoExpenses(){
        let thereAreNoExpenses = array.count == 0
        initialView.hidden = thereAreNoExpenses ? false : true
    }
    
    @IBAction func linkDropbox(sender: UIBarButtonItem) {
        if Dropbox.authorizedClient == nil {
            Dropbox.authorizeFromController(self)
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    func presentSearchController(searchController:UISearchController) {
    }
    
    func willPresentSearchController(searchController:UISearchController) {
        // do something before the search controller is presented
    }
    
    func didPresentSearchController(searchController:UISearchController) {
        // do something after the search controller is presented
    }
    
    func willDismissSearchController(searchController:UISearchController) {
        // do something before the search controller is dismissed
    }
    
    func didDismissSearchController(searchController:UISearchController) {
        // do something after the search controller is dismissed
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController:UISearchController) {
    }
    
    // MARK: TableView Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ExpenseCell") as? ExpensesTableViewCell {
            
            let expense = array[indexPath.row]
            
            cell.category = expense.category
            
            cell.amount = expense.amount.currency
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/YY"
            let formattedDate = dateFormatter.stringFromDate(expense.date).uppercaseString
            cell.date = formattedDate
            
            let person:String
            if expense.personIndex == 0 {
                person = defaults.objectForKey(kUD_Person1) as? String ?? "1"
            }
            else {
                person = defaults.objectForKey(kUD_Person2) as? String ?? "2"
            }
            
            cell.person = person
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let realm = Realm()
            realm.beginWrite()
            realm.delete(array[indexPath.row])
            realm.commitWrite()
        }
    }
}

