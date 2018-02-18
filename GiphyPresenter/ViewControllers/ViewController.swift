//
//  ViewController.swift
//  GiphyPresenter
//
//  Created by Omnicron on 2/18/18.
//  Copyright © 2018 Eugeniya. All rights reserved.
//

import UIKit
import Giphy_iOS
import MBProgressHUD


class ViewController: UIViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var noResult: UILabel!
    @IBOutlet fileprivate weak var gifsCollectionView: UICollectionView!
    
    fileprivate static let padding: CGFloat = 2.0
    fileprivate var dataSource = [AXCGiphy]()
    fileprivate var currentPageOffset: UInt = 0
    fileprivate var isSearchPageLoadInProgress = false
    
    fileprivate var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchNextAnimations()
    }
    
    private func setupUI() {
        self.gifsCollectionView.isPagingEnabled = true
        self.gifsCollectionView.collectionViewLayout = CollectionGiphyGridLayouts()
        
        if let layouts = self.gifsCollectionView.collectionViewLayout as? CollectionGiphyGridLayouts {
            layouts.padding = ViewController.padding
            layouts.delegate = self
        }
        self.hideKeyboard()
    }
    
    private func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    fileprivate func fetchNextAnimations() {
        guard let searchedText = self.searchText else { return }
        guard !isSearchPageLoadInProgress else { return }
        
        self.isSearchPageLoadInProgress = true
        MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        NetworkLayer.sharedInstance.searchGiphyWithTerm(searchedText, offset: self.currentPageOffset){[weak self](result, term, error) in
            guard let s = self else { return }
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            s.isSearchPageLoadInProgress = false
            if let confirmError = error as NSError? {
                if (confirmError as NSError).code != NSURLErrorCancelled {
                    s.showError(confirmError)
                }
            } else if let confirmResult = result {
                print(confirmResult.count)
                s.dataSource += confirmResult
                s.updateCollectionView(withNumberOfCell: Int(s.dataSource.count) - Int(s.currentPageOffset))
                s.currentPageOffset = UInt(s.dataSource.count)
            }
        }
    }
    
    fileprivate func startNewSearch(searchedText: String?) {
        guard searchedText != nil else { return }
        self.searchText        = searchedText
        self.currentPageOffset = 0
        RuntimeStorage.sharedInstance.removeAll()
        guard self.searchText!.isEmpty == false else {
            self.dataSource.removeAll()
            self.reloadCollectionView()
            return
        }
        MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        NetworkLayer.sharedInstance.searchGiphyWithTerm(searchedText!, offset: self.currentPageOffset){[weak self](result,term, error) in
            guard let s = self else { return }
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            if let confirmError = error {
                if (confirmError as NSError).code != NSURLErrorCancelled {
                    s.showError(confirmError)
                    s.dataSource.removeAll()
                    s.currentPageOffset = 0
                    s.reloadCollectionView()
                }
            } else if let confirmResult = result {
                s.dataSource = confirmResult
                s.currentPageOffset += UInt(s.dataSource.count)
                s.reloadCollectionView()
            } else {
                print("everything is loaded")
            }
        }
    }
    
    private func reloadCollectionView() {
        if self.dataSource.count == 0 {
            self.noResult.isHidden = false
            self.gifsCollectionView.isHidden = true
        } else {
            self.noResult.isHidden = true
            self.gifsCollectionView.isHidden = false
        }
        self.gifsCollectionView.reloadData()
    }
    
    private func updateCollectionView(withNumberOfCell count: Int) {
        var indexPaths = [IndexPath]()
        for i in 1...count {
            let indexPath = IndexPath(item: (self.dataSource.count - i), section: 0)
            indexPaths.append(indexPath)
        }
        self.gifsCollectionView.performBatchUpdates({
            self.gifsCollectionView.insertItems(at: indexPaths)
        }, completion: nil)
    }
    
    private func showError(_ error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}

extension ViewController : CollectionGiphyGridDelegate {
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let width = self.view.bounds.width / 2 - ViewController.padding * 3
        if indexPath.row  < self.dataSource.count {
            let gif = self.dataSource[indexPath.row]
            if let img = gif.originalImage {
                let aspectRatio = img.height / img.width
                return width * aspectRatio
            }
        }
        return width
    }
}

extension ViewController : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell 
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GiphyCollectionViewCell.self),
                                                      for: indexPath) as! GiphyCollectionViewCell
        let gif = self.dataSource[indexPath.row]
        if let url = gif.fixedWidthDownsampledImage.url {
            cell.url = url
        }
        return cell
    }
}

extension ViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + scrollView.bounds.height + 100 >= scrollView.contentSize.height {
            if !isSearchPageLoadInProgress {
                self.fetchNextAnimations()
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == self.searchText {
            self.fetchNextAnimations()
        } else {
            self.startNewSearch(searchedText: searchText)
        }
    }
}
