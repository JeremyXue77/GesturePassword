//
//  ViewController.swift
//  GesturePassword
//
//  Created by JeremyXue on 2019/4/12.
//  Copyright © 2019 JeremyXue. All rights reserved.
//

import UIKit

enum GesturePasswordType: Int {
    case setting = 0
    case unlock = 1
}

class ViewController: UIViewController {
    
    private var currentPoint: CGPoint?
    private var gesturePasswordType = GesturePasswordType.setting
    private var password = [Int]()
    private var selectedPassword = [Int]()
    private var lineLayers = [CAShapeLayer]()
    private var row = 3
    private let buttonTag = -1
    private let cellID = "cell"
    private var moveLayer: CAShapeLayer?
    
    @IBOutlet weak var gestureCollectionView: GestureCollectionView!
    
    @IBAction func changeRows(_ sender: UIStepper) {
        let alert = UIAlertController(title: "", message: "Your password will be cleared. Do you want to continue?", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { [weak self](_) in
            self?.row = Int(sender.value)
            self?.password = []
            self?.gestureCollectionView.reloadSections(IndexSet(integer: 0))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        guard let type = GesturePasswordType(rawValue: sender.selectedSegmentIndex) else { return }
        gesturePasswordType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureCollectionView.dataSource = self
        gestureCollectionView.delegate = self
        gestureCollectionView.gestureDelegate = self
        gestureCollectionView.isUserInteractionEnabled = false
    }
    
    private func drawLine(to point: CGPoint) {
        if let currentPoint = currentPoint {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = gestureCollectionView.bounds
            shapeLayer.position = gestureCollectionView.center
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = 3
            shapeLayer.strokeColor = UIColor.green.cgColor
            let path = UIBezierPath()
            path.move(to: currentPoint)
            path.addLine(to: point)
            shapeLayer.path = path.cgPath
            shapeLayer.lineCap = .round
            view.layer.addSublayer(shapeLayer)
            lineLayers.append(shapeLayer)
        }
        currentPoint = point
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesEnded(touches, with: event)
    }
    
    func showMessageAlert(message: String) {
        let alert = UIAlertController(title: "Gesture Password", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self](_) in
            self?.lineLayers.forEach { (layer) in
                layer.removeFromSuperlayer()
            }
            self?.selectedPassword.removeAll()
            self?.gestureCollectionView.reloadSections(IndexSet(integer: 0))
            self?.currentPoint = nil
            self?.moveLayer?.removeFromSuperlayer()
            self?.moveLayer = nil
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row * row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.tag = indexPath.row
        cell.layer.cornerRadius = cell.bounds.height / 2
        cell.layer.borderColor = !selectedPassword.contains(indexPath.row) ? UIColor.white.cgColor : UIColor.green.cgColor
        cell.layer.borderWidth = 3
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return width
    }
}

extension ViewController: GestureCollectionViewDelegate {
    
    func move(point: CGPoint) {
        if let currentPoint = currentPoint {
            if moveLayer == nil {
                moveLayer = CAShapeLayer()
                view.layer.addSublayer(moveLayer!)
            }
            moveLayer?.frame = gestureCollectionView.bounds
            moveLayer?.position = gestureCollectionView.center
            moveLayer?.fillColor = nil
            moveLayer?.lineWidth = 3
            moveLayer?.strokeColor = UIColor.green.cgColor
            let path = UIBezierPath()
            path.move(to: currentPoint)
            path.addLine(to: point)
            moveLayer?.path = path.cgPath
            moveLayer?.lineCap = .round
        }
    }
    
    func selectedItem(indexPath: IndexPath) {
        if selectedPassword.contains(indexPath.row) { return }
        let cell = gestureCollectionView.cellForItem(at: indexPath)
        drawLine(to: cell!.center)
        selectedPassword.append(indexPath.row)
        moveLayer?.removeFromSuperlayer()
        moveLayer = nil
        gestureCollectionView.reloadItems(at: [indexPath])
    }
    
    func cancel() {
        switch gesturePasswordType {
        case .setting:
            if selectedPassword.count >= 4 {
                password = selectedPassword
                showMessageAlert(message: "Password setting is successful")
            } else {
                showMessageAlert(message: "Password must be greater than 4, please try again")
            }
        case .unlock:
            if selectedPassword == password {
                showMessageAlert(message: "Unlocked successfully")
            } else {
                lineLayers.forEach { (layer) in
                    layer.strokeColor = UIColor.red.cgColor
                }
                gestureCollectionView.visibleCells.forEach { (cell) in
                    cell.layer.borderColor = UIColor.red.cgColor
                }
                moveLayer?.strokeColor = UIColor.red.cgColor
                showMessageAlert(message: "Unlock failed, please try again")
            }
        }
    }
}
