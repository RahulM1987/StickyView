//
//  ViewController.swift
//  StickyView
//
//  Created by Rahul Morade on 18/09/18.
//  Copyright © 2018 Rahul Morade. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var imageView = UIImageView()
     var imageView2 = UIImageView()
    var overlayView = UIView()
    var btnsetImage = UIButton()
    var cropFrame = CGSize()
    var cropAreaView = CropAreaView()
    var cropArea:CGRect{
        get{
            let factor = self.imageView.image!.size.width/self.view.frame.width
            let scale = 1/self.scrollView.zoomScale
            let imageFrame = self.imageView.imageFrame()
            let x = (self.scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (self.scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = cropAreaView.frame.size.width * scale * factor
            let height = cropAreaView.frame.size.height * scale * factor
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        setZoomScale()
        setupGestureRecognizer()
        self.cropAreaView.frame = CGRect(x: 5, y: self.view.frame.height/2 - (self.view.frame.width/2 - 5) , width: self.view.frame.width - 10, height: self.view.frame.width - 5)
        self.cropAreaView.backgroundColor = UIColor.init(red: 30.0/255.0, green: 30.0/255.0, blue: 150.0/255.0, alpha: 0.5)
        self.cropAreaView.isUserInteractionEnabled = true
        self.cropAreaView.layer.cornerRadius = self.cropAreaView.frame.width/2
        self.cropAreaView.layer.masksToBounds = true
        
        //ScrollView parent View
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 3
        self.scrollView.bounces = false
        self.scrollView.delegate = self;
        
        // Subview of Scrollview - Imageview
        self.imageView.image = UIImage(named: "apple-colour-logo.jpg")
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        //self.imageView.frame = CGRect(origin: CGPoint.zero, size: (self.imageView.image?.size)!)
        self.imageView.backgroundColor = UIColor.lightGray
        self.imageView.contentMode = .scaleAspectFit
        
        //SubView of scroll - circle overlay
        //self.overlayView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.overlayView = createOverlay(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), xOffset: self.view.frame.width/2, yOffset: self.view.frame.height/2, radius: self.view.frame.width/2 - 5)
        self.cropFrame = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)

        // Button to set image - subview of overlay
        self.btnsetImage.frame = CGRect(x: self.view.frame.width/2 - 75, y: self.view.frame.height - 50, width: 150, height: 20)
        self.btnsetImage.setTitle("Set Image", for: .normal)
        self.btnsetImage.titleLabel?.textColor = UIColor.lightGray
        self.btnsetImage.backgroundColor = UIColor.black
        self.btnsetImage.isUserInteractionEnabled = true
        self.btnsetImage.addTarget(self, action: #selector(setImageAsProfile), for: .touchUpInside)
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.overlayView.addSubview(self.btnsetImage)
        self.scrollView.addSubview(self.cropAreaView)
        self.scrollView.addSubview(self.overlayView)
    }
    
    @objc func setImageAsProfile() {
        print("Image frame: \(cropArea)")
//        self.imageView.image?.cgImage?.cropping(to: self.imageView.frame)
//        self.imageView.image = self.imageView.image?.circularImage(size: self.overlayView.frame.size)
        
        //self.imageView.frame.size = self.cropFrame
        
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        if croppedCGImage != nil {
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        self.imageView.image = croppedImage
        scrollView.zoomScale = 1
        } else { print("Image cropped too much")}
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //print("Zooming: \(self.imageView.frame)")
        return self.imageView
    }
    
    override func viewWillLayoutSubviews() {
        //        setZoomScale()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("Y = \(self.scrollView.contentOffset.y) X = \(self.scrollView.contentOffset.x)")
        //print("L = \(self.scrollView.contentInset.left) R = \(self.scrollView.contentInset.right)")

        self.overlayView.frame = CGRect(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y, width: self.view.frame.width, height: self.view.frame.height)
        self.cropAreaView.frame = CGRect(x:self.scrollView.contentOffset.x + 5, y: self.scrollView.contentOffset.y +  self.view.frame.height/2 - self.view.frame.width/2 + 2.5, width: self.view.frame.width - 10, height: self.view.frame.width - 5)
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = self.imageView.frame.size
        let scrollViewSize = self.scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        //print("Y = \(self.scrollView.contentOffset.y) X = \(self.scrollView.contentOffset.x)")
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    //
    //    func setZoomScale() {
    //        let imageViewSize = self.imageView?.bounds.size
    //        let scrollViewSize = self.scrollView.bounds.size
    //        let widthScale = scrollViewSize.width / imageViewSize.width
    //        let heightScale = scrollViewSize.height / imageViewSize.height
    //
    //        self.scrollView.minimumZoomScale = min(widthScale, heightScale)
    //        self.scrollView.zoomScale = 3.0
    //    }
    //
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func createOverlay(frame: CGRect,
                       xOffset: CGFloat,
                       yOffset: CGFloat,
                       radius: CGFloat) -> UIView {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
}

extension UIImage {
    
    func circularImage(size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
}

extension UIImageView {
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

class CropAreaView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
