//
//  ViewController.swift
//  DoodleKit
//
//  Created by popwarsweet on 06/02/2017.
//  Copyright (c) 2017 popwarsweet. All rights reserved.
//

import UIKit
import DoodleKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let doodleView = DoodleViewController()
        doodleView.view.backgroundColor = .gray
//        doodleView.state = .drawing
        doodleView.textEditingInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        doodleView.willMove(toParentViewController: self)
        doodleView.view.frame = self.view.bounds
        self.view.addSubview(doodleView.view)
        self.addChildViewController(doodleView)
        doodleView.didMove(toParentViewController: self)
    }
}

