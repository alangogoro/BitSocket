//
//  ContentView.swift
//  BitSocket
//
//  Created by usr on 2024/4/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var service = WebSocketService()
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 150))
                .foregroundColor(Color(red: 247/255, green: 142/255, blue: 26/255))
                .padding()
            
            Text("USD")
                .font(.largeTitle)
                .padding()
            
            Text(service.priceResult)
                .font(.system(size: 60))
            
        }.onAppear {
            self.service.connect()
        }
        
    }
}

#Preview {
    ContentView()
}
