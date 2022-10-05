//
//  UserProfile.swift
//  CinemaFinder


import UIKit
import FirebaseFirestore
import FirebaseAuth

class UserProfile: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtContact: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnSaveChanges: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnSeeHistory: UIButton!
    
    let email: String = FirebaseAuth.Auth.auth().currentUser?.email ?? ""
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnReset {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: ResetPasswordVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnSaveChanges {
            let error = self.validation(name: self.txtName.text?.trim() ?? "", mobile: self.txtContact.text?.trim() ?? "")
            if error.isEmpty {
                self.update(dataID: FirebaseAuth.Auth.auth().currentUser?.uid ?? "", name: self.txtName.text?.trim() ?? "", phone: self.txtContact.text?.trim() ?? "")
            }else{
                Alert.shared.showAlert(message: error, completion: nil)
            }
        }else if sender == btnSeeHistory {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: HistoryViewController.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func validation(name: String, mobile: String) -> String {
        if name.isEmpty {
            return STRING.errorEnterName
        } else if mobile.isEmpty {
            return STRING.errorMobile
        } else if !Validation.isValidPhoneNumber(mobile) {
            return STRING.errorValidMobile
        }
        return ""
    }
    
    @IBAction func btnLogoutClick(_ sender: UIButton) {
        UIApplication.shared.setStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
    }

    
    func getData(){
        Firestore.firestore().collection(cUser).whereField(cEmail, isEqualTo: email).addSnapshotListener{querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            let data1 = snapshot.documents[0].data()
            if let name: String = data1[cName] as? String, let email: String = data1[cEmail] as? String, let phone: String = data1[cPhone] as? String {
                //                GFunction.user = UserModel(docID: "", name: name, email: email, password: password, phone: phone)
                self.txtEmail.text = FirebaseAuth.Auth.auth().currentUser?.email
                self.txtName.text = name
                self.txtContact.text = phone
            }
            
            self.btnSaveChanges.layer.cornerRadius = 10.0
            // Do any additional setup after loading the view.
        }
    }
    
    func update(dataID: String,name:String,phone: String) {
        let ref = Firestore.firestore().collection(cUser).document(dataID)
        ref.updateData([
            cPhone: phone,
            cName: name,
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully updated")
                Alert.shared.showAlert(message: "Your profile has been updated successfully !!!") { (true) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
