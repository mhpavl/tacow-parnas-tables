//
//  ContentView.swift  (starter / placeholder)
//
//  Intentionally minimal so the app builds and runs before the demo. The agent
//  replaces this with the real driving UI (see ../Reference/ContentView.swift for
//  the target implementation and stage-safe backup).
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Vending Machine")
                .font(.largeTitle.bold())
            Text("Ready for the agent to build the state machine and UI.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
