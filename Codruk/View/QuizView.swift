//
//  QuizView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

struct QuizView: View {

    @Bindable var card: CardModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var selectedOption: Int? = nil
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    questionSection
                    optionsSection

                    if !showResult {
                        submitButton
                    } else {
                        resultSection
                    }
                }
                .padding()
            }
            .navigationTitle("퀴즈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(card.quizQuestion)
                .font(.title3)
                .fontWeight(.semibold)
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

    // MARK: - Options

    private var optionsSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(card.quizOptions.enumerated()), id: \.offset) { index, option in
                OptionButton(
                    index: index,
                    text: option,
                    selectedOption: selectedOption,
                    correctAnswer: card.quizAnswer,
                    showResult: showResult
                ) {
                    guard !showResult else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedOption = index
                    }
                }
            }
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            guard let selected = selectedOption else { return }
            withAnimation { showResult = true }
            card.quizAnswered = true
            card.quizCorrect = selected == card.quizAnswer
            try? context.save()
        } label: {
            Text("정답 확인")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selectedOption != nil ? Color.blue : Color.gray.opacity(0.3))
                .foregroundStyle(selectedOption != nil ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedOption == nil)
    }

    // MARK: - Result

    private var resultSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: selectedOption == card.quizAnswer
                      ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(selectedOption == card.quizAnswer ? .green : .red)
                Text(selectedOption == card.quizAnswer ? "정답이에요! 🎉" : "아쉽네요 😅")
                    .font(.headline)
                    .foregroundStyle(selectedOption == card.quizAnswer ? .green : .red)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                (selectedOption == card.quizAnswer ? Color.green : Color.red).opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("해설")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Text(card.quizExplanation)
                    .font(.subheadline)
                    .lineSpacing(4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button { dismiss() } label: {
                Text("확인")
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

// MARK: - Option Button

struct OptionButton: View {

    let index: Int
    let text: String
    let selectedOption: Int?
    let correctAnswer: Int
    let showResult: Bool
    let action: () -> Void

    private let labels = ["A", "B", "C", "D"]

    private var backgroundColor: Color {
        guard showResult else {
            return selectedOption == index ? .blue.opacity(0.12) : Color(.systemGray6)
        }
        if index == correctAnswer { return .green.opacity(0.15) }
        if index == selectedOption { return .red.opacity(0.15) }
        return Color(.systemGray6)
    }

    private var borderColor: Color {
        guard showResult else {
            return selectedOption == index ? .blue : .clear
        }
        if index == correctAnswer { return .green }
        if index == selectedOption { return .red }
        return .clear
    }

    private var labelColor: Color {
        guard showResult else {
            return selectedOption == index ? .blue : .secondary
        }
        if index == correctAnswer { return .green }
        if index == selectedOption { return .red }
        return .secondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(labels[index])
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(labelColor)
                    .frame(width: 28, height: 28)
                    .background(labelColor.opacity(0.1))
                    .clipShape(Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showResult {
                    if index == correctAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if index == selectedOption {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }
}
