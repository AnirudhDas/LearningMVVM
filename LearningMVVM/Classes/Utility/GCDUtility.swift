//
//  GCDUtility.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

let serialQueue = DispatchQueue(label: "SerialQueue")
let concurrentQueue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)

/**
 Method to perform operations on Main Thread.
 
 - parameter updates: A block that needs to be executed on Main Thread.
 */
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

/**
 Method to perform operations on Background Thread.
 
 - parameter updates: A block that needs to be executed on Background Thread.
 */
func performOperationInBackground(_ updates: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        updates()
    }
}

/**
 Method to perform operations on Background Thread for User Initiated QOS.
 
 - parameter updates: A block that needs to be executed on Background Thread.
 */
func performInBackgroundForUserInitiated(_ updates: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        updates()
    }
}


/**
 Method to perform operations on Main Thread after some delay.
 
 - parameter delayTime: The time interval for which you want to delay the execution
 - parameter updates: A block that needs to be executed on Main Thread after the delay.
 */
func performUIUpdatesOnMainAfterDelay(delayTime delay: Double, _ updates: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
        updates()
    })
}

func performTaskSyncOnSerial(_ updates: @escaping () -> Void) {
    serialQueue.sync {
        updates()
    }
}

func performTaskAsyncOnSerial(_ updates: @escaping () -> Void) {
    serialQueue.async {
        updates()
    }
}

func performTaskSyncOnConcurrent(_ updates: @escaping () -> Void) {
    concurrentQueue.sync {
        updates()
    }
}

func performTaskAsyncOnConcurrent(_ updates: @escaping () -> Void) {
    concurrentQueue.async(flags: .barrier) {
        updates()
    }
}
