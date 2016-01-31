//
//  ContactsManager.swift
//  ContactsDemo
//
//  Created by Joshua on 1/29/16.
//  Copyright © 2016 SigmaStudio. All rights reserved.
//

import UIKit
import Contacts

final class ContactManager {
    
    /// create a contact and save it
    func createContact(contact: Contact, completionHandler: ((success: Bool, error: NSError?) -> Void)) {
        let newContact = CNMutableContact()
        
        newContact.givenName = contact.firstName
        newContact.familyName = contact.lastName
        
        newContact.emailAddresses = contact.emailAddresses.map { (emailAddress) -> CNLabeledValue in
            return CNLabeledValue(label: emailAddress.label, value: emailAddress.value)
        }
        
        newContact.phoneNumbers = contact.phoneNumbers.map({ (phoneNumber) -> CNLabeledValue in
            return CNLabeledValue(label: phoneNumber.label, value: CNPhoneNumber(stringValue: phoneNumber.value))
        })
        
        newContact.birthday = contact.birthday
        
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(newContact, toContainerWithIdentifier: nil)
            try contactStore.executeSaveRequest(saveRequest)
            
            completionHandler(success: true, error: nil)
        } catch {
            completionHandler(success: false, error: NSError.ContactSaveFailedError)
        }
    }
    
    /// get contacts matching name
    func getContacts(matchingName matchingName: String, completionHandler: ((contacts: [Contact]?, error: NSError?) -> Void)) {
        
        guard (matchingName as NSString).length != 0 else { return }
        let predicate = CNContact.predicateForContactsMatchingName(matchingName)
        //                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey]
        
        var contacts = [CNContact]()
        
        do {
            contacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: normalKeys)
            
            let cs = contactsArrayFromCNContactsArray(contacts)
            
            if contacts.count == 0 {
                completionHandler(contacts: nil, error: NSError.ContactNotFoundError)
            }
            
            completionHandler(contacts: cs, error: nil)
        } catch let error as NSError {
            completionHandler(contacts: nil, error: error)
        }
    }
    
    /// get contacts matching brithday month
    func getContacts(matchingBirthMonth matchingBirthMonth: Int, completionHandler: ((contacts: [Contact]?, error: NSError?) -> Void)) {
        
        var contacts = [CNContact]()
        
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: normalKeys)) { (contact, pointer) -> Void in
                
                if contact.birthday != nil && contact.birthday!.month == matchingBirthMonth {
                    contacts.append(contact)
                }
            }
            
            if contacts.count == 0 {
                completionHandler(contacts: nil, error: NSError.ContactNotFoundError)
            } else {
                let cs = contactsArrayFromCNContactsArray(contacts)
                completionHandler(contacts: cs, error: nil)
            }
            
        } catch let error as NSError {
            completionHandler(contacts: nil, error: error)
        }
    }
   
    /// request access for user contact
    func requestAccessWithCompletion(completionHandler: (granted: Bool, error: NSError?) -> Void) {
        
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(granted: true, error: nil)
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(granted: access, error: nil)
                } else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        completionHandler(granted: false, error: NSError.ContactUserDeniedError)
                    }
                }
            })
            
        default:
            completionHandler(granted: false, error: nil)
        }
        
        //        if !UIDevice.iOS9 {
        //
        //            let status = ABAddressBookGetAuthorizationStatus()
        //
        //            if status == .NotDetermined {
        //                let addressBook = ABAddressBookCreateWithOptions(nil, nil)
        //                ABAddressBookRequestAccessWithCompletion(addressBook.takeRetainedValue(), { (granted, error) -> Void in
        //                    if granted {
        //                        completionHandler(granted: true, error: nil)
        //                    } else {
        //                        completionHandler(granted: false, error: error)
        //                    }
        //                })
        //            }
        //        }
    }
    
    
    // MARK: - private
    private static let ContactDomain = "Seraph.Contact"
    let contactStore = CNContactStore()
    
    private let normalKeys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
    
    /// convert CNContact to Contact
    private func contactsArrayFromCNContactsArray(CNContactsArray: [CNContact]) -> [Contact] {
        
        return CNContactsArray.map { (contact) -> Contact in
            
            let avatarData = contact.imageData ?? NSData()
            let avatar = UIImage(data: avatarData)
            
            let c = Contact(
                firstName: contact.givenName,
                lastName: contact.familyName,
                emailAddresses: contact.emailAddresses.map({ (labelValue) -> EmailAddress in
                    let email = EmailAddress(
                        label: CNLabeledValue.localizedStringForLabel(labelValue.label),
                        value: CNLabeledValue.localizedStringForLabel(labelValue.value as! String)
                    )
                    return email
                }),
                phoneNumbers: contact.phoneNumbers.map({ (labelValue) -> PhoneNumber in
                    let phone = PhoneNumber(
                        label: CNLabeledValue.localizedStringForLabel(labelValue.label),
                        value: CNLabeledValue.localizedStringForLabel((labelValue.value as! CNPhoneNumber).stringValue)
                    )
                    return phone
                }),
                avatar: avatar,
                birthday: contact.birthday
            )
            return c
        }
    }
    
}

struct Contact {
    
    var firstName: String
    var lastName: String
    var fullName: String {
        let c = CNMutableContact()
        c.givenName = firstName
        c.familyName = lastName
        return CNContactFormatter.stringFromContact(c, style: .FullName) ?? ""
    }
    var emailAddresses: [EmailAddress]
    var phoneNumbers: [PhoneNumber]
    var avatar: UIImage?
    var birthday: NSDateComponents?
    
    init(firstName: String, lastName: String, emailAddresses: [EmailAddress], phoneNumbers: [PhoneNumber], avatar: UIImage?, birthday: NSDateComponents?) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddresses = emailAddresses
        self.phoneNumbers = phoneNumbers
        self.avatar = avatar
        self.birthday = birthday
    }
    
    init(firstName: String, lastName: String, emailAddress: EmailAddress, phoneNumber: PhoneNumber, avatar: UIImage? = nil, birthday: NSDateComponents? = nil) {
        
        self.init(firstName: firstName, lastName: lastName, emailAddresses: [emailAddress], phoneNumbers: [phoneNumber], avatar: avatar, birthday: birthday)
    }
}

struct LabeledValue {
    
    var label: String
    var value: String
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

typealias EmailAddress = LabeledValue
typealias PhoneNumber = LabeledValue

// MARK: - error
enum ContactErrorCode: Int {
    case NotFound = 0
    case UserDenied = 1
    case SaveFailed = 2
}

enum ContactError: String {
    case NotFound = "No Contacts Found!"
    case UserDenied = "Denied By User!"
    case SaveFailed = "Contact Save Failed!"
}

extension NSError {
    
    /// no contact found error
    static var ContactNotFoundError: NSError {
        return NSError(domain: ContactManager.ContactDomain, code: ContactErrorCode.NotFound.rawValue, userInfo: [kErrorKey: ContactError.NotFound.rawValue])
    }
    
    /// user denied error
    static var ContactUserDeniedError: NSError {
        return NSError(domain: ContactManager.ContactDomain, code: ContactErrorCode.UserDenied.rawValue, userInfo: [kErrorKey: ContactError.UserDenied.rawValue])
    }
    
    /// user denied error
    static var ContactSaveFailedError: NSError {
        return NSError(domain: ContactManager.ContactDomain, code: ContactErrorCode.SaveFailed.rawValue, userInfo: [kErrorKey: ContactError.SaveFailed.rawValue])
    }
}

public let kErrorKey: String = "error"