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
    private var selectedPassword = [Int]()
    private var lineLayers = [CAShapeLayer]()
    private var row = 3
    private let buttonTag = -1
    
    @IBOutlet weak var gestureCollectionView: UICollectionView!
    
    @IBAction func reset(_ sender: UIButton) {
        lineLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        selectedPassword.removeAll()
        gestureCollectionView.reloadData()
        currentPoint = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureCollectionView.dataSource = self
        gestureCollectionView.delegate = self
    }
    
    private func configurationButton(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        guard let button = cell.viewWithTag(buttonTag) as? UIButton else { return }
        cell.layoutIfNeeded()
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.borderWidth = 3
        if !selectedPassword.contains(indexPath.row) {
            button.layer.borderColor = UIColor.black.cgColor
            button.tintColor = UIColor.black
        } else {
            button.layer.borderColor = UIColor.red.cgColor
            button.tintColor = UIColor.red
        }
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
    }
    
    private func drawLine(to point: CGPoint) {
        if let currentPoint = currentPoint {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = gestureCollectionView.bounds
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = 3
            shapeLayer.strokeColor = UIColor.red.cgColor
            let path = UIBezierPath()
            path.move(to: currentPoint)
            path.addLine(to: point)
            shapeLayer.path = path.cgPath
            shapeLayer.position = gestureCollectionView.center
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        configurationButton(cell, indexPath: indexPath)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedPassword.contains(indexPath.row) {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath)
        drawLine(to: cell!.center)
        selectedPassword.append(indexPath.row)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(row)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

