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
    private var currentOperation: Operation?
    
    init() {
        AXCGiphy.setGiphyAPIKey(NetworkLayer.giphyApiKey)
    }
    
    func searchGiphyWithTerm(_ term : String, offset: UInt, completion: @escaping EZCompletionClosure) {
        self.currentOperation?.cancel()
        for r in self.requests {
            print(r)
            r.cancel()
        }
        self.requests.removeAll()
        self.currentOperation = BlockOperation {
            let task = AXCGiphy.search(withTerm: term, limit: 25, offset: offset) { [weak self](result, error) in
                DispatchQueue.main.async(execute: {() -> Void in
                    if let confirmError = error as NSError? {
                        if confirmError.code == NSURLErrorCancelled {
                            print("CANCELLED: \(term)")
                        }
                        completion(nil, term, error)
                    } else {
                        let giphies: [AXCGiphy]? = (result as? [AXCGiphy]) ?? nil
                        if let aGiphies = giphies {
                            DispatchQueue.global(qos: .background).async {
                                self?.casheImages(aGiphies)
                            }
                        }
                        completion(giphies, term, error)
                        self?.currentOperation = nil
                    }
                })
            }
            guard let aTask = task else { return }
            self.requests.append(aTask)
        }
        self.currentOperation?.start()
    }
    
        private func casheImages(_ images: [AXCGiphy]) {
            for gif in images {
                if let imageData = try? Data(contentsOf: gif.fixedWidthDownsampledImage.url) {
                    if let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
                        RuntimeStorage.sharedInstance.saveImage(image: animatedImage, key: gif.originalImage.url.absoluteString)
                    }
                }
    
            }
        }
}
