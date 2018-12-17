//
//  MainViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 16/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    var allClassViewController: AllClassesViewController!
    var personClassViewController: PersonClassesViewController!
    var controllers = [UIViewController]()
    
    @IBOutlet var navView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = self.navView
        
        //获取到嵌入的UIPageViewController
        pageViewController = self.children.first as! UIPageViewController
        
        //根据Storyboard ID来创建一个View Controller
        allClassViewController = storyboard?.instantiateViewController(withIdentifier: "allClassseView") as? AllClassesViewController
        personClassViewController = storyboard?.instantiateViewController(withIdentifier: "personClassesView") as? PersonClassesViewController
        
        //设置pageViewController的数据源代理为当前Controller
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        //手动为pageViewController提供提一个页面
        pageViewController.setViewControllers([allClassViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        //把页面添加到数组中
        controllers.append(allClassViewController)
        controllers.append(personClassViewController)
    }
    
    @IBAction func allClassesAction(_ sender: Any) {
        
        pageViewController.setViewControllers([allClassViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    @IBAction func personClassesAction(_ sender: Any) {
        pageViewController.setViewControllers([personClassViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension MainViewController:UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    //返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PersonClassesViewController.self) {
            return allClassViewController
        }
        else if viewController.isKind(of: AllClassesViewController.self) {
            return personClassViewController
        }
        return nil
        
    }
    
    //返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PersonClassesViewController.self) {
            return allClassViewController
        }
        else if viewController.isKind(of: AllClassesViewController.self) {
            return personClassViewController
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
}
