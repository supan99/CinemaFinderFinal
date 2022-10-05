//
//  HistoryViewController.swift
//  CinemaFinder

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: SelfSizedTableView!
    
    var array = [BookingModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLogoutClick(_ sender: UIButton) {
        UIApplication.shared.setStart()
    }
}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.configCell(data: self.array[indexPath.row])
        return cell
    }
    
    
    func getData(){
        _ = Firestore.firestore().collection(cBooking).whereField(cUID, isEqualTo: GFunction.user.docID).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if
                        let date: String = data1[cDate] as? String,
                        let time: String = data1[cTime] as? String,
                        let tid :String = data1[cTID] as? String,
                        let mid :String = data1[cMID] as? String,
                        let seats :String = data1[cSeats] as?  String,
                        let total :String = data1[cTotalPayment] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(BookingModel(docID: data.documentID, date: date, time: time, seats: seats, tID: tid, mID: mid, totalPayment: total))
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
    
    
    
    
    
}



class HistoryCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelSeats: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var viewMain: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewMain.layer.borderColor = UIColor.red.cgColor
        self.viewMain.layer.borderWidth = 1.0
        self.viewMain.layer.cornerRadius = 10.0
    }
    
    func configCell(data: BookingModel) {
        self.labelID.text = "ORDER ID: \(data.docID.description)"
        self.labelDate.text = "DATE & TIME: \(data.date.description) at \(data.time.description)"
        self.labelSeats.text = "SEATS: \(data.seats.description) seats you have booked."
        self.labelPrice.text = "PRICE: \(data.totalPayment.description)"
        
        self.getMovieData(mid: data.mID)
        self.getTheaterData(tid: data.tID)
    }
    
    func getMovieData(mid: String) {
        _ = Firestore.firestore().collection(cMovie).whereField(cMID, isEqualTo: mid).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if snapshot.documents.count != 0 {
                self.labelName.text = "MOVIE: \(snapshot.documents[0].data()[cMName] as? String ?? "")".description
            }
        }
    }
    
    func getTheaterData(tid: String) {
        _ = Firestore.firestore().collection(cTheater).whereField(cTID, isEqualTo: tid).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if snapshot.documents.count != 0 {
                self.labelAddress.text = "THEATER: \(snapshot.documents[0].data()[cTName] as? String ?? "")".description
            }
        }
    }

}
