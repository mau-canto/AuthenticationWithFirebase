//
//  AuthViewController.swift
//  AutenticationWFirebase
//
//  Created by Mauricio Manuel Canto Romero on 06/02/21.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn

class AuthViewController: UIViewController {

	//Outlets
	@IBOutlet weak var authStackView: UIStackView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var logInButton: UIButton!
	@IBOutlet weak var googleButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
			
		title = "Autenticación"
		
		//Firebase Analytics Event
		Analytics.logEvent("InitScreen", parameters: ["Message":"Integración de Firebase completa"])
		
		//Comprobar la autenticación
		let defaults = UserDefaults.standard
		if let email = defaults.value(forKey: "email") as? String,
		   let provider = defaults.value(forKey: "provider") as? String {
			
			authStackView.isHidden = true
			
			navigationController?.pushViewController(HomeViewController(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
		}
		
		//Google Auth
		GIDSignIn.sharedInstance()?.presentingViewController = self
		GIDSignIn.sharedInstance()?.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		authStackView.isHidden = false
	}
	
	@IBAction func signUpButtonAction(_ sender: Any) {
		
		if let email = emailTextField.text, let password = passwordTextField.text {
			Auth.auth().createUser(withEmail: email, password: password) {
				(result, error) in
				
				self.showHome(result: result, error: error, provider: .basic)
			}
		}
	}
	
	@IBAction func logInButtonAction(_ sender: Any) {
		if let email = emailTextField.text, let password = passwordTextField.text {
			Auth.auth().signIn(withEmail: email, password: password) {
				(result, error) in
				
				self.showHome(result: result, error: error, provider: .basic)
			}
		}
	}

	@IBAction func googleButtonAction(_ sender: Any) {
		GIDSignIn.sharedInstance()?.signOut()
		GIDSignIn.sharedInstance()?.signIn()
		
		
		
	}
	
	private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType) {
		
		if let result = result, error == nil {
			self.navigationController?.pushViewController(HomeViewController(email:result.user.email!, provider: provider), animated: true)
		}else{
			let alertController = UIAlertController(title: "Error", message: "Se ha producido un error de autenticación mediante \(provider.rawValue)", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
			self.present(alertController, animated: true, completion: nil)
		}
		
	}
	
}



extension AuthViewController: GIDSignInDelegate{
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if error == nil && user.authentication != nil {
			let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
			Auth.auth().signIn(with: credential) { (result, error) in
				self.showHome(result: result, error: error, provider: .google)
			}
			
		}
	}

}

