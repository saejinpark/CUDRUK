//
//  Models.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
final class ChapterModel {
    @Attribute(.unique) var id: String
    var order: Int
    var title: String
    var subtitle: String
    var icon: String
    var color: String
    var cardCount: Int

    init(id: String, order: Int, title: String, subtitle: String,
         icon: String, color: String, cardCount: Int) {
        self.id = id
        self.order = order
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.cardCount = cardCount
    }
}

@Model
final class CardModel {
    @Attribute(.unique) var id: String
    var chapterId: String
    var order: Int
    var level: Int
    var title: String
    var subtitle: String
    var summary: String
    var detail: String
    var tags: [String]
    var keywords: [String]
    var relatedIds: [String]
    var quizQuestion: String
    var quizOptions: [String]
    var quizAnswer: Int
    var quizExplanation: String
    var isBookmarked: Bool = false
    var isCompleted: Bool = false
    var quizAnswered: Bool = false
    var quizCorrect: Bool = false

    init(id: String, chapterId: String, order: Int, level: Int,
         title: String, subtitle: String, summary: String, detail: String,
         tags: [String], keywords: [String], relatedIds: [String],
         quizQuestion: String, quizOptions: [String],
         quizAnswer: Int, quizExplanation: String) {
        self.id = id
        self.chapterId = chapterId
        self.order = order
        self.level = level
        self.title = title
        self.subtitle = subtitle
        self.summary = summary
        self.detail = detail
        self.tags = tags
        self.keywords = keywords
        self.relatedIds = relatedIds
        self.quizQuestion = quizQuestion
        self.quizOptions = quizOptions
        self.quizAnswer = quizAnswer
        self.quizExplanation = quizExplanation
    }
}

// MARK: - JSON DTOs

struct ChapterDTO: Decodable {
    let id: String
    let order: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: String
    let card_count: Int
}

struct CardDTO: Decodable {
    let id: String
    let chapter_id: String
    let order: Int
    let level: Int
    let title: String
    let subtitle: String
    let summary: String
    let detail: String
    let tags: [String]
    let keywords: [String]
    let related_ids: [String]
    let quiz: QuizDTO
}

struct QuizDTO: Decodable {
    let question: String
    let options: [String]
    let answer: Int
    let explanation: String
}
