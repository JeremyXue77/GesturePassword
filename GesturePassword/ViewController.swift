//
//  ViewController.swift
//  GesturePassword
//
//  Created by JeremyXue on 2019/4/12.
//  Copyright © 2019 JeremyXue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var currentPoint: CGPoint?
    private var password = [Int]()
    private var selectedPassword = [Int]()
    private var lineLayers = [CAShapeLayer]()
    private var row = 3
    private let buttonTag = -1
    private let cellID = "cell"
    private var moveLayer: CAShapeLayer?
    
    @IBOutlet weak var gestureCollectionView: GestureCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureCollectionView.dataSource = self
        gestureCollectionView.delegate = self
        gestureCollectionView.gestureDelegate = self
    }
    
    private func drawLine(to point: CGPoint) {
        if let currentPoint = currentPoint {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = gestureCollectionView.bounds
            shapeLayer.position = gestureCollectionView.center
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = 5
            shapeLayer.strokeColor = UIColor.red.cgColor
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
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row * row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.tag = indexPath.row
        cell.layer.cornerRadius = cell.bounds.height / 2
        cell.layer.borderColor = !selectedPassword.contains(indexPath.row) ? UIColor.black.cgColor : UIColor.red.cgColor
        cell.layer.borderWidth = 5
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView.bounds.width - CGFloat(60 * row)) / CGFloat(row - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView.bounds.width - CGFloat(60 * row)) / CGFloat(row - 1)
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
            moveLayer?.lineWidth = 5
            moveLayer?.strokeColor = UIColor.red.cgColor
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
        lineLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        selectedPassword.removeAll()
        gestureCollectionView.reloadSections(IndexSet(integer: 0))
        currentPoint = nil
        moveLayer?.removeFromSuperlayer()
        moveLayer = nil
    }
}
