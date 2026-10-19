import Foundation
import SwiftUI
import Combine

enum GameStatus {
    case ready
    case playing
    case gameOver
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var timeRemaining: Double = 20.0
    @Published var activeTargetIndex: Int? = nil
    @Published var status: GameStatus = .ready
    @Published var isNewHighScore: Bool = false
    
    private var gameTimer: AnyCancellable?
    private var targetTimer: AnyCancellable?
    private let highScoreKey = "TapGame_HighScore_v1"
    private let totalTime: Double = 20.0
    
    init() {
        self.highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    func startGame() {
        score = 0
        timeRemaining = totalTime
        isNewHighScore = false
        status = .playing
        spawnNewTarget()
        
        gameTimer?.cancel()
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0.15 {
                    self.timeRemaining -= 0.1
                } else {
                    self.timeRemaining = 0.0
                    self.endGame()
                }
            }
        
        resetTargetTimer()
    }
    
    func tapCell(at index: Int) {
        guard status == .playing else { return }
        
        if activeTargetIndex == index {
            score += 1
            triggerHapticFeedback()
            
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: highScoreKey)
                isNewHighScore = true
            }
            
            spawnNewTarget()
            resetTargetTimer()
        }
    }
    
    private func spawnNewTarget() {
        var nextIndex: Int
        repeat {
            nextIndex = Int.random(in: 0..<9)
        } while nextIndex == activeTargetIndex
        
        activeTargetIndex = nextIndex
    }
    
    private func resetTargetTimer() {
        targetTimer?.cancel()
        targetTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.status == .playing else { return }
                self.spawnNewTarget()
            }
    }
    
    private func endGame() {
        gameTimer?.cancel()
        targetTimer?.cancel()
        gameTimer = nil
        targetTimer = nil
        activeTargetIndex = nil
        status = .gameOver
        triggerGameOverHaptic()
    }
    
    func resetGame() {
        gameTimer?.cancel()
        targetTimer?.cancel()
        gameTimer = nil
        targetTimer = nil
        status = .ready
        score = 0
        timeRemaining = totalTime
        activeTargetIndex = nil
        isNewHighScore = false
    }
    
    private func triggerHapticFeedback() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    private func triggerGameOverHaptic() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        #endif
    }
}
