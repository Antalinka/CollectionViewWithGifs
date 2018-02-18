//
//  NetworkLayer.swift
//  TheBestSearchGifsApplication
//
//  Created by Omnicron on 2/18/18.
//  Copyright © 2018 OmnicronMini. All rights reserved.
//

import Foundation
import Giphy_iOS
import FLAnimatedImage


typealias EZCompletionClosure = ([AXCGiphy]?, String, Error?) -> ()

class NetworkLayer {
    private static let giphyApiKey = "2wGpUWCJ1jQcKu1nrFiz07vFImiURv3X"
    static let sharedInstance = NetworkLayer()
    private var requests = [URLSessionDataTask]()
    //@property(strong, nonatomic) NSOperation* currentOperation;
    private var currentOperation: Operation?
//    let operationsQueue = OperationQueue()
    
    
    init() {
        AXCGiphy.setGiphyAPIKey(NetworkLayer.giphyApiKey)
//        self.operationsQueue.maxConcurrentOperationCount = 8
    }
    
    func searchGiphyWithTerm(_ term : String, offset: UInt, completion: @escaping EZCompletionClosure) {
        //        if let previousTask = self.previousTask {
        //            previousTask.cancel()
        //        }
        self.currentOperation?.cancel()
//        operationsQueue.cancelAllOperations()
        /*
         self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
         
         NSArray* sectionArray = [weakSelf generationSectionFromArray:array withFilter:filterString];
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
         
         weakSelf.sectionsArray = sectionArray;
         [weakSelf.tableView reloadData];
         
         self.currentOperation = nil;
         
         });
         }];
         */
        //        let operation = BlockOperation(block: {
        //            AXCGiphy.search(withTerm: term, limit: 25, offset: offset) { [weak self](result, error) in
        //                if let giphies = result as? [AXCGiphy] {
        //                    for gif in giphies {
        //                        if let imageData = try? Data(contentsOf: gif.originalImage.url) {
        //                            if let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
        //                                RuntimeStorage.sharedInstance.saveImage(image: animatedImage, key: gif.originalImage.url.absoluteString)
        //                            }
        //                        }
        //                    }
        //                }
        //                DispatchQueue.main.async(execute: {() -> Void in
        //                    print("FINISHED!!!!" + term)
        //                    if let confirmError = error {
        //                        completion(nil, term, confirmError)
        //                    } else {
        //                        let giphies: [AXCGiphy]? = (result as? [AXCGiphy]) ?? nil
        //                        completion(giphies, term, error)
        //                    }
        //                    self?.currentOperation = nil
        //                })
        //            }
        //        })
        for r in self.requests {
            print(r)
            r.cancel()
        }
        self.requests.removeAll()
//        self.operationsQueue.addOperation {
        self.currentOperation = BlockOperation {
            let task = AXCGiphy.search(withTerm: term, limit: 25, offset: offset) { [weak self](result, error) in

                if let confirmError = error as NSError? {
                    if confirmError.code == NSURLErrorCancelled {
                        print("CANCELLED: \(term)")
                    }
                } else {
                    DispatchQueue.main.async(execute: {() -> Void in
                        let giphies: [AXCGiphy]? = (result as? [AXCGiphy]) ?? nil
                        completion(giphies, term, error)
                        self?.currentOperation = nil
                    })
                }
            }
            guard let aTask = task else { return }
            self.requests.append(aTask)
        }
        self.currentOperation?.start()
//        }
    }
    
//    private func casheImages(_ images: [AXCGiphy]) {
//        for gif in images {
//            if let imageData = try? Data(contentsOf: gif.originalImage.url) {
//                if let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
//                    RuntimeStorage.sharedInstance.saveImage(image: animatedImage, key: gif.originalImage.url.absoluteString)
//                }
//            }
//
//        }
//    }
}
