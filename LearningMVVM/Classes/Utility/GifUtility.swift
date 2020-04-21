//
//  GifUtility.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

open class SwiftyGifManager {
    
    // A convenient default manager if we only have one gif to display here and there
    public static var defaultManager = SwiftyGifManager(memoryLimit: 50)
    
    fileprivate var timer: CADisplayLink?
    fileprivate var displayViews: [UIImageView] = []
    fileprivate var totalGifSize: Int
    fileprivate var memoryLimit: Int
    open var  haveCache: Bool
    
    /// Initialize a manager
    ///
    /// - Parameter memoryLimit: The number of Mb max for this manager
    public init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        totalGifSize = 0
        haveCache = true
    }
    
    deinit {
        stopTimer()
    }
    
    public func startTimerIfNeeded() {
        guard timer == nil else {
            return
        }
        
        timer = CADisplayLink(target: self, selector: #selector(updateImageView))
        
        #if swift(>=4.2)
        timer?.add(to: .main, forMode: .common)
        #else
        timer?.add(to: .main, forMode: RunLoopMode.commonModes)
        #endif
    }
    
    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Add a new imageView to this manager if it doesn't exist
    /// - Parameter imageView: The UIImageView we're adding to this manager
    open func addImageView(_ imageView: UIImageView) -> Bool {
        if containsImageView(imageView) {
            startTimerIfNeeded()
            return false
        }
        
        updateCacheSize(for: imageView, add: true)
        displayViews.append(imageView)
        startTimerIfNeeded()
        
        return true
    }
    
    /// Delete an imageView from this manager if it exists
    /// - Parameter imageView: The UIImageView we want to delete
    open func deleteImageView(_ imageView: UIImageView) {
        guard let index = displayViews.firstIndex(of: imageView) else {
            return
        }
        
        displayViews.remove(at: index)
        updateCacheSize(for: imageView, add: false)
    }
    
    open func updateCacheSize(for imageView: UIImageView, add: Bool) {
        totalGifSize += (add ? 1 : -1) * (imageView.gifImage?.imageSize ?? 0)
        haveCache = totalGifSize <= memoryLimit
        
        for imageView in displayViews {
            DispatchQueue.global(qos: .userInteractive).sync(execute: imageView.updateCache)
        }
    }
    
    open func clear() {
        displayViews.forEach { $0.clear() }
        displayViews = []
        stopTimer()
    }
    
    /// Check if an imageView is already managed by this manager
    /// - Parameter imageView: The UIImageView we're searching
    /// - Returns : a boolean for wether the imageView was found
    open func containsImageView(_ imageView: UIImageView) -> Bool{
        return displayViews.contains(imageView)
    }
    
    /// Check if this manager has cache for an imageView
    /// - Parameter imageView: The UIImageView we're searching cache for
    /// - Returns : a boolean for wether we have cache for the imageView
    open func hasCache(_ imageView: UIImageView) -> Bool{
        return imageView.displaying && (imageView.loopCount == -1 || imageView.loopCount >= 5) ? haveCache : false
    }
    
    /// Update imageView current image. This method is called by the main loop.
    /// This is what create the animation.
    @objc func updateImageView(){
        guard !displayViews.isEmpty else {
            stopTimer()
            return
        }
        
        for imageView in displayViews {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync {
                imageView.image = imageView.currentImage
            }
            
            if imageView.isAnimatingGif() {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync(execute: imageView.updateCurrentImage)
            }
        }
    }
}

public typealias GifLevelOfIntegrity = Float

extension GifLevelOfIntegrity {
    public static let highestNoFrameSkipping: GifLevelOfIntegrity = 1
    public static let `default`: GifLevelOfIntegrity = 0.8
    public static let lowForManyGifs: GifLevelOfIntegrity = 0.5
    public static let lowForTooManyGifs: GifLevelOfIntegrity = 0.2
    public static let superLowForSlideShow: GifLevelOfIntegrity = 0.1
}

enum GifParseError: Error {
    case invalidFilename
    case noImages
    case noProperties
    case noGifDictionary
    case noTimingInfo
}

