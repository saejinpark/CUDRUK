//
//  CardDetailView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {

    @Bindable var card: CardModel
    @Environment(\.modelContext) private var context

    @State private var selectedTab: CardTab = .summary
    @State private var showQuiz = false

    enum CardTab: String, CaseIterable {
        case summary = "요약"
        case detail = "상세"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                tabPicker
                contentSection
                Divider()
                quizSection
            }
            .padding()
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        card.isBookmarked.toggle()
                        try? context.save()
                    } label: {
                        Image(systemName: card.isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(card.isBookmarked ? .orange : .primary)
                    }

                    Button {
                        card.isCompleted.toggle()
                        try? context.save()
                    } label: {
                        Image(systemName: card.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundStyle(card.isCompleted ? .green : .primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showQuiz) {
            QuizView(card: card)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                levelBadge
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(card.tags.prefix(4), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Text(card.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(card.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var levelBadge: some View {
        let (label, color): (String, Color) = {
            switch card.level {
            case 1: return ("입문", .green)
            case 2: return ("중급", .orange)
            case 3: return ("심화", .red)
            default: return ("", .gray)
            }
        }()
        return Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(CardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                }
            }
        }
        .background(
            GeometryReader { geo in
                let tabWidth = geo.size.width / 2
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .frame(width: tabWidth)
                    .offset(x: selectedTab == .summary ? 0 : tabWidth)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            .padding(2)
        )
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Content

    private var contentSection: some View {
        Group {
            if selectedTab == .summary {
                summaryContent
            } else {
                detailContent
            }
        }
        .animation(.easeInOut(duration: 0.15), value: selectedTab)
    }

    private var summaryContent: some View {
        Text(card.summary)
            .font(.body)
            .lineSpacing(6)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
    }

    private var detailContent: some View {
        Text(card.detail)
            .font(.body)
            .lineSpacing(6)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
    }

    // MARK: - Quiz

    private var quizSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.blue)
                Text("퀴즈")
                    .font(.headline)
                Spacer()
                if card.quizAnswered {
                    HStack(spacing: 4) {
                        Image(systemName: card.quizCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(card.quizCorrect ? .green : .red)
                        Text(card.quizCorrect ? "정답" : "오답")
                            .font(.caption)
                            .foregroundStyle(card.quizCorrect ? .green : .red)
                    }
                }
            }

            Button {
                showQuiz = true
            } label: {
                Text(card.quizAnswered ? "퀴즈 다시 풀기" : "퀴즈 풀기 →")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
