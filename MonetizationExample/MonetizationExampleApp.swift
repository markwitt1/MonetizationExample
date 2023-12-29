//
//  MonetizationExampleApp.swift
//  MonetizationExample
//
//  Created by Mark on 22.12.23.
//

import SwiftUI

@main
struct MonetizationExampleApp: App {
    
    @State var isPaymentViewPresented: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    isPaymentViewPresented = !(await verifyPaid())
                }
                .sheet(isPresented: $isPaymentViewPresented, content: {
                    PaymentView(onPaymentSuccess: {
                        isPaymentViewPresented = false
                    })
                })
        }
    }
}
