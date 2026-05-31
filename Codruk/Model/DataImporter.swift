//
//  DataImporter.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import Foundation
import SwiftData

final class DataImporter {

    static let seededKey = "codruk_data_seeded_v1"

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        seedData(context: context)
        UserDefaults.standard.set(true, forKey: seededKey)
    }

    static func seedData(context: ModelContext) {
        print("📦 Codruk 데이터 임포트 시작...")

        importChapters(context: context)

        let cardFiles = [
            "cards_history", "cards_varieties", "cards_origins",
            "cards_processing", "cards_roasting", "cards_grinding",
            "cards_brewing", "cards_drinks", "cards_cupping",
            "cards_specialty", "cards_science", "cards_equipment",
            "cards_culture", "cards_korea"
        ]

        var totalCards = 0
        for fileName in cardFiles {
            let count = importCards(fileName: fileName, context: context)
            totalCards += count
            print("  ✅ \(fileName): \(count)개")
        }

        do {
            try context.save()
            print("✅ 총 \(totalCards)개 카드 임포트 완료")
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }

    private static func importChapters(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "chapters", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([ChapterDTO].self, from: data) else {
            print("❌ chapters.json 로드 실패")
            return
        }
        for dto in dtos {
            let chapter = ChapterModel(
                id: dto.id,
                order: dto.order,
                title: dto.title,
                subtitle: dto.subtitle,
                icon: dto.icon,
                color: dto.color,
                cardCount: dto.card_count
            )
            context.insert(chapter)
        }
        print("  ✅ chapters: \(dtos.count)개")
    }

    private static func importCards(fileName: String, context: ModelContext) -> Int {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([CardDTO].self, from: data) else {
            print("❌ \(fileName).json 로드 실패")
            return 0
        }
        for dto in dtos {
            let card = CardModel(
                id: dto.id,
                chapterId: dto.chapter_id,
                order: dto.order,
                level: dto.level,
                title: dto.title,
                subtitle: dto.subtitle,
                summary: dto.summary,
                detail: dto.detail,
                tags: dto.tags,
                keywords: dto.keywords,
                relatedIds: dto.related_ids,
                quizQuestion: dto.quiz.question,
                quizOptions: dto.quiz.options,
                quizAnswer: dto.quiz.answer,
                quizExplanation: dto.quiz.explanation
            )
            context.insert(card)
        }
        return dtos.count
    }

    // 개발용: 데이터 리셋
    static func resetSeed() {
        UserDefaults.standard.removeObject(forKey: seededKey)
    }
}
