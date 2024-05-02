//
//  WebSocketService.swift
//  BitSocket
//
//  Created by usr on 2024/4/25.
//

import Foundation
import Combine

class WebSocketService: ObservableObject {
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask? = nil
    
    private let baseURL = URL(string: "wss://ws.finnhub.io?token=cooc2shr01qm6hd1g06gcooc2shr01qm6hd1g070")!
    
    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    
    private var cancellable: AnyCancellable? = nil
    // Sends to contentView Price label
    var priceResult: String = "" {
        didSet {
            didChange.send(())
        }
    }
    
    init() {
        cancellable = AnyCancellable($price
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.priceResult, on: self))
    }
    
    // MARK: URLSession WebSocketTask
    func connect() {
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        
        sendMessage()
        receiveMessage()
        //sendPing()
    }
    
    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.sendPing()
            }
        }
    }
    
    private func sendMessage() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:BTCUSDT\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            
            switch result {
            case .success(.string(let str)):
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    
                    DispatchQueue.main.async {
                        self?.price = "\(result.data[0].p)"
                    }
                } catch {
                    print("error is \(error.localizedDescription)")
                }
                
                self?.receiveMessage()
                
            case .failure(let error):
                print("Error in receiving message: \(error)")
            default:
                print("default")
            }
            
        }
    }
    
}
