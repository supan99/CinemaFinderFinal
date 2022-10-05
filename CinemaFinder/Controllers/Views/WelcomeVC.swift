//
//  WelcomeVC.swift
//  CinemaFinder


import UIKit

class WelcomeVC: UIViewController {

    
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnApple: UIButton!
    @IBOutlet weak var btnSignIn: PinkThemeButton!
    @IBOutlet weak var btnSignUp: UIButton!
   
    private func setUpView(){
        self.btnApple.layer.borderColor = UIColor.themePink.cgColor
        self.btnApple.layer.borderWidth = 2.0
        self.btnApple.layer.cornerRadius = 20.0
        self.btnEmail.layer.borderColor = UIColor.themePink.cgColor
        self.btnEmail.layer.borderWidth = 2.0
        self.btnEmail.layer.cornerRadius = 20.0
    }
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnEmail || sender == btnSignUp {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SignUpVC.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if sender == btnSignIn {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: LoginVC.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
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
