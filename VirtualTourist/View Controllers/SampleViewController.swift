//
//  SampleViewController.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    var deleteItem: UIBarButtonItem?
    var viewModel: LocationDetailViewModel!
    
    private var selectedIndices: [Int] = [] {
        didSet {
            configureView()
        }
    }
    private let itemsPerRow: CGFloat = 2
    private let spacing: CGFloat = 16.0
    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 10.0,
                                             bottom: 0,
                                             right: 10.0)
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FlickrCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    @objc func didTapDeleteItem(_ sender: UIBarButtonItem) {
        viewModel.deleteImages(at: selectedIndices)
        selectedIndices.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewModel?.delegate = self
        viewModel?.loadSavedPhotos()
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDeleteItem(_:)))
         navigationItem.rightBarButtonItem = deleteItem
        deleteItem?.isEnabled = false
        
    }
    
    func configureView(){
        deleteItem?.isEnabled = selectedIndices.count > 0 ? true : false
    }
    
}

extension SampleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlickrCollectionViewCell
        let photo = viewModel.images[indexPath.row]
        
        if let data = photo.image {
            cell.bg.image = UIImage(data: data)
        }
        else {
            cell.bg.image = UIImage(named: "placeholder")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha = 0.6
        selectedIndices.append(indexPath.row)
    }
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacingBetweenCells: CGFloat = 5
        
        let totalSpacing = (2 * self.spacing) + ((itemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
    
        let width = (collectionView.bounds.width - totalSpacing)/itemsPerRow
        return CGSize(width: width, height: width)
    }
    
}

extension SampleViewController: LocationDetailViewModelProtocol {
//    func fetchedImages(photos: [UIImage]) {
//
//    }
    
    func showAlert(message: String) {
        print(message)
    }
    
    func reloadRows() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    
}


