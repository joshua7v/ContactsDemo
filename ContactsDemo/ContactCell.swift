//
//  ContactCell.swift
//  ContactsDemo
//
//  Created by Joshua on 1/29/16.
//  Copyright © 2016 SigmaStudio. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    var contact: Contact! {
        didSet {
            nameLabel.text = contact.fullName
            if let birth = contact.birthday {
                birthdayLabel.text = "\(birth.year) - \(birth.month) - \(birth.day)"
            } else {
                birthdayLabel.text = "Unknow Birthday."
            }
        }
    }
    
    private var nameLabel: UILabel!
    private var birthdayLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        
        nameLabel = UILabel()
        contentView.addSubview(nameLabel)
        
        birthdayLabel = UILabel()
        contentView.addSubview(birthdayLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: nameLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: nameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: nameLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: nameLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 0.5, constant: 0)
        ])
        
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: birthdayLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: birthdayLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: birthdayLabel, attribute: .Top, relatedBy: .Equal, toItem: nameLabel, attribute: .Bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: birthdayLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: -10)
            ])
    }
}
