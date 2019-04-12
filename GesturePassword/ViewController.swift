//
//  ViewController.swift
//  GesturePassword
//
//  Created by JeremyXue on 2019/4/12.
//  Copyright © 2019 JeremyXue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]! {
        didSet {
            configurationButtons()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func configurationButtons() {
        buttons.forEach { (button) in
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.black.cgColor
            button.clipsToBounds = true
            button.setTitle("●", for: .normal)
            button.tintColor = UIColor.black
            button.addTarget(self, action: #selector(touchDragEnter(_:)), for: .touchDragEnter)
            button.addTarget(self, action: #selector(touchDragExit(_:)), for: .touchDragExit)
        }
    }
    
    @objc func touchDragEnter(_ sender: UIButton) {
        print("touchDragEnter")
    }
    
    @objc func touchDragExit(_ sender: UIButton) {
        print("touchDragExit")
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches.first?.location(in: view))
//    }


}

