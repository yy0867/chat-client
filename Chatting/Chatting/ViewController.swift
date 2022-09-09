//
//  ViewController.swift
//  Chatting
//
//  Created by 김세영 on 2022/09/09.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var field: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        connect()
    }
    
    var socket: URLSessionWebSocketTask!
    
    func connect() {
        self.socket = URLSession.shared.webSocketTask(with: URL(string: "ws://127.0.0.1:8080/echo")!)
        self.listen()
        self.socket.resume()
    }
    
    func listen() {
        self.socket.receive { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.handleMessage(message)
                case .failure(let error):
                    self.presentAlert(error.localizedDescription)
                }
            }
            
            self.listen()
        }
    }
    
    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            text.text = data.description
        case .string(let string):
            text.text = string
        @unknown default:
            text.text = "default"
        }
    }
    
    func presentAlert(_ message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = field.text else { return }
        
        socket.send(.string(text)) { [weak self] error in
            if let error = error {
                self?.presentAlert(error.localizedDescription)
            }
        }
    }
}

