//
//  ViewController.swift
//  testlogin
//
//  Created by Chenran jin on 12/12/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, ServerData {
    @IBOutlet weak var usernameInputBox: UITextField!
    @IBOutlet weak var passwordInputBox: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tokenButton: UIButton!
    
    let serverKey: String = ""
    let tokenURL: String = "https://munpage.com/api/auth"
    var getEventsURL: String = "https://munpage.com/api/get-events?access_token="
    var getUserDataURL:String = "https://munpage.com/api/get-user-data?access_token="
    var token: String = "nil"
    var user_name: String = ""
    var user_id: Int = 0
    var verified: Bool = false
    
    //    MARK: Networking
    func setToken(param: [String:String]) {
        AF.request(self.tokenURL, method: .post, parameters: param).responseJSON {
            response in
            switch response.result {
            case .success:
                let tokenJson: JSON = JSON(response.value ?? "default tooken")
                self.token = tokenJson["access_token"].stringValue
                self.user_id = tokenJson["usre_id"].intValue
                self.tokenButton.isHidden = false
                self.greetingLabel.textColor = .green
                self.greetingLabel.text = "Login Successful!"
            case .failure(let error):
                self.greetingLabel.textColor = .red
                self.greetingLabel.text = "Error with Internet"
                print(error)
            }
        }
    }
    
    func getMyEvents(param: [String:String]) {
        AF.request(self.getEventsURL+token, method: .post, parameters: param).responseJSON {
            response in
            switch response.result{
            case .success:
                if self.verified == true {
                    self.greetingLabel.text! += "以下是你可以申请授权的会议: \n"
                    for event in JSON(response.value ?? "default events")["my_events"] {
                        self.greetingLabel.text! += event.1["name"].stringValue + "\n"
                    }
                }
                
            case .failure(let error):
                self.greetingLabel.textColor = .red
                self.greetingLabel.text = "Error with Internet"
                print(error)
            }
        }
    }
    
    func ifVerified() {
        AF.request(self.getUserDataURL+token, method: .post, parameters:
                    ["server_key": serverKey, "fetch":"user_data", "user_id": 1]
        ).responseJSON {
            response in
            switch response.result{
            case .success:
                let userDataJson: JSON = JSON(response.value ?? "default userData")["user_data"]
                self.user_name = userDataJson["name"].stringValue
                if userDataJson["verified"] == "1" {
                    self.verified = true
                    self.greetingLabel.text = self.user_name + ": 已认证\n"
                } else {
                    self.verified = false
                    self.greetingLabel.text = self.user_name + ": 未认证\n"
                }
            case .failure(let error):
                self.greetingLabel.textColor = .red
                self.greetingLabel.text = "Error with Internet"
                print(error)
            }
        }
    }
    
    // MARK: DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Button Action
    @IBAction func loginButtonPressed(_ sender: Any) {
        let username: String = usernameInputBox.text ?? ""
        let password: String = passwordInputBox.text ?? ""
        let tokenParam = ["server_key": self.serverKey, "username": username, "password": password]
        setToken(param: tokenParam)
    }
    
    @IBAction func tokenButtonPressed(_ sender: Any) {
        self.greetingLabel.textColor = .none
        print(token)
        ifVerified()
        getMyEvents(param: ["server_key": serverKey, "fetch": "my_events"])
    }
    

}

