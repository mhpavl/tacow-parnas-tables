//
//  VendingDemoApp.swift
//  VendingDemo — starter for the "Tables → State Machines → Apps" live demo.
//
//  This is the BEFORE state. On stage, the Xcode 27 agent generates
//  `VendingMachine.swift` (the state machine from the reviewed Parnas table) and
//  rewrites `ContentView.swift` into the driving UI. If the agent stalls, paste the
//  files from ../Reference/ and keep going.
//

import SwiftUI

@main
struct VendingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
