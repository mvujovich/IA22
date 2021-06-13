//
//  ModerationCommentTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 13/6/2021.
//

import UIKit

class ModerationCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameText: UILabel!
    
    @IBOutlet weak var commentText: UILabel!
    
    var callBackOnApproveButton: (()->())?
    
    var callBackOnDenyButton: (()->())?
    
    var commenterUserID: String = ""

    static let identifier = "ModerationCommentTableViewCell"
    
    //Helps register cell with table view
    static func nib() -> UINib {
        return UINib(nibName: "ModerationCommentTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated) }
    
    //MARK: - Configure
    func configure(with model: Comment) {
        userNameText.text = model.commenterName
        commentText.text = model.message
        commenterUserID = model.commenterID
    }
    
    //MARK: - Closures
    
    @IBAction func pressedApproveButton(_ sender: Any) {
        self.callBackOnApproveButton?()
    }
    
    @IBAction func pressedDenyButton(_ sender: Any) {
        self.callBackOnDenyButton?()
    }
    
}
