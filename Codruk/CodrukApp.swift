//
//  CodrukApp.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI
import SwiftData

@main
struct CodrukApp: App {
    
    @AppStorage("isOnboardingDone") private var isOnboardingDone = false

    
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: ChapterModel.self, CardModel.self
            )
        } catch {
            fatalError("SwiftData 컨테이너 생성 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isOnboardingDone {
                ContentView()
                    .onAppear {
                        DataImporter.seedIfNeeded(context: container.mainContext)
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(container)
    }
}
