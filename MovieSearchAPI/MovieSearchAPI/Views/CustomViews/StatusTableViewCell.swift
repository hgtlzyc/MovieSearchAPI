//
//  StatusTableViewCell.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/7/21.
//

import UIKit

class StatusTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    
    func updateLabelWithText(_ text: String) {
        self.statusLabel.text = text
    }
}