extension GifParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFilename:
            return "Invalid file name"
        case .noImages,.noProperties, .noGifDictionary,.noTimingInfo:
            return "Invalid gif file "
        }
    }
}

// MARK: - Inits

public extension UIImage {
    
    /// Convenience initializer. Creates a gif with its backing data.
    ///
    /// - Parameter gifData: The actual gif data
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init(gifData:Data, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        self.init()
        try setGifFromData(gifData, levelOfIntegrity: levelOfIntegrity)
    }
    
    /// Convenience initializer. Creates a gif with its backing data.
    ///
    /// - Parameter gifName: Filename
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init(gifName: String, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        self.init()
        try setGif(gifName, levelOfIntegrity: levelOfIntegrity)
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter data: The actual gif data
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    func setGifFromData(_ data: Data, levelOfIntegrity: GifLevelOfIntegrity) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        self.imageSource = imageSource
        imageData = data
        
        calculateFrameDelay(try delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
        calculateFrameSize()
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter name: Filename
    func setGif(_ name: String) throws {
        try setGif(name, levelOfIntegrity: .default)
    }
    
    /// Check the number of frame for this gif
    ///
    /// - Return number of frames
    func framesCount() -> Int {
        return displayOrder?.count ?? 0
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter name: Filename
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    func setGif(_ name: String, levelOfIntegrity: GifLevelOfIntegrity) throws {
        if let url = Bundle.main.url(forResource: name,
                                     withExtension: name.pathExtension() == "gif" ? "" : "gif") {
            if let data = try? Data(contentsOf: url) {
                try setGifFromData(data, levelOfIntegrity: levelOfIntegrity)
            }
        } else {
            throw GifParseError.invalidFilename
        }
    }
    
    func clear() {
        imageData = nil
        imageSource = nil
        displayOrder = nil
        imageCount = nil
        imageSize = nil
        displayRefreshFactor = nil
    }
    
    // MARK: Logic
    
    private func convertToDelay(_ pointer:UnsafeRawPointer?) -> Float? {
        if pointer == nil {
            return nil
        }
        
        return unsafeBitCast(pointer, to:AnyObject.self).floatValue
    }
    
    /// Get delay times for each frames
    ///
    /// - Parameter imageSource: reference to the gif image source
    /// - Returns array of delays
    private func delayTimes(_ imageSource:CGImageSource) throws -> [Float] {
        let imageCount = CGImageSourceGetCount(imageSource)
        
        guard imageCount > 0 else {
            throw GifParseError.noImages
        }
        
        var imageProperties = [CFDictionary]()
        
        for i in 0..<imageCount {
            if let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) {
                imageProperties.append(dict)
            } else {
                throw GifParseError.noProperties
            }
        }
        
        let frameProperties = try imageProperties.map() { (dict: CFDictionary) -> CFDictionary in
            let key = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
            let value = CFDictionaryGetValue(dict, key)
            
            if value == nil {
                throw GifParseError.noGifDictionary
            }
            
            return unsafeBitCast(value, to: CFDictionary.self)
        }
        
        let EPS:Float = 1e-6
        
        let frameDelays:[Float] = try frameProperties.map() {
            let unclampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
            let unclampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, unclampedKey)
            
            if let value = convertToDelay(unclampedPointer), value >= EPS {
                return value
            }
            
            let clampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()
            let clampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, clampedKey)
            
            if let value = convertToDelay(clampedPointer) {
                return value
            }
            
            throw GifParseError.noTimingInfo
        }
        
        return frameDelays
    }
    
