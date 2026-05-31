//
//  SavedView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct SavedView: View {

    @Query private var allCards: [CardModel]
    @State private var selectedFilter: SavedFilter = .bookmarked

    enum SavedFilter: String, CaseIterable {
        case bookmarked = "북마크"
        case completed = "완료"
    }

    private var filteredCards: [CardModel] {
        switch selectedFilter {
        case .bookmarked:
            return allCards.filter { $0.isBookmarked }
        case .completed:
            return allCards.filter { $0.isCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 필터 피커
                Picker("필터", selection: $selectedFilter) {
                    ForEach(SavedFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredCards.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCards, id: \.id) { card in
                                NavigationLink(destination: CardDetailView(card: card)) {
                                    SavedCardRow(card: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("저장")
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: selectedFilter == .bookmarked ? "bookmark" : "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(selectedFilter == .bookmarked ? "북마크한 카드가 없어요" : "완료한 카드가 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

struct SavedCardRow: View {

    let card: CardModel

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
                    if card.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
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
