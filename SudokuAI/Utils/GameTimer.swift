import Foundation
import UIKit

/*
     let timer = GameTimer { elapsed in
         print("Elapsed: \(elapsed)")
     }
     timer.start()
     // timer.pause(), timer.resume(), timer.stop() as needed
 */
class GameTimer {
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private(set) var elapsed: TimeInterval = 0
    private var isRunning = false
    private var wasPausedBySystem = false
    private var updateHandler: ((TimeInterval) -> Void)?

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }

    func start(updateHandler: ((TimeInterval) -> Void)? = nil) {
        self.updateHandler = updateHandler
        guard !isRunning else { return }
        startTime = Date()
        scheduleTimer()
        isRunning = true
        pausedTime = 0
        elapsed = 0
        wasPausedBySystem = false
    }

    func pause() {
        guard isRunning else { return }
        timer?.invalidate()
        if let start = startTime {
            pausedTime += Date().timeIntervalSince(start)
        }
        isRunning = false
    }

    func resume() {
        guard !isRunning else { return }
        startTime = Date()
        scheduleTimer()
        isRunning = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        pausedTime = 0
        elapsed = 0
        isRunning = false
        wasPausedBySystem = false
    }

    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsed = self.pausedTime + Date().timeIntervalSince(start)
            self.updateHandler?(self.elapsed)
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    @objc private func appWillResignActive() {
        if isRunning {
            pause()
            wasPausedBySystem = true
        }
    }

    @objc private func appDidBecomeActive() {
        if wasPausedBySystem {
            resume()
            wasPausedBySystem = false
        }
    }
}