    /// Compute backing data for this gif
    ///
    /// - Parameter delaysArray: decoded delay times for this gif
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    private func calculateFrameDelay(_ delaysArray: [Float], levelOfIntegrity: GifLevelOfIntegrity) {
        let levelOfIntegrity = max(0, min(1, levelOfIntegrity))
        var delays = delaysArray
        
        // Factors send to CADisplayLink.frameInterval
        let displayRefreshFactors = [60, 30, 20, 15, 12, 10, 6, 5, 4, 3, 2, 1]
        
        // maxFramePerSecond,default is 60
        let maxFramePerSecond = displayRefreshFactors[0]
        
        // frame numbers per second
        let displayRefreshRates = displayRefreshFactors.map { maxFramePerSecond / $0 }
        
        // time interval per frame
        let displayRefreshDelayTime = displayRefreshRates.map { 1 / Float($0) }
        
        // caclulate the time when each frame should be displayed at(start at 0)
        for i in delays.indices.dropFirst() {
            delays[i] += delays[i - 1]
        }
        
        //find the appropriate Factors then BREAK
        for (i, delayTime) in displayRefreshDelayTime.enumerated() {
            let displayPosition = delays.map { Int($0 / delayTime) }
            var frameLoseCount: Float = 0
            
            for j in displayPosition.indices.dropFirst() where displayPosition[j] == displayPosition[j - 1] {
                frameLoseCount += 1
            }
            
            if displayPosition.first == 0 {
                frameLoseCount += 1
            }
            
            if frameLoseCount <= Float(displayPosition.count) * (1 - levelOfIntegrity) || i == displayRefreshDelayTime.count - 1 {
                imageCount = displayPosition.last
                displayRefreshFactor = displayRefreshFactors[i]
                displayOrder = []
                var oldIndex = 0
                var newIndex = 1
                let imageCount = self.imageCount ?? 0
                
                while newIndex <= imageCount && oldIndex < displayPosition.count {
                    if newIndex <= displayPosition[oldIndex] {
                        displayOrder?.append(oldIndex)
                        newIndex += 1
                    } else {
                        oldIndex += 1
                    }
                }
                
                break
            }
        }
    }
    
    /// Compute frame size for this gif
    private func calculateFrameSize(){
        guard let imageSource = imageSource,
            let imageCount = imageCount,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                return
        }
        
        let image = UIImage(cgImage: cgImage)
        imageSize = Int(image.size.height * image.size.width * 4) * imageCount / 1_000_000
    }
}

// MARK: - Properties

private let _imageSourceKey = malloc(4)
private let _displayRefreshFactorKey = malloc(4)
private let _imageSizeKey = malloc(4)
private let _imageCountKey = malloc(4)
private let _displayOrderKey = malloc(4)
private let _imageDataKey = malloc(4)

public extension UIImage {
    
