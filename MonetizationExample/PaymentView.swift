//
//  PaymentView.swift
//  MonetizationExample
//
//  Created by Mark on 22.12.23.
//

import SwiftUI

struct PaymentView: View {
    @State var isPolling: Bool = false
    @State private var timer: Timer? = nil
    
    var onPaymentSuccess: () -> Void = {}
    
    var body: some View {
        VStack {
            Text("Please pay to continue")
            if (isPolling){
                ProgressView("Polling")
                Button("Cancel"){
                    stopPolling()
                }
            }else {
                Button("Pay"){
                    openCheckoutAndStartPolling()
                }
            }
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
    }
    
    func openCheckoutAndStartPolling(){
        
        var checkoutURL = URL(string: "http://localhost:3000/checkout")!
        checkoutURL.append(queryItems: [
            URLQueryItem(name: "hashedDeviceID", value: getHashedDeviceID())
        ])
        NSWorkspace.shared.open(checkoutURL)
        
        startPolling()
    }

    func startPolling(){
        isPolling = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
            Task {
                let paid = await verifyPaid()
                if paid {
                    stopPolling()
                    onPaymentSuccess()
                }
            }
        })
    }

    func stopPolling(){
        
    }

}


#Preview {
    PaymentView(isPolling: true)
}
