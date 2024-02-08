//
//  HistoryTableViewCell.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Iakovlev on 07.02.2024.
//

import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var expressionlabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!
    
    func configure(with expression: String, result: String) {
        expressionlabel.text = expression
        resultLabel.text = result
    }
    
    
    
    
    
    
}
