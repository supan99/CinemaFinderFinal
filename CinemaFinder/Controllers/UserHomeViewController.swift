//
//  UserHomeViewController.swift
//  CinemaFinder

import UIKit

class UserHomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var labelNOData: UILabel!
    
    var pendingItem: DispatchWorkItem?
    var pendingRequest: DispatchWorkItem?
    var array = [MovieModel]()
    var arrayData = [MovieModel]()
    
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
        self.labelNOData.isHidden = true
        self.tableView.isHidden = false
        self.getData()
        self.searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
}


extension UserHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellUser", for: indexPath) as! MovieCellUser
        cell.configCell(data: self.arrayData[indexPath.row])
        let tap = UITapGestureRecognizer()
        tap.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: UserTheaterViewController.self) {
                vc.movieData = self.arrayData[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell.viewMain.isUserInteractionEnabled = true
        cell.viewMain.addGestureRecognizer(tap)
        return cell
    }
    
    func getData(){
        _ = Firestore.firestore().collection(cMovie).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[cMName] as? String, let id :String = data1[cMID] as? String, let cast:String = data1[cMCast] as? String, let dName:String = data1[cMDName] as? String, let imageURL: String = data1[cImageURL] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(MovieModel(docID: id, name: name, starCast: cast,dName: dName, imageurl: imageURL))
                    }
                }
                self.arrayData = self.array
                self.labelNOData.isHidden = true
                self.tableView.isHidden = false
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                self.labelNOData.isHidden = false
                self.tableView.isHidden = true
            }
        }
    }
}


class MovieCellUser: UITableViewCell {
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelDirector: UILabel!
    
    
    func configCell(data: MovieModel) {
        self.labelName.text = data.name
        self.labelPrice.text = data.starCast
        self.labelDirector.text = data.dName
        self.imageViewProfile.setImgWebUrl(url: data.imageurl, isIndicator: true)
    }
    
    override func awakeFromNib() {
        
        self.imageViewProfile.layer.cornerRadius = 10.0
    }
}


//MARK:- UISearchBarDelegate Delegate methods :-
extension UserHomeViewController : UISearchBarDelegate{
    
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
