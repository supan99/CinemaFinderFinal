//
//  SelectSeatVC.swift
//  CinemaFinder


import UIKit
import Razorpay

class SelectSeatVC: UIViewController {

    @IBOutlet weak var vwSeatCount: UIView!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btn9AM: UIButton!
    @IBOutlet weak var btn3PM: UIButton!
    @IBOutlet weak var btn9PM: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    
    var datePicker = UIDatePicker()
    var count = 1
    let toolBar = UIToolbar()
    var razorpayObj : Razorpay.RazorpayCheckout? = nil
    let razorpayKey = "rzp_test_HCVYCp9beI7gNu"
    var movieData: MovieModel!
    var theaterData: TheaterModel!
    var isSelectTime: Bool = false
    var price: Float = 0.0
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == self.btn9AM {
            self.setupButton(sender1: self.btn9AM, sender2: self.btn3PM, sender3: self.btn9PM)
        } else if sender == self.btn3PM {
            self.setupButton(sender1: self.btn3PM, sender2: self.btn9AM, sender3: self.btn9PM)
        } else if sender == btn9PM {
            self.setupButton(sender1: self.btn9PM, sender2: self.btn9AM, sender3: self.btn3PM)
        } else if sender == self.btnMinus {
            if self.count > 1 {
                self.count -= 1
                self.lblCount.text = self.count.description
            }
        } else if sender == btnPlus {
            if self.count < 5 {
                self.count += 1
                self.lblCount.text = self.count.description
            }
        }
    }
    
    
    func checkPayment() -> String {
        if self.txtDate.text == "" {
            return "Please select date"
        }else if !self.isSelectTime {
            return "Please select time"
        }
        return ""
    }
    
    @IBAction func btnPaymentClick(_ sender: UIButton) {
        
        let error = self.checkPayment()
        
        if error.isEmpty {
            self.price = Float(15 * self.count * 100)
            let options: [String:Any] = ["amount" : price.description,
                                         "description" : "Booking Movie Ticket",
                                         "image": UIImage(named: "img"),
                                         "name" : "Cinema Finder",
                                         "prefill" :
                                            ["contact" : GFunction.user.contactNumber,
                                             "email":GFunction.user.email],
                                         "theme" : "#F00000"]
            
            if let rzp = self.razorpayObj {
                rzp.open(options)
            } else {
                print("Unable to initialize")
            }
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
        
    }
    
    @IBAction func btnProfileClick(_ sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        razorpayObj = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self)
        
        
        self.btn9AM.layer.cornerRadius = 10.0
        self.btn3PM.layer.cornerRadius = 10.0
        self.btn9PM.layer.cornerRadius = 10.0
        self.vwSeatCount.layer.cornerRadius = 10.0
        self.btnPayment.layer.cornerRadius = 10.0
        self.txtDate.delegate = self
        
        self.lblCount.text = self.count.description
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setupButton(sender1: UIButton, sender2: UIButton, sender3: UIButton) {
        self.isSelectTime = true
        sender1.backgroundColor = UIColor.blue
        sender1.isSelected = true
        sender2.isSelected = false
        sender2.backgroundColor = UIColor.hexStringToUIColor(hex: "#E90000")
        sender3.isSelected = false
        sender3.backgroundColor = UIColor.hexStringToUIColor(hex: "#E90000")
    }
    
    func setUpView(){
        self.txtDate.inputView = datePicker
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        components.day = 7
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        self.datePicker.maximumDate = maxDate
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.sizeToFit()
        self.txtDate.inputAccessoryView = toolBar
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func doneButtonTapped() {
        self.txtDate.text = GFunction.shared.getDate(datePicker.date, "dd-MM-yyyy hh:mm:ss +0000", output: "dd-MM-yyyy")
        self.txtDate.resignFirstResponder()
        self.getData3PM()
        self.getData9AM()
        self.getData9PM()
    }
}


extension SelectSeatVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtDate {
            self.datePicker.datePickerMode = .date
            self.datePicker.minimumDate = Date()
            return true
        }
        return false
    }
    
    
    func getTime() -> String {
        if self.btn3PM.isSelected {
            return "3:00 PM"
        }else if self.btn9PM.isSelected {
            return "9:00 PM"
        }else if self.btn9AM.isSelected {
            return "9:00 AM"
        }
        
        return ""
    }
    
    
    func createOrder(paymentId: String, time: String, date: String) {
        let total = (self.count * 15)
        var ref : DocumentReference? = nil
        ref = Firestore.firestore().collection(cBooking).addDocument(data:[
                                                                            cUID: GFunction.user.docID,
                                                                            cTID : self.theaterData.docID,
                                                                            cMID : self.movieData.docID,
                                                                            cTime: time,
                                                                            cDate: date,
                                                                            cTotalPayment: "$\(total)",
                                                                            cSeats: "\(self.count)"
                                                                        ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "Your Ticket has been booked successfully !!!") { Bool in
                    self.emailSend(email: GFunction.user.email, name: GFunction.user.fullName)
                }
            }
        }
    }
    
    func getData3PM(){
        _ = Firestore.firestore().collection(cBooking).whereField(cDate, isEqualTo: self.txtDate.text?.trim() ?? "").whereField(cMID, isEqualTo: movieData.docID).whereField(cTime, isEqualTo: "3:00 PM").whereField(cTID, isEqualTo: theaterData.docID).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var bookedCount = 0
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let seat : Int = data1[cSeats] as? Int {
                        bookedCount += seat
                    }
                }
            }
            
            if !(10 > (bookedCount+self.count)){
                self.btn3PM.backgroundColor = .lightGray
                self.btn3PM.isUserInteractionEnabled = false
            }
        }
    }
    
    
    func getData9PM(){
        _ = Firestore.firestore().collection(cBooking).whereField(cDate, isEqualTo: self.txtDate.text?.trim() ?? "").whereField(cMID, isEqualTo: movieData.docID).whereField(cTime, isEqualTo: "9:00 PM").whereField(cTID, isEqualTo: theaterData.docID).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var bookedCount = 0
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let seat : Int = data1[cSeats] as? Int {
                        bookedCount += seat
                    }
                }
            }
            
            if !(10 > (bookedCount+self.count)){
                self.btn9PM.backgroundColor = .lightGray
                self.btn9PM.isUserInteractionEnabled = false
            }
        }
    }
    
    func getData9AM(){
        _ = Firestore.firestore().collection(cBooking).whereField(cDate, isEqualTo: self.txtDate.text?.trim() ?? "").whereField(cMID, isEqualTo: movieData.docID).whereField(cTime, isEqualTo: "9:00 AM").whereField(cTID, isEqualTo: theaterData.docID).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var bookedCount = 0
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let seat : Int = data1[cSeats] as? Int {
                        bookedCount += seat
                    }
                }
            }
            
            if !(10 > (bookedCount+self.count)){
                self.btn9AM.backgroundColor = .lightGray
                self.btn9AM.isUserInteractionEnabled = false
            }
        }
    }
    
    func emailSend(email: String, name:String){
        self.sendEmail( email: email, name:name){ [unowned self] (result) in
            DispatchQueue.main.async {
                switch result{
                    case .success(_):
                        Alert.shared.showAlert(message: "Your booking has been confirmed successfully !!!") { (bool) in
                            UIApplication.shared.setTab()
                        }
                    case .failure(_):
                        Alert.shared.showAlert(message: "Error", completion: nil)
                }
            }
            
        }
    }
    
    func sendEmail(email: String, name:String, completion: @escaping (Result<Void,Error>) -> Void) {
        let apikey = "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"
        let devemail = "udaydheerajreddy@gmail.com"
        
        let data : [String:String] = [
            "name": name,
            "email": email
        ]
        
        
        let personalization = TemplatedPersonalization(dynamicTemplateData: data, recipients: email)
        let session = Session()
        session.authentication = Authentication.apiKey(apikey)
        
        let from = Address(email: devemail, name: "CinemaFinder")
        let template = Email(personalizations: [personalization], from: from, templateID: "d-f793f3c366ec49b7b0bf264fbf3d91be", subject: "Your booking has been confirmed!!!")
        
        do {
            try session.send(request: template, completionHandler: { (result) in
                switch result {
                    case .success(let response):
                        print("Response : \(response)")
                        completion(.success(()))
                        
                    case .failure(let error):
                        print("Error : \(error)")
                        completion(.failure(error))
                }
            })
        }catch(let error){
            print("ERROR: ")
            completion(.failure(error))
        }
    }
}

extension SelectSeatVC : RazorpayPaymentCompletionProtocol {
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
        Alert.shared.showAlert(message: str, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        self.createOrder(paymentId: payment_id, time: self.getTime(), date: self.txtDate.text?.trim() ?? "")
    }
    
}
