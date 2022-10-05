//
//  HomePageMovieViewController.swift
//  CinemaFinder


import UIKit

class HomePageMovieViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var array = [MovieModel]()
    
    @IBAction func btnClickAdd(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let vc = UIStoryboard.main.instantiateViewController(withClass: AddMovieViewController.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnClickLogout(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStart()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        // Do any additional setup after loading the view.
    }

}

extension HomePageMovieViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.configCell(data: self.array[indexPath.row])
        cell.buttonEdit.addAction(for: .touchUpInside) {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddMovieViewController.self) {
                vc.data = self.array[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        cell.buttonDelete.addAction(for: .touchUpInside) {
            Alert.shared.showAlert("CinemaFinder", actionOkTitle: "Delete", actionCancelTitle: "Cancel", message: "Are you sure you want to delete this movie? ") { (true) in
                self.delete(dataID: self.array[indexPath.row].docID)
            }
        }
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
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func delete(dataID: String) {
        let ref = Firestore.firestore().collection(cMovie).document(dataID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                Alert.shared.showAlert(message: "Your movie has been deleted successfully !!!", completion: nil)
                self.getData()
            }
        }
    }
}




class MovieCell: UITableViewCell {
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonEdit.layer.cornerRadius = 10.0
        self.buttonDelete.layer.cornerRadius = 10.0
    }
    
    func configCell(data: MovieModel) {
        self.labelName.text = data.name
        self.imageViewProfile.setImgWebUrl(url: data.imageurl, isIndicator: true)
    }
}
