//
//  EditViewController.swift
//  Puranas
//
//  Created by Lucky Clover on 5/29/17.
//  Copyright © 2017 Lucky Clover. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblChapter: UILabel!
    @IBOutlet weak var btnNote: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtView: UITextView!
    
    var isBookmarkMode : Bool = false
    var curCellData : CellData = CellData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.isNavigationBarHidden = false
        
        txtView.text = curCellData.text
        lblChapter.text = "\(curCellData.chapterNo).\(curCellData.contentId)"

        initView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTapsRequired = 1
        imgStar.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    func initView() {
        if (curCellData.isBookmarked == 1) {
            if (curCellData.bmType == "f") {
                imgStar.image = #imageLiteral(resourceName: "bookmarked")
                let range = NSRange(location: 0, length: txtView.attributedText.length)
                let string = NSMutableAttributedString(attributedString: txtView.attributedText)
                let attributes = [NSBackgroundColorAttributeName: Const.highlightColor]
                string.addAttributes(attributes, range: range)
                txtView.attributedText = string
            }
            else if (curCellData.bmType == "p") {
                imgStar.image = #imageLiteral(resourceName: "bookmarksOnly")
                let string = NSMutableAttributedString(attributedString: txtView.attributedText)
                for i in 0..<txtView.attributedText.length {
                    let range1 = NSRange(location: i, length: 1)
                    var attributes = [NSBackgroundColorAttributeName: Const.cellBackColor]
                    if (curCellData.bmData[i] == "1") {
                        attributes = [NSBackgroundColorAttributeName: Const.highlightColor]
                    }
                    string.addAttributes(attributes, range: range1)
                }
                txtView.attributedText = string
            }
        }
        else {
            imgStar.image = #imageLiteral(resourceName: "bookmarksOnly")
            let range = NSRange(location: 0, length: txtView.attributedText.length)
            let string = NSMutableAttributedString(attributedString: txtView.attributedText)
            let attributes = [NSBackgroundColorAttributeName: Const.cellBackColor]
            string.addAttributes(attributes, range: range)
            txtView.attributedText = string
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        mainVC?.initSectionData()
    }
    
    func setBookmark() {

        if (txtView.selectedRange.length != 0) {
            let range = txtView.selectedRange
            let db = DBManager()
            curCellData.bmData = db.insertBookmark(data: curCellData, startPos: range.location, bmlength: range.length, totalLength: txtView.attributedText.length, type: "p")
            
            if curCellData.bmData.range(of: "1") == nil {
                curCellData.isBookmarked = 0
            }
            else {
                curCellData.isBookmarked = 1
                if curCellData.bmData.range(of: "0") == nil {
                    curCellData.bmType = "f"
                }
                else {
                    curCellData.bmType = "p"
                }
            }
            
            initView()
        }
    }
    
    func tapped() {
        if (curCellData.isBookmarked == 0) {
            imgStar.image = #imageLiteral(resourceName: "bookmarked")
            curCellData.isBookmarked = 1
            
            curCellData.bmType = "f"
            var str = ""
            for _ in 0..<txtView.attributedText.length {
                str += "1"
            }
            curCellData.bmData = str
            
            let range = NSRange(location: 0, length: txtView.attributedText.length)
            let string = NSMutableAttributedString(attributedString: txtView.attributedText)
            let attributes = [NSBackgroundColorAttributeName: Const.highlightColor]
            string.addAttributes(attributes, range: range)
            txtView.attributedText = string
            
            let db = DBManager()
            db.insertBookmark(data: curCellData, startPos: 0, bmlength: 0, totalLength: txtView.attributedText.length, type: "f")
        }
        else {
            if (curCellData.bmType == "f") {
                imgStar.image = #imageLiteral(resourceName: "bookmarksOnly")
                curCellData.isBookmarked = 0
                
                let range = NSRange(location: 0, length: txtView.attributedText.length)
                let string = NSMutableAttributedString(attributedString: txtView.attributedText)
                let attributes = [NSBackgroundColorAttributeName: Const.cellBackColor]
                string.addAttributes(attributes, range: range)
                txtView.attributedText = string
                
                let db = DBManager()
                db.deleteBookmark(data: curCellData)
            }
            else if (curCellData.bmType == "p") {
                imgStar.image = #imageLiteral(resourceName: "bookmarked")
                curCellData.isBookmarked = 1
                
                curCellData.bmType = "f"
                var str = ""
                for _ in 0..<txtView.attributedText.length {
                    str += "1"
                }
                curCellData.bmData = str
                
                let range = NSRange(location: 0, length: txtView.attributedText.length)
                let string = NSMutableAttributedString(attributedString: txtView.attributedText)
                let attributes = [NSBackgroundColorAttributeName: Const.highlightColor]
                string.addAttributes(attributes, range: range)
                txtView.attributedText = string
                
                let db = DBManager()
                db.insertBookmark(data: curCellData, startPos: 0, bmlength: 0, totalLength: txtView.attributedText.length, type: "f")
            }
        }
        
    }
    
    @IBAction func onNoteTapped(_ sender: Any) {
    }
    
    @IBAction func onBookmarkTapped(_ sender: Any) {
        if (isBookmarkMode == false) {
            isBookmarkMode = true
            self.txtView.isSelectable = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.btnNote.alpha = 0.0
                self.btnBack.alpha = 0.0
            }, completion: nil)
        }
        else {
            isBookmarkMode = false
            self.txtView.isSelectable = false
            setBookmark()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.btnNote.alpha = 1.0
                self.btnBack.alpha = 1.0
            }, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}