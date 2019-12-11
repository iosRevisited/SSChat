//
//  ViewController.swift
//  SSChat
//
//  Created by Sai Sandeep on 03/12/19.
//  Copyright © 2019 Sai Sandeep. All rights reserved.
//

import UIKit


class CellIds {
    
    static let senderCellId = "senderCellId"
    
    static let receiverCellId = "receiverCellId"
}


class ViewController: UIViewController {
    
    var bottomHeight: CGFloat {
        guard #available(iOS 11.0, *),
            let window = UIApplication.shared.keyWindow else {
                return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    var items = [String]()
    
    var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextView: InputTextView = {
        let v = InputTextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "SS Chat"
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.setupViews()
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
        tableView.edges([.left, .right, .top], to: self.view, offset: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.receiverCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.senderCellId)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:))))
        
        self.view.addSubview(inputTextView)
        inputTextView.edges([.left, .right], to: self.view, offset: .zero)
        inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        inputTextViewBottomConstraint.isActive = true
        inputTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        inputTextView.delegate = self
        
        for _ in 0...50 {
            items.append(randomString(length: Int.random(in: 2...50)))
        }
        //        tableView.scrollToRow(at: IndexPath(item: 0, section: 49), at: .none, animated: false)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            let oldOffset = self.tableView.contentOffset
            self.inputTextViewBottomConstraint.constant = -keyboardFrame.height + bottomHeight
            UIView.animate(withDuration: keyboardAnimationDuration) {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            self.inputTextViewBottomConstraint.constant = 0
            let oldOffset = self.tableView.contentOffset
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
            }, completion: nil)
        }
    }
    
    @objc func tableViewTapped(recognizer: UITapGestureRecognizer) {
        self.inputTextView.textView.resignFirstResponder()
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section % 2 == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.receiverCellId, for: indexPath) as? CustomTableViewCell {
                cell.selectionStyle = .none
                cell.textView.text = items[indexPath.section]
                cell.showTopLabel = false
                return cell
            }
        }
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.senderCellId, for: indexPath) as? CustomTableViewCell {
                cell.selectionStyle = .none
                cell.textView.text = items[indexPath.section]
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController: InputTextViewDelegate {
    func didPressSendButton(_ text: String, _ sender: UIButton, _ textView: UITextView) {
        print(text)
    }
}
