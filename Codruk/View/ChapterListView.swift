//
//  ChapterListView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct ChapterListView: View {

    @Query(sort: \ChapterModel.order) private var chapters: [ChapterModel]
    @AppStorage("selectedLevel") private var selectedLevel: Int = 1

    var body: some View {
        NavigationStack {
            Group {
                if chapters.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("데이터 불러오는 중...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(chapters, id: \.id) { chapter in
                                NavigationLink(destination: CardListView(chapter: chapter, selectedLevel: selectedLevel)) {
                                    ChapterCardView(chapter: chapter, selectedLevel: selectedLevel)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("탐험")
        }
    }
}

struct ChapterCardView: View {

    let chapter: ChapterModel
    let selectedLevel: Int
    @Query private var allCards: [CardModel]

    private var cards: [CardModel] {
        allCards.filter { $0.chapterId == chapter.id && $0.level <= selectedLevel }
    }

    private var completedCount: Int {
        cards.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(completedCount) / Double(cards.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: chapter.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: chapter.color))

            Text(chapter.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            Text(chapter.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 4)

            ProgressView(value: progress)
                .tint(Color(hex: chapter.color))

            HStack {
                Text("\(completedCount)/\(cards.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: chapter.color))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: chapter.color).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: chapter.color).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
