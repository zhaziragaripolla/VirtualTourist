//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController {

    private var deleteItem: UIBarButtonItem!
    private var updateItem: UIBarButtonItem!
    public var viewModel: LocationDetailViewModel!
    
    private var selectedIndex: Int? {
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FlickrCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewModel.delegate = self
        
        layoutUI()
        viewModel.loadSavedPhotos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.savePhotos()
    }
    
    fileprivate func layoutUI(){
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDeleteItem(_:)))
        updateItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapReloadItem(_:)))
        
        navigationItem.setRightBarButtonItems([deleteItem, updateItem], animated: true)
        deleteItem.isEnabled = false
    }
    
    private func configureView(){
        if selectedIndex != nil {
            deleteItem.isEnabled = true
        }
        else {
            deleteItem.isEnabled = false
        }
    }
    
    @objc func didTapDeleteItem(_ sender: UIBarButtonItem) {
        guard let index = selectedIndex else { return}
        viewModel.deletePhoto(at: index)
    }
    
    @objc func didTapReloadItem(_ sender: UIBarButtonItem){
        viewModel.downloadNewPhotos()
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isUsingSavedPhotos {
            return viewModel.savedPhotos.count
        }
       return viewModel.flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlickrCollectionViewCell
        
        if viewModel.isUsingSavedPhotos {
            let image = viewModel.savedPhotos[indexPath.row]
            if let data = image.image {
                cell.photoImageView.image = UIImage(data: data)
            }
        } else {
            let photo = viewModel.flickrPhotos[indexPath.row]
            cell.activityIndicator.startAnimating()
            
            viewModel.downloadImage(for: photo, completion: { image in
                if let image = image {
                    cell.photoImageView.image = image
                }
                cell.activityIndicator.stopAnimating()
            })
            
        }
      
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedIndex = nil
            return false
        }
        selectedIndex = indexPath.row
        return true
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
        
        let totalSpacing = (2 * self.spacing) + ((itemsPerRow - 1) * spacingBetweenCells)
    
        let width = (collectionView.bounds.width - totalSpacing)/itemsPerRow
        return CGSize(width: width, height: width)
    }
    
}

extension PhotoAlbumViewController: LocationDetailViewModelProtocol {
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func reloadRows() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
}


