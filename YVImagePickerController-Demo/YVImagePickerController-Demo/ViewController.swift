//
//  ViewController.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/11.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
import YVImagePickerController

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {

    

    var yvTableView: UITableView!
    
    let yvNameOfClasses: Array<Dictionary<String,UIViewController.Type>> = [["单选图片":SingleSelectionImageVC.self],["单选视频":SingleSelectionVideoVC.self],["多选图片":MultiSelectImageVC.self],["多选图片并合成幻灯片":MultiSelectImageToVideoVC.self]]

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        
        self.title = "YVImagePickerController"
        yvTableView = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .plain)
        yvTableView.rowHeight = 60
        yvTableView.delegate = self
        yvTableView.dataSource = self
        yvTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.view.addSubview(yvTableView)
    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yvNameOfClasses.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = yvNameOfClasses[indexPath.row].keys.first
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       let vcT =  yvNameOfClasses[indexPath.row].values.first
        let vc = vcT?.init()
        vc?.title = yvNameOfClasses[indexPath.row].keys.first
       self.navigationController?.pushViewController(vc!, animated: true)
    }
    

}


