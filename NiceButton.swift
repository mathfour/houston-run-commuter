//
//  NiceButton.swift
//  Houston Run Commuter
//
//  Created by Bon Crowder on 8/26/17.
//  Copyright © 2017 Bon Crowder. All rights reserved.
//

import UIKit

@IBDesignable
class NiceButton: UIButton {

  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      self.layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      self.layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.white {
    didSet {
      self.layer.borderColor = borderColor.cgColor
    }
  }
  
}
