//
//  ContentView.swift
//  MonetizationExample
//
//  Created by Mark on 22.12.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("You need to pay to use this app")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
