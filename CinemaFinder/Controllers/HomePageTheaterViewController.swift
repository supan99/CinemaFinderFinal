//
//  HomePageTheaterViewController.swift
//  CinemaFinder

import UIKit

class HomePageTheaterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonAdd: UIButton!
    
    
    var array = [TheaterModel]()
    
    
    @IBAction func btnClickAdd(_ sender: UIButton) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: AddTheaterViewController.self) {
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


extension HomePageTheaterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TheaterCell", for: indexPath) as! TheaterCell
        cell.configCell(data: self.array[indexPath.row])
        cell.buttonEdit.addAction(for: .touchUpInside) {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddTheaterViewController.self) {
                vc.data = self.array[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        cell.buttonDelete.addAction(for: .touchUpInside) {
            Alert.shared.showAlert("CinemaFinder", actionOkTitle: "Delete", actionCancelTitle: "Cancel", message: "Are you sure you want to delete this theater? ") { (true) in
                self.delete(dataID: self.array[indexPath.row].docID)
            }
        }
        
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
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func delete(dataID: String) {
        let ref = Firestore.firestore().collection(cTheater).document(dataID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                Alert.shared.showAlert(message: "Your Theater has been deleted successfully !!!",completion: nil)
                self.getData()
            }
        }
    }
}




class TheaterCell: UITableViewCell {
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonEdit.layer.cornerRadius = 10.0
        self.buttonDelete.layer.cornerRadius = 10.0
    }
    
    func configCell(data: TheaterModel) {
        self.labelName.text = data.name
        self.labelAddress.text = data.location
    }
}