    var imageSource: CGImageSource? {
        get {
            let result = objc_getAssociatedObject(self, _imageSourceKey!)
            return result == nil ? nil : (result as! CGImageSource)
        }
        set {
            objc_setAssociatedObject(self, _imageSourceKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var displayRefreshFactor: Int?{
        get { return objc_getAssociatedObject(self, _displayRefreshFactorKey!) as? Int }
        set { objc_setAssociatedObject(self, _displayRefreshFactorKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageSize: Int?{
        get { return objc_getAssociatedObject(self, _imageSizeKey!) as? Int }
        set { objc_setAssociatedObject(self, _imageSizeKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageCount: Int?{
        get { return objc_getAssociatedObject(self, _imageCountKey!) as? Int }
        set { objc_setAssociatedObject(self, _imageCountKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var displayOrder: [Int]?{
        get { return objc_getAssociatedObject(self, _displayOrderKey!) as? [Int] }
        set { objc_setAssociatedObject(self, _displayOrderKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageData:Data? {
        get {
            let result = objc_getAssociatedObject(self, _imageDataKey!)
            return result == nil ? nil : (result as? Data)
        }
        set {
            objc_setAssociatedObject(self, _imageDataKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension String {
    fileprivate func pathExtension() -> String {
        return (self as NSString).pathExtension
    }
}


@objc public protocol SwiftyGifDelegate {
    @objc optional func gifDidStart(sender: UIImageView)
    @objc optional func gifDidLoop(sender: UIImageView)
    @objc optional func gifDidStop(sender: UIImageView)
    @objc optional func gifURLDidFinish(sender: UIImageView)
    @objc optional func gifURLDidFail(sender: UIImageView, url: URL, error: Error?)
}

public extension UIImageView {
    
    // MARK: - Inits
    
    /// Convenience initializer. Creates a gif holder (defaulted to infinite loop).
    ///
    /// - Parameter gifImage: The UIImage containing the gif backing data
    /// - Parameter manager: The manager to handle the gif display
    convenience init(gifImage: UIImage, manager: SwiftyGifManager = .defaultManager, loopCount: Int = -1) {
        self.init()
        setGifImage(gifImage,manager: manager, loopCount: loopCount)
    }
    
    /// Convenience initializer. Creates a gif holder (defaulted to infinite loop).
    ///
    /// - Parameter gifImage: The UIImage containing the gif backing data
    /// - Parameter manager: The manager to handle the gif display
    convenience init(gifURL: URL, manager: SwiftyGifManager = .defaultManager, loopCount: Int = -1) {
        self.init()
        setGifFromURL(gifURL, manager: manager, loopCount: loopCount)
    }
    
    /// Set a gif image and a manager to an existing UIImageView.
    ///
    /// WARNING : this overwrite any previous gif.
    /// - Parameter gifImage: The UIImage containing the gif backing data
    /// - Parameter manager: The manager to handle the gif display
    /// - Parameter loopCount: The number of loops we want for this gif. -1 means infinite.
    func setGifImage(_ gifImage: UIImage, manager: SwiftyGifManager = .defaultManager, loopCount: Int = -1) {
        if let imageData = gifImage.imageData, (gifImage.imageCount ?? 0) < 1 {
            image = UIImage(data: imageData)
            return
        }
        
        self.loopCount = loopCount
        self.gifImage = gifImage
        animationManager = manager
        syncFactor = 0
        displayOrderIndex = 0
        cache = NSCache()
        haveCache = false
        
        if let source = gifImage.imageSource, let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            currentImage = UIImage(cgImage: cgImage)
            
            if manager.addImageView(self) {
                startDisplay()
                startAnimatingGif()
            }
        }
    }
}

// MARK: - Download gif

public extension UIImageView {
    
    /// Download gif image and sets it.
    ///
    /// - Parameters:
    ///     - url: The URL pointing to the gif data
    ///     - manager: The manager to handle the gif display
    ///     - loopCount: The number of loops we want for this gif. -1 means infinite.
    ///     - showLoader: Show UIActivityIndicatorView or not
    /// - Returns: An URL session task. Note: You can cancel the downloading task if it needed.
    @discardableResult
    func setGifFromURL(_ url: URL,
                       manager: SwiftyGifManager = .defaultManager,
                       loopCount: Int = -1,
                       levelOfIntegrity: GifLevelOfIntegrity = .default,
                       showLoader: Bool = true) -> URLSessionDataTask {
        stopAnimatingGif()
        let loader: UIActivityIndicatorView? = showLoader ? createLoader() : nil
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                loader?.removeFromSuperview()
                self.parseDownloadedGif(url: url,
                                        data: data,
                                        error: error,
                                        manager: manager,
                                        loopCount: loopCount,
                                        levelOfIntegrity: levelOfIntegrity)
            }
        }
        
        task.resume()
        
        return task
    }
    
    private func createLoader() -> UIActivityIndicatorView {
        let loader = UIActivityIndicatorView()
        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[subview]-0-|",
            options: .directionLeadingToTrailing,
            metrics: nil,
            views: ["subview": loader]))
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[subview]-0-|",
            options: .directionLeadingToTrailing,
            metrics: nil,
            views: ["subview": loader]))
        
        loader.startAnimating()
        
        return loader
    }
    
    private func parseDownloadedGif(url: URL,
                                    data: Data?,
                                    error: Error?,
                                    manager: SwiftyGifManager,
                                    loopCount: Int,
                                    levelOfIntegrity: GifLevelOfIntegrity) {
        guard let data = data else {
            report(url: url, error: error)
            return
        }
        
        do {
            let image = try UIImage(gifData: data, levelOfIntegrity: levelOfIntegrity)
            setGifImage(image, manager: manager, loopCount: loopCount)
            startAnimatingGif()
            delegate?.gifURLDidFinish?(sender: self)
        } catch {
            report(url: url, error: error)
        }
    }
    
    private func report(url: URL, error: Error?) {
        delegate?.gifURLDidFail?(sender: self, url: url, error: error)
    }
}

// MARK: - Logic

public extension UIImageView {
    
    /// Start displaying the gif for this UIImageView.
    private func startDisplay() {
        displaying = true
        updateCache()
    }
    
    /// Stop displaying the gif for this UIImageView.
    private func stopDisplay() {
        displaying = false
        updateCache()
    }
    
    /// Start displaying the gif for this UIImageView.
    func startAnimatingGif() {
        isPlaying = true
    }
    
    /// Stop displaying the gif for this UIImageView.
    func stopAnimatingGif() {
        isPlaying = false
    }
    
    /// Check if this imageView is currently playing a gif
    ///
    /// - Returns wether the gif is currently playing
    func isAnimatingGif() -> Bool{
        return isPlaying
    }
    
    /// Show a specific frame based on a delta from current frame
    ///
    /// - Parameter delta: The delsta from current frame we want
    func showFrameForIndexDelta(_ delta: Int) {
        guard let gifImage = gifImage else { return }
        var nextIndex = displayOrderIndex + delta
        
        while nextIndex >= gifImage.framesCount() {
            nextIndex -= gifImage.framesCount()
        }
        
        while nextIndex < 0 {
            nextIndex += gifImage.framesCount()
        }
        
        showFrameAtIndex(nextIndex)
    }
    
    /// Show a specific frame
    ///
    /// - Parameter index: The index of frame to show
    func showFrameAtIndex(_ index: Int) {
        displayOrderIndex = index
        updateFrame()
    }
    
    /// Update cache for the current imageView.
    func updateCache() {
        guard let animationManager = animationManager else { return }
        
        if animationManager.hasCache(self) && !haveCache {
            prepareCache()
            haveCache = true
        } else if !animationManager.hasCache(self) && haveCache {
            cache?.removeAllObjects()
            haveCache = false
        }
    }
    
    /// Update current image displayed. This method is called by the manager.
    func updateCurrentImage() {
        if displaying {
            updateFrame()
            updateIndex()
            
            if loopCount == 0 || !isDisplayedInScreen(self)  || !isPlaying {
                stopDisplay()
            }
        } else {
            if isDisplayedInScreen(self) && loopCount != 0 && isPlaying {
                startDisplay()
            }
            
            if isDiscarded(self) {
                animationManager?.deleteImageView(self)
            }
        }
    }
    
    /// Force update frame
    private func updateFrame() {
        if haveCache, let image = cache?.object(forKey: displayOrderIndex as AnyObject) as? UIImage {
            currentImage = image
        } else {
            currentImage = frameAtIndex(index: currentFrameIndex())
        }
    }
    
    /// Get current frame index
    func currentFrameIndex() -> Int{
        return displayOrderIndex
    }
    
    /// Get frame at specific index
    func frameAtIndex(index: Int) -> UIImage {
        guard let gifImage = gifImage,
            let imageSource = gifImage.imageSource,
            let displayOrder = gifImage.displayOrder, index < displayOrder.count,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, displayOrder[index], nil) else {
                return UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Check if the imageView has been discarded and is not in the view hierarchy anymore.
    ///
    /// - Returns : A boolean for weather the imageView was discarded
    func isDiscarded(_ imageView: UIView?) -> Bool {
        return imageView?.superview == nil
    }
    
    /// Check if the imageView is displayed.
    ///
    /// - Returns : A boolean for weather the imageView is displayed
    func isDisplayedInScreen(_ imageView: UIView?) -> Bool {
        guard !isHidden, let imageView = imageView else  {
            return false
        }
        
        let screenRect = UIScreen.main.bounds
        let viewRect = imageView.convert(bounds, to:nil)
        let intersectionRect = viewRect.intersection(screenRect)
        
        return window != nil && !intersectionRect.isEmpty && !intersectionRect.isNull
    }
    
    func clear() {
        if let gifImage = gifImage {
            gifImage.clear()
        }
        
        gifImage = nil
        currentImage = nil
        cache?.removeAllObjects()
        animationManager = nil
        image = nil
    }
    
    /// Update loop count and sync factor.
    private func updateIndex() {
        guard let gif = self.gifImage,
            let displayRefreshFactor = gif.displayRefreshFactor,
            displayRefreshFactor > 0 else {
                return
        }
        
        syncFactor = (syncFactor + 1) % displayRefreshFactor
        
        if syncFactor == 0, let imageCount = gif.imageCount, imageCount > 0 {
            displayOrderIndex = (displayOrderIndex+1) % imageCount
            
            if displayOrderIndex == 0 {
                if loopCount == -1 {
                    delegate?.gifDidLoop?(sender: self)
                } else if loopCount > 1 {
                    delegate?.gifDidLoop?(sender: self)
                    loopCount -= 1
                } else {
                    delegate?.gifDidStop?(sender: self)
                    loopCount -= 1
                }
            }
        }
    }
    
    /// Prepare the cache by adding every images of the gif to an NSCache object.
    private func prepareCache() {
        guard let cache = self.cache else { return }
        
        cache.removeAllObjects()
        
        guard let gif = self.gifImage,
            let displayOrder = gif.displayOrder,
            let imageSource = gif.imageSource else { return }
        
        for (i, order) in displayOrder.enumerated() {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, order, nil) else { continue }
            
            cache.setObject(UIImage(cgImage: cgImage), forKey: i as AnyObject)
        }
    }
}

// MARK: - Dynamic properties

private let _gifImageKey = malloc(4)
private let _cacheKey = malloc(4)
private let _currentImageKey = malloc(4)
private let _displayOrderIndexKey = malloc(4)
private let _syncFactorKey = malloc(4)
private let _haveCacheKey = malloc(4)
private let _loopCountKey = malloc(4)
private let _displayingKey = malloc(4)
private let _isPlayingKey = malloc(4)
private let _animationManagerKey = malloc(4)
private let _delegateKey = malloc(4)

public extension UIImageView {
    
    var gifImage: UIImage? {
        get { return possiblyNil(_gifImageKey) }
        set { objc_setAssociatedObject(self, _gifImageKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var currentImage: UIImage? {
        get { return possiblyNil(_currentImageKey) }
        set { objc_setAssociatedObject(self, _currentImageKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var displayOrderIndex: Int {
        get { return value(_displayOrderIndexKey, 0) }
        set { objc_setAssociatedObject(self, _displayOrderIndexKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var syncFactor: Int {
        get { return value(_syncFactorKey, 0) }
        set { objc_setAssociatedObject(self, _syncFactorKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var loopCount: Int {
        get { return value(_loopCountKey, 0) }
        set { objc_setAssociatedObject(self, _loopCountKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var animationManager: SwiftyGifManager? {
        get { return (objc_getAssociatedObject(self, _animationManagerKey!) as? SwiftyGifManager) }
        set { objc_setAssociatedObject(self, _animationManagerKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var delegate: SwiftyGifDelegate? {
        get { return (objc_getAssociatedObject(self, _delegateKey!) as? SwiftyGifDelegate) }
        set { objc_setAssociatedObject(self, _delegateKey!, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    private var haveCache: Bool {
        get { return value(_haveCacheKey, false) }
        set { objc_setAssociatedObject(self, _haveCacheKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var displaying: Bool {
        get { return value(_displayingKey, false) }
        set { objc_setAssociatedObject(self, _displayingKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var isPlaying: Bool {
        get {
            return value(_isPlayingKey, false)
        }
        set {
            objc_setAssociatedObject(self, _isPlayingKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue {
                delegate?.gifDidStart?(sender: self)
            } else {
                delegate?.gifDidStop?(sender: self)
            }
        }
    }
    
    private var cache: NSCache<AnyObject, AnyObject>? {
        get { return (objc_getAssociatedObject(self, _cacheKey!) as? NSCache) }
        set { objc_setAssociatedObject(self, _cacheKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private func value<T>(_ key:UnsafeMutableRawPointer?, _ defaultValue:T) -> T {
        return (objc_getAssociatedObject(self, key!) as? T) ?? defaultValue
    }
    
    private func possiblyNil<T>(_ key:UnsafeMutableRawPointer?) -> T? {
        let result = objc_getAssociatedObject(self, key!)
        
        if result == nil {
            return nil
        }
        
        return (result as? T)
    }
}
