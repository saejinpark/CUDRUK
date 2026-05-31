//
//  CardListView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct CardListView: View {

    let chapter: ChapterModel
    let selectedLevel: Int
    @Query private var allCards: [CardModel]

    private var cards: [CardModel] {
        allCards
            .filter { $0.chapterId == chapter.id && $0.level <= selectedLevel }
            .sorted { $0.order < $1.order }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(cards, id: \.id) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        CardRowView(card: card, chapterColor: chapter.color)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CardRowView: View {

    let card: CardModel
    let chapterColor: String

    private var levelLabel: String {
        switch card.level {
        case 1: return "입문"
        case 2: return "중급"
        case 3: return "심화"
        default: return ""
        }
    }

    private var levelColor: Color {
        switch card.level {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // 순서 번호 or 완료 표시
            ZStack {
                Circle()
                    .fill(card.isCompleted
                          ? Color(hex: chapterColor)
                          : Color(hex: chapterColor).opacity(0.1))
                    .frame(width: 36, height: 36)

                if card.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                } else {
                    Text("\(card.order)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: chapterColor))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(levelLabel)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(levelColor.opacity(0.15))
                        .foregroundStyle(levelColor)
                        .clipShape(Capsule())

                    Spacer()

                    if card.isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if card.quizAnswered {
                        Image(systemName: card.quizCorrect ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(card.quizCorrect ? .yellow : .gray)
                    }
                }

                Text(card.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(card.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(card.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}
