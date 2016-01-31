//
//  ViewController.swift
//  ContactsDemo
//
//  Created by Joshua on 1/29/16.
//  Copyright © 2016 SigmaStudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var contacts: [Contact]!
    
    let contactManager = ContactManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureData()
        configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func performCreateContact(sender: UIBarButtonItem) {
        
        contactManager.requestAccessWithCompletion { (granted, error) -> Void in
            
            guard granted else {
                print("Can not get access to contact.")
                return
            }
            
            let alert = UIAlertController(title: "Add Contact", message: "", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "First Name"
            })
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Last Name"
            })
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Phone Number"
            })
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Email Address"
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action) -> Void in
                let firstName = alert.textFields![0].text ?? ""
                let lastName = alert.textFields![1].text ?? ""
                let phoneNumber = alert.textFields![2].text ?? ""
                let emailAddress = alert.textFields![3].text ?? ""
                
                let c = Contact(firstName: firstName, lastName: lastName, emailAddress: EmailAddress(label: "email", value: emailAddress), phoneNumber: PhoneNumber(label: "phone", value: phoneNumber))
                self.contactManager.createContact(c, completionHandler: { (success, error) -> Void in
                    if success {
                        self.contactManager.getContacts(matchingName: c.fullName, completionHandler: { (contacts, error) -> Void in
                            self.contacts = contacts ?? []
                            self.tableView.reloadData()
                        })
                    }
                })
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func performFetchByName(sender: UIBarButtonItem) {
        
        contactManager.requestAccessWithCompletion { (granted, error) -> Void in
            
            guard granted else {
                print("Can not get access to contact.")
                return
            }
            
            self.showMessage("Fetch Contacts by ... (name)", confirmHandler: { (text) -> Void in
                
                self.contactManager.getContacts(matchingName: text, completionHandler: { (contacts, error) -> Void in
                    self.contacts = contacts ?? []
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    @IBAction func performFetchByBirthday(sender: UIBarButtonItem) {
        
        contactManager.requestAccessWithCompletion { (granted, error) -> Void in
            
            guard granted else {
                print("Can not get access to contact.")
                return
            }
            
            self.showMessage("Fetch Contacts by ... (birthday-month)", confirmHandler: { (text) -> Void in
                
                self.contactManager.getContacts(matchingBirthMonth: Int(text)!, completionHandler: { (contacts, error) -> Void in
                    self.contacts = contacts ?? []
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    private func configureViews() {
        tableView.registerClass(NoContentsCell.self, forCellReuseIdentifier: CellIds.NoContentsCell)
        tableView.registerClass(ContactCell.self, forCellReuseIdentifier: CellIds.ContactCell)
        tableView.tableFooterView = UIView()
    }
    
    private func configureData() {
        
        contacts = []
    }
    
    private func showMessage(message: String, confirmHandler: ((text: String) -> Void)?) {
        
        let alert = UIAlertController(title: "Fetch", message: message, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action) -> Void in
            let text = alert.textFields!.first!.text!
            if let block = confirmHandler {
                block(text: text)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard contacts.count != 0 else {
            return 1
        }
        
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard contacts.count != 0 else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIds.NoContentsCell, forIndexPath: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIds.ContactCell, forIndexPath: indexPath) as! ContactCell
        let contact = contacts[indexPath.row]
        cell.contact = contact
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard contacts.count != 0 else {
            return 77
        }
        
        return 66
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

struct CellIds {
    static let ContactCell = "ContactCellId"
    static let NoContentsCell = "NoContentsCellId"
}
