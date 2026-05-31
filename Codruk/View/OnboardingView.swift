//
//  OnboardingView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI

struct OnboardingView: View {

    @AppStorage("isOnboardingDone") private var isOnboardingDone = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cup.and.saucer.fill",
            title: "커피로 꺼드럭대고 싶을 때",
            description: "카페 가기 전, 원두 고르기 전,\n친구한테 커피 얘기하기 전.\n빠르게 무장하고 나가는 앱이에요.",
            color: Color(hex: "#6B4C2A")
        ),
        OnboardingPage(
            icon: "rectangle.stack.fill",
            title: "필요한 것만, 빠르게",
            description: "128개 커피 카드.\n요약으로 훑고, 상세로 파고,\n퀴즈로 확인해요.",
            color: Color(hex: "#3A7D44")
        ),
        OnboardingPage(
            icon: "drop.fill",
            title: "준비됐어요?",
            description: "입문부터 고급까지\n내 수준에 맞게 골라서 봐요.",
            color: Color(hex: "#C8860A")
        )
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack {
                // 스킵
                HStack {
                    Spacer()
                    Button("건너뛰기") {
                        isOnboardingDone = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                }

                Spacer()

                // 하단 인디케이터 + 버튼
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.primary : Color.secondary.opacity(0.3))
                                .frame(width: currentPage == index ? 20 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            isOnboardingDone = true
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "다음" : "시작하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(pages[currentPage].color)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {

    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(page.color)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
