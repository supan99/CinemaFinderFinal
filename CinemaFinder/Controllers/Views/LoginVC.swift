//
//  LoginVC.swift
//  CinemaFinder

import UIKit
import FirebaseFirestore
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSignUP: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignInAdmin: UIButton!
    @IBOutlet weak var btnApple: UIButton!
  
    var flag: Bool = true
    private let socialLoginManager: SocialLoginManager = SocialLoginManager()
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnSignIn {
            self.flag = false
            let error = self.validation(email: self.txtEmail.text!.trim(),password: self.txtConfirmPassword.text!.trim())
            
            if error.isEmpty {
                self.firebaseLogin(data: self.txtEmail.text?.trim() ?? "", password: self.txtConfirmPassword.text ?? "")
            }else{
                Alert.shared.showAlert(message: error, completion: nil)
            }
            
        }else if sender == btnSignUP {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SignUpVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnSignInAdmin {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: ForgotPasswordVC.self)
            {
            self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
            
        } else if sender == btnApple {
            self.socialLoginManager.performAppleLogin()
        }
        
        
    }
    
    
    func validation(email: String, password: String) -> String {

        if email.isEmpty {
            return STRING.errorEmail
        }else if !Validation.isValidEmail(email) {
            return STRING.errorValidEmail
        } else if password.isEmpty {
            return STRING.errorPassword
        } else if password.count < 8 {
                return STRING.errorPasswordCount
        }
        else {
            return ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnApple.layer.cornerRadius = 10.0
        self.btnSignInAdmin.layer.cornerRadius = 10.0
        self.btnSignIn.layer.cornerRadius = 10.0
        
    //    self.socialLoginManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }

}


//MARK:- Extension for Login Function
extension LoginVC {
    
    func firebaseLogin(data: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: data, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            
            if error != nil {
                Alert.shared.showAlert(message: error?.localizedDescription.description ?? "", completion: nil)
            }else{
                Firestore.firestore().collection(cUser).whereField(cEmail, isEqualTo: data).addSnapshotListener{querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    if snapshot.documents.count != 0 {
                        let data1 = snapshot.documents[0].data()
                        let dataID = snapshot.documents[0].documentID
                        if let fullName: String = data1[cName] as? String, let email: String = data1[cEmail] as? String, let contactNumber: String = data1[cPhone] as? String {
                            GFunction.user = UserModel(docID: dataID, fullName: fullName, email: email, contactNumber: contactNumber)
                            if data == "admin@gmail.com" && password == "12345678" {
                                UIApplication.shared.adminTab()
                            }else{
                                UIApplication.shared.setTab()
                            }
                        }
                    }
                }
            }
        }
    }
}



