//
//  RuntimeStorage.swift
//  GiphyPresenter
//
//  Created by Omnicron on 2/18/18.
//  Copyright © 2018 Eugeniya. All rights reserved.
//

import Foundation
import FLAnimatedImage

class RuntimeStorage {
    private var gifStorage = [String : FLAnimatedImage]()
    static let sharedInstance = RuntimeStorage()
    private var lock = NSLock()

    init() {
    }
    
    func saveImage(image: FLAnimatedImage, key: String) {
        lock.lock()
        self.gifStorage[key] = image
        lock.unlock()
    }
    
    func imageForKey(_ key: String) -> FLAnimatedImage? {
        return self.gifStorage[key]
    }
    func removeAll() {
        self.gifStorage.removeAll()
    }
}
