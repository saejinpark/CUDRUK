//
//  HomeView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Query private var allCards: [CardModel]
    @Query(sort: \ChapterModel.order) private var chapters: [ChapterModel]
    @State private var todayCard: CardModel? = nil
    @AppStorage("selectedLevel") private var selectedLevel: Int = 0

    enum LevelFilter: Int, CaseIterable {
        case beginner = 1
        case intermediate = 2
        case advanced = 3

        var label: String {
            switch self {
            case .beginner: return "입문"
            case .intermediate: return "중급"
            case .advanced: return "고급"
            }
        }
    }

    private var completedCount: Int {
        filteredCards.filter { $0.isCompleted }.count
    }

    private var filteredCards: [CardModel] {
        if selectedLevel == 0 { return allCards }
        return allCards.filter { $0.level <= selectedLevel }
    }

    private var totalCount: Int { filteredCards.count }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    progressSection

                    if let card = todayCard {
                        todayCardSection(card: card)
                    }

                    chapterProgressSection
                }
                .padding()
            }
            .navigationTitle("CODRUK")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(LevelFilter.allCases, id: \.rawValue) { level in
                            Button {
                                selectedLevel = level.rawValue
                            } label: {
                                Text(level.label)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(LevelFilter(rawValue: selectedLevel)?.label ?? "전체")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .clipShape(Capsule())
                    }
                }
            }
            .onAppear {
                setTodayCard()
            }
        }
    }

    // MARK: - 진행도

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("진행도")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(completedCount)개 완료")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(totalCount)개 중")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: progress)
                    .tint(.blue)
                    .scaleEffect(x: 1, y: 2)

                Text("\(Int(progress * 100))% 완료")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
    }

    // MARK: - 오늘의 카드

    private func todayCardSection(card: CardModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 카드")
                .font(.headline)

            NavigationLink(destination: CardDetailView(card: card)) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("✨ 오늘의 카드")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "arrow.right.circle")
                            .foregroundStyle(.blue)
                    }

                    Text(card.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(card.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(card.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.blue.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 챕터별 진행도

    private var chapterProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챕터별 진행도")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(chapters, id: \.id) { chapter in
                    let chapterCards = filteredCards.filter { $0.chapterId == chapter.id }
                    let completed = chapterCards.filter { $0.isCompleted }.count
                    let total = chapterCards.count
                    let prog = total > 0 ? Double(completed) / Double(total) : 0

                    if total > 0 {
                        HStack(spacing: 12) {
                            Image(systemName: chapter.icon)
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: chapter.color))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(chapter.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(completed)/\(total)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                ProgressView(value: prog)
                                    .tint(Color(hex: chapter.color))
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
    }

    // MARK: - 오늘의 카드 설정

    private func setTodayCard() {
        guard todayCard == nil, !allCards.isEmpty else { return }
        let notCompleted = allCards.filter { !$0.isCompleted }
        todayCard = notCompleted.randomElement() ?? allCards.randomElement()
    }
}
