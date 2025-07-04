import Foundation

typealias Scores = [Score]

struct Score: Codable, Comparable {
    let id: String
    let date: Date
    let seconds: Int
    let numIncorrect: Int
    let level: Int
    let usedColor: Bool
    let score: Int

    static func < (lhs: Score, rhs: Score) -> Bool {
        lhs.score > rhs.score
    }
}

extension Scores {
    init(storage: UserDefaults = UserDefaults.standard) {
        if let data = storage.data(forKey: "scores"),
           let loadedScores =  try? JSONDecoder().decode(Scores.self, from: data) {
            self = loadedScores
            print("Loaded \(loadedScores.count) scores.")
        } else {
            self = []
        }
    }

    mutating func add(_ score: Score, storage: UserDefaults = UserDefaults.standard) {
        self.append(score)
        save(scores: self)
    }

    func clear(storage: UserDefaults = UserDefaults.standard) {
        save(scores: [])
    }

    private func save(scores: Scores, storage: UserDefaults = UserDefaults.standard) {
        print("Saving \(scores.count) scores.")
        if let data = try? JSONEncoder().encode(scores) {
            storage.setValue(data, forKey: "scores")
        }
    }
}

extension Array where Element == Score {
    var average: Double {
        guard count > 0 else { return 0 }
        return self.map { Double($0.score) }.reduce(0, +) / Double(count)
    }

    func top(count: Int) -> [Score] {
        Array(self.sorted().prefix(count))
    }

    func recent(count: Int) -> [Score] {
        Array(self.sorted(by: { lhs, rhs in lhs.date > rhs.date }).prefix(count))
    }

    var mostRecent: Score? {
        Array(self.sorted(by: { lhs, rhs in lhs.date > rhs.date })).first
    }
}
