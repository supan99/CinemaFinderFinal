//
//  AddTheaterViewController.swift
//  CinemaFinder


import UIKit
import Firebase

class AddTheaterViewController: UIViewController {

    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    var data: TheaterModel!
    
    
    private func validation(name: String, address: String) -> String {
        if name.isEmpty {
            return STRING.errorEnterTheaterName
        } else if address.isEmpty {
            return STRING.errorEnterTheaterAddress
        } else {
            return ""
        }
    }
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        let error = self.validation(name: self.textFieldFullName.text?.trim() ?? "", address: self.textFieldAddress.text?.trim() ?? "")
        
        if error.isEmpty {
            if self.data != nil {
                self.update(dataID: self.data.docID, name: self.textFieldFullName.text?.trim() ?? "", address: self.textFieldAddress.text?.trim() ?? "")
            }else{
                self.addTheaterData(address: self.textFieldAddress.text?.trim() ?? "", name: self.textFieldFullName.text?.trim() ?? "")
            }
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
    }
    
    @IBAction func btnClickLogout(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnAdd.layer.cornerRadius = 10.0
        
        if data != nil {
            self.textFieldAddress.text = self.data.location
            self.textFieldFullName.text = self.data.name
        }
    }
    
    func addTheaterData(address: String, name:String) {
        var ref : DocumentReference? = nil
        ref = Firestore.firestore().collection(cTheater).addDocument(data:
                                                                        [
                                                                            cTName: name,
                                                                            cTID : "",
                                                                            cTAddress: address,
                                                                                                     ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.update(dataID: ref!.documentID,name: name,address: address)
            }
        }
    }
    
    func update(dataID: String,name:String,address: String) {
        let ref = Firestore.firestore().collection(cTheater).document(dataID)
        ref.updateData([
            cTID: dataID,
            cTName: name,
            cTAddress: address,
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully updated")
                Alert.shared.showAlert(message: self.data != nil ? "Your Theater has been updated successfully !!!" :  "Your Theater has been added successfully !!!") { (true) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
