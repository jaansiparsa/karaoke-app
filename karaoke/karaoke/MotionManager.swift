//
//  MotionManager.swift
//  karaoke
//
//  Created by Jaansi Parsa on 7/12/25.
//


import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private let updateInterval = 0.2

    @Published var roll: Double = 0.0

    func startUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let data = data else { return }
                let attitude = data.attitude
                let rawRoll = attitude.roll * 180 / .pi
                let rollRelativeToLeft = rawRoll + 90
                self?.roll = rollRelativeToLeft
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
