//
//  ViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 5/31/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, NVActivityIndicatorViewable, ControllerType {
    
    typealias ViewModelType = LoginControllerViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    // MARK: - UI
    @IBOutlet weak var loginContainerView: MBRHEBorderView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var QAView: UIView!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var remberMeLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    @IBOutlet weak var usernameView: MBRHEBorderView!
    
    @IBOutlet weak var passwordView: MBRHEBorderView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    var isShowPassword = false
    var noData : NoDataView!
    
    var debuggModeCount : Int = 1
    var timer = Timer()
    
    @IBOutlet weak var profileIconImgV: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //isRememberPassword = true
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        profileIconImgV.addGestureRecognizer(tap)
        profileIconImgV.isUserInteractionEnabled = true
        
        setupView()

    }
    
    
    func setupView()  {
        defaultUISetUp()
        localizationSetUp()
        
        if(Common.isConnectedToNetwork() == false)
        {
            notAvailable(serverError: false)
        }
        configure(with: viewModel)

    }
    
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer)
    {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(LoginViewController.updateQAModeCount), userInfo: nil, repeats: false)
        
        if debuggModeCount == 5
        {
            Common.showToaster(message: "enable_QA_Mode".ls)
            self.QAView.isHidden = false
            self.switchBtn.isHidden = false
            timer.invalidate()
        }
        
        if Common.userDefaults.getDebugMode()
        {
            self.switchBtn.isOn = true
        }
        else
        {
            self.switchBtn.isOn = false
        }
        debuggModeCount = debuggModeCount + 1
    }
    private func defaultUISetUp()
    {
        //Temp Hardcode value
        if Common.currentLanguageArabic(){
           if (Common.userDefaults.getIsRemember()){
            let prodUserDataAvailable =  Common.userDefaults.getSavedLoggedUserName(environment: "Prod")
            if let userName = prodUserDataAvailable["UserName"]{
                self.userNameTextField.text = userName
                self.passwordTextField.text = prodUserDataAvailable["Password"]
            }
            else{
                self.userNameTextField.text = ""
                self.passwordTextField.text = ""
            }
            }
           else{
            self.userNameTextField.text = ""
            self.passwordTextField.text = ""
            }
            switchBtn.isHidden = true
            QAView.isHidden = true
            self.switchBtn.isOn = false
        }
        else{
            if (Common.userDefaults.getIsRemember()){
            let qaUserDataAvailable =  Common.userDefaults.getSavedLoggedUserName(environment: "QA")
                if let userName = qaUserDataAvailable["UserName"]{
                    self.userNameTextField.text = userName
                    self.passwordTextField.text = qaUserDataAvailable["Password"]
                }
                else{
                    self.userNameTextField.text = ""
                    self.passwordTextField.text = ""
                }
            }
            else{
                self.userNameTextField.text = ""
                self.passwordTextField.text = ""}
            switchBtn.isHidden = false
            QAView.isHidden = false
            self.switchBtn.isOn = true}
        self.signInButton.contentEdgeInsets.right = 0.1
        rememberSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    
    private func localizationSetUp() {
        
        self.userNameTextField.placeholder = "username_tf".ls
        self.passwordTextField.placeholder = "password_tf".ls
        self.signInButton.setTitle("login_btn".ls, for: .normal)
        remberMeLbl.text = "remember_me".ls
        if Common.currentLanguageArabic()
        {
            self.view.transform  = Common.arabicTransform
            self.view.toArabicTransform()
            headerView.transform = Common.arabicTransform
            signInButton.titleLabel?.textAlignment = .center
            remberMeLbl.textAlignment = .right
        }
        else
        {
            self.view.transform  = Common.englishTransform
            self.view.toEnglishTransform()
            headerView.transform = Common.englishTransform
        }
        print(self.view.transform)
    }
    
    private func environmentUIDesign() {
        
        if Common.userDefaults.getDebugMode() {
            QAView.isHidden = false
            switchBtn.isOn = true
            switchBtn.onTintColor = UIColor(red: 36/255, green: 98/255, blue: 158/255, alpha: 1.0)
        }else {
            QAView.isHidden = true
            switchBtn.isOn = false
            switchBtn.onTintColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1.0)
        }
    }
    
    
    // MARK: - Functions
    func configure(with viewModel: ViewModelType) {
        //        self.gotoDashBoardView()
        
        let nameValidation = self.userNameTextField
            .rx.text
            .map({!($0?.isEmptyString())!})
            .share(replay: 1)
        
        let passwordValidation = self.passwordTextField
            .rx.text
            .map({!($0?.isEmptyString())!})
            .share(replay: 1)
        
        let enableButton = Observable.combineLatest(nameValidation, passwordValidation) { $0 || $1 }
            .share(replay: 1)
        
        enableButton
            .bind(to: signInButton.rx.valid)
            .disposed(by: disposeBag)
        
        userNameTextField.rx.text.asObservable()
            .ignoreNil()
            .subscribe(viewModel.input.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.asObservable()
            .ignoreNil()
            .subscribe(viewModel.input.password)
            .disposed(by: disposeBag)
        
        rememberSwitch.rx.isOn.bind(to: viewModel.input.rememberMeVal)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signInDidTap)
            .disposed(by: disposeBag)
        
//        btnShowPassword.rx.tap.asObservable()
//            .subscribe(onNext:{[weak self] _ in
//                if (self?.isShowPassword)! {
//                    self?.isShowPassword = false
//                    self?.passwordTextField.isSecureTextEntry = true
//                } else {
//                    self?.isShowPassword = true
//                    self?.passwordTextField.isSecureTextEntry = false
//                }
//            })
//            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                // perform action you want to perform
                if self?.userNameTextField.text == "" && self?.passwordTextField.text == "" {
                    // either textfield 1 or 2's text is empty
                    self?.uiUpdates(CurrentValue: "Both")
                    Common.showToaster(message: "empty_username_and_password".ls)
                }
               else if self?.userNameTextField.text == ""{
                  self?.uiUpdates(CurrentValue: "User")
                    Common.showToaster(message: "empty_username".ls)
                }
                else if self?.passwordTextField.text == ""{
                    self?.uiUpdates(CurrentValue: "Password")
                    Common.showToaster(message: "empty_password".ls)
                    }
                else{
                self?.view.endEditing(true)
                self?.showActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.stopAnimating()
                let errorMessage = (error as NSError).domain
                Common.showToaster(message: errorMessage)
                self.notAvailable(serverError: true)
            })
            .disposed(by: disposeBag)
        
        
        if(Common.isConnectedToNetwork() == true)
        {
            
            viewModel.output.loginResultObservable
                .debounce(.milliseconds(Int(0.0005)), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (user) in
                    self.stopAnimating()
                    print("Userlogin service response\(user.statusCode)")
                    if user.statusCode == 200
                    {
                        print(user)
                        let currentDateTime = Date()
                        let dateStr = Common.convertDateToString(date: currentDateTime)
                        Common.userDefaults.setLoginUserTime(_time:dateStr)
                        Common.userDefaults.saveUserModel(user)
                        Common.userDefaults.setIsRemember(isRemember: self.rememberSwitch.isOn)
                        var currentEnvironment :String = ""
                        if (Common.userDefaults.getDebugMode())
                        {
                            currentEnvironment = "QA"
                        }
                        else
                        {
                            currentEnvironment = "Prod"
                        }
                    Common.userDefaults.saveLoggedUserName(userName:self.userNameTextField.text!,environment:currentEnvironment,password:self.passwordTextField.text!)
                     //   Common.userDefaults.savePassword(password: self.passwordTextField.text!)
                        
                        if (Common.userDefaults.getIsRemember() && (Common.userDefaults.getDebugMode())){
                            Common.userDefaults.saveLoggedUserName(userName:"",environment:"Prod",password:"")

                        }
                        
                        self.setEnvironmentValue(qaEnable: self.switchBtn.isOn)
                        self.gotoDashBoardView()
                    }else if user.statusCode == 401 {
                        
                        self.uiUpdates(CurrentValue:"Both")
                        let msgDict = Common.convertToDictionary(text: user.message)
                        Common.showToaster(message: msgDict?["error_description"] as? String ?? "Invalid login")
                    }
                    else
                    {
                        if !user.message.isEmpty
                        {
                            Common.showToaster(message: user.message)
                        }
                        if(Common.isConnectedToNetwork() == false)
                        {
                            self.notAvailable(serverError: false)
                            Common.showToaster(message: "no_Internet".ls)
                        }
                        else
                        {
                            self.notAvailable(serverError: true)
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
        else
        {
            self.notAvailable(serverError: false)
            Common.showToaster(message: "no_Internet".ls)
        }
        
    }
    
    func uiUpdates(CurrentValue:String){
        if (CurrentValue == "Both")
        {
            self.usernameView.layer.borderWidth = 1
            self.passwordView.layer.borderWidth = 1
            
            self.usernameView.layer.borderColor = UIColor(red: 240/255, green: 68/255, blue: 68/255, alpha: 1).cgColor
            self.passwordView.layer.borderColor = UIColor(red: 240/255, green: 68/255, blue: 68/255, alpha: 1).cgColor
        }else if (CurrentValue == "User")
        {
            self.usernameView.layer.borderWidth = 1
            self.usernameView.layer.borderColor = UIColor(red: 240/255, green: 68/255, blue: 68/255, alpha: 1).cgColor
            self.passwordView.layer.borderColor = UIColor.clear.cgColor
        }
        else
        {
            self.passwordView.layer.borderWidth = 1
            self.passwordView.layer.borderColor = UIColor(red: 240/255, green: 68/255, blue: 68/255, alpha: 1).cgColor
            self.usernameView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func tempNavigation() {
        let satelliteVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSatellitePhotoController")
        self.navigationController?.pushViewController(satelliteVC!, animated: true)

    }
    
    private func setEnvironmentValue(qaEnable:Bool) {
        
        let domainType: APIDomainType = qaEnable ? .QA : .Production
        APICommunicationURLs.setApplicationEnviroment(_domainType: domainType)
        Common.userDefaults.saveDebugMode(qaEnable)
        Common.setAPPKeyAndSeacretDebuggMode(qaEnable)
        SharedResources.sharedInstance.loadAllVariables(isFromAppDelegate: false)
        
    }
    
    func gotoDashBoardView()  {
        SharedResources.sharedInstance.isRefreshNeeded = true

        let contractsService = ContractsService()
        let dashboardViewModel = DashboardViewModel(contractsService)
        let dashboardViewController = DashboardViewController.create(with: dashboardViewModel) as? DashboardViewController
        
        let navigationController = UINavigationController(rootViewController: dashboardViewController!)
        navigationController.navigationBar.isHidden = true
        Common.appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        Common.appDelegate.window?.rootViewController = navigationController
        SharedResources.sharedInstance.currentRootTag =  1
        Common.appDelegate.window?.makeKeyAndVisible()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("ViewWillAppear")
        //isShowPassword = false
      //  configure(with: viewModel)
        
        btnShowPassword.rx.tap.asObservable()
        .subscribe(onNext:{[weak self] _ in
            if (self?.isShowPassword)! {
                self?.isShowPassword = false
                self?.passwordTextField.isSecureTextEntry = true
            } else {
                self?.isShowPassword = true
                self?.passwordTextField.isSecureTextEntry = false
            }
        })
        .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showActivityIndicator() {
        let size = CGSize(width: 70, height: 70)
        startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
    }
    
    func notAvailable(serverError : Bool)
    {
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y:0, width: (self.loginContainerView?.frame.size.width)!,  height:(self.loginContainerView?.frame.size.height)!)
        
        if serverError == true {
            noData.setLayout(serverError:true,Yposition :5)
        }else {
            noData.setLayout(noNetwork:true,Yposition :5)
        }
         noData.tag = 1111
        noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        self.loginContainerView?.addSubview(noData)
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true)
        {
            for views in self.loginContainerView.subviews{
                if views.tag == 1111{
                    views .removeFromSuperview()
                }
            }
          //  self.loginContainerView.willRemoveSubview((noData))
            
//            noData.removeFromSuperview()
//            signInButton.sendActions(for: .touchUpInside)
        }
        else{
            self.notAvailable(serverError: false)
            Common.showToaster(message: "no_Internet".ls)

        }
    }
    
    //MARK: - UIButton Action

    @IBAction func profileBtnTapped(_ sender: Any) {
        print("profileBtnTapped")
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(LoginViewController.updateQAModeCount), userInfo: nil, repeats: false)
        
        if debuggModeCount == 5
        {
            Common.showToaster(message: "enable_QA_Mode".ls)

            self.QAView.isHidden = false
            self.switchBtn.isHidden = false
            timer.invalidate()
        }
        debuggModeCount = debuggModeCount + 1
    }
    
    @objc func updateQAModeCount() {
        print(debuggModeCount)
        debuggModeCount = 1
        timer.invalidate()
    }
    
    @IBAction func switchPressed(_ sender: Any)
    {
        
        if switchBtn.isOn
        {
            Common.userDefaults.saveDebugMode(true)
            Common.setAPPKeyAndSeacretDebuggMode(true)
            APICommunicationURLs.setApplicationEnviroment(_domainType: .QA)
            Localization.storeCurrentLanguage("en")
            switchBtn.onTintColor = UIColor(red: 36/255, green: 98/255, blue: 158/255, alpha: 1.0)
            
            setupView()

        }
        else {
            Common.setAPPKeyAndSeacretDebuggMode(false)
            Common.userDefaults.saveDebugMode(false)
            APICommunicationURLs.setApplicationEnviroment(_domainType: .Production)
            switchBtn.onTintColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1.0)
            Localization.storeCurrentLanguage("ar")
            setupView()
        }
    }
}

extension LoginViewController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
        controller.viewModel = viewModel
        return controller
    }
    
}

extension Reactive where Base: UIView {
    var valid: AnyObserver<Bool> {
        return Binder(base, binding: { (thisVw: UIView, valid: Bool) in
            thisVw.alpha = 0.5
            (thisVw as! UIButton).isEnabled = false
            if valid {
                thisVw.alpha = 1.0
                (thisVw as! UIButton).isEnabled = true
            }
        }).asObserver()
    }
}
