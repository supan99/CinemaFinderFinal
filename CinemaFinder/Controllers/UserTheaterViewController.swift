//
//  UserTheaterViewController.swift
//  CinemaFinder


import UIKit

class UserTheaterViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var labelNOData: UILabel!
    
    var movieData: MovieModel!
    var pendingItem: DispatchWorkItem?
    var pendingRequest: DispatchWorkItem?
    var array = [TheaterModel]()
    var arrayData = [TheaterModel]()
    
    @IBAction func btnClickAdd(_ sender: UIButton) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: UserProfile.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnClickLogout(_ sender: UIButton) {
        UIApplication.shared.setStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
}


extension UserTheaterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.labelNOData.isHidden = true
        self.tableView.isHidden = false
        if self.arrayData.count == 0 {
            self.labelNOData.isHidden = false
            self.tableView.isHidden = true
        }
        
        return self.arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TheaterCellUser", for: indexPath) as! TheaterCellUser
        cell.labelName.text = self.arrayData[indexPath.row].name
        cell.labelAddress.text = self.arrayData[indexPath.row].location
        let tap = UITapGestureRecognizer()
        tap.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SelectSeatVC.self){
                vc.movieData = self.movieData
                vc.theaterData = self.arrayData[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell.viewMain.isUserInteractionEnabled = true
        cell.viewMain.addGestureRecognizer(tap)
        return cell
    }
    
    func getData(){
        _ = Firestore.firestore().collection(cTheater).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[cTName] as? String, let address: String = data1[cTAddress] as? String, let id :String = data1[cTID] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(TheaterModel(docID: id, name: name, location: address))
                    }
                }
                self.arrayData = self.array
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
}


class TheaterCellUser: UITableViewCell {
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewMain.layer.cornerRadius = 10.0
    }
}


//MARK:- UISearchBarDelegate Delegate methods :-
extension UserTheaterViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        self.pendingRequest?.cancel()
        
        guard searchBar.text != nil else {
            return
        }
        
        if(searchText.count == 0 || (searchText == " ")){
            self.arrayData = self.array
            self.tableView.reloadData()
            return
        }
        
        self.pendingRequest = DispatchWorkItem{ [weak self] in
            guard let self = self else { return }
            self.arrayData = self.array.filter({$0.name.localizedStandardContains(searchText)})
            self.tableView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: self.pendingRequest!)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.arrayData = self.array.filter({$0.name.localizedStandardContains(searchBar.text!)})
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.arrayData = self.array
        self.searchBar.resignFirstResponder()
    }
}
