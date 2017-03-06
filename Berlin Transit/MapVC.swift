//
//  MapVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 15/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class MapVC: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        if let imageSize = self.imageView.image?.size {
            self.scrollView.contentSize = imageSize
            self.imageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            let zoomScale = CGFloat(0.5)
            let viewSize = self.view.frame.size;
            self.scrollView.zoomScale = zoomScale
            let offset = CGPoint(x: (imageSize.width / 2) * zoomScale - viewSize.width / 2, y: (imageSize.height / 2) * zoomScale - viewSize.height / 2)
            self.scrollView.contentOffset = offset
        }
    }
}

extension MapVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
