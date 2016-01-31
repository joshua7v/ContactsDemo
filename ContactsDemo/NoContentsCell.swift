//
//  NoContentsCell.swift
//  ContactsDemo
//
//  Created by Joshua on 1/29/16.
//  Copyright © 2016 SigmaStudio. All rights reserved.
//

import UIKit

class NoContentsCell: UITableViewCell {

    var msg: String!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureViews() {
        
        let msgLabel = UILabel()
        contentView.addSubview(msgLabel)
        
        msgLabel.text = "No Contents"
        msgLabel.textAlignment = .Center
        
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: msgLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: msgLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: msgLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: msgLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        ])
    }

}
