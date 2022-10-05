//
//  SignUpVC.swift
//  CinemaFinder

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CloudKit

class SignUpVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSignUP: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    
    var flag : Bool = true
   
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnSignIn {
            self.navigationController?.popViewController(animated: true)
        }else if sender == btnSignUP {
            self.flag = false
            
            let error = self.validation(name: self.txtName.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", mobile: self.txtPhone.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", confirmPass: self.txtConfirmPassword.text?.trim() ?? "")
        
            if error.isEmpty {
                self.firebaseRegister(fullName: self.txtName.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", contactNumber: self.txtPhone.text?.trim() ?? "")
            }else{
                Alert.shared.showAlert(message: error, completion: nil)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func validation(name: String, email: String,mobile: String, password: String, confirmPass: String) -> String {

        if name.isEmpty {
            return STRING.errorEnterName
            
        } else if email.isEmpty {
            return STRING.errorEmail
            
        } else if !Validation.isValidEmail(email) {
            return STRING.errorValidEmail
            
        } else if mobile.isEmpty {
            return STRING.errorMobile
            
        } else if !Validation.isValidPhoneNumber(mobile) {
            return STRING.errorValidMobile
            
        } else if password.isEmpty {
            return STRING.errorPassword
            
        } else if password.count < 8 {
            return STRING.errorPasswordCount
            
        } else if !Validation.isValidPassword(password) {
            return STRING.errorValidCreatePassword
            
        } else if confirmPass.isEmpty {
            return STRING.errorConfirmPassword
            
        } else if password != confirmPass {
            return STRING.errorPasswordMismatch
            
        } else {
            return ""
        }
    }
}


//MARK:- Extension for Login Function
extension SignUpVC {
    
    func firebaseRegister(fullName: String, email: String, password:String, contactNumber: String){
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password){authResult, error in
                let id = authResult?.user.uid ?? ""
                if error != nil {createAccount(fullname: fullName, email: email,contactNumber: contactNumber, id: id)}
            }
            func createAccount(fullname: String, email: String, contactNumber: String, id: String) {
                Firestore.firestore().collection(cUser).document(FirebaseAuth.Auth.auth().currentUser?.uid ?? "" ).setData([cEmail: email,
                                                                               cName: fullName,
                                                                              cPhone: contactNumber]){
                    err in
                    if err != nil {
                        Alert.shared.showAlert(message: "Error!!", completion: nil)
                        self.flag = true
                    }else{
                        if let vc = UIStoryboard.main.instantiateViewController(withClass: LoginVC.self){
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
    
}
    }
}
