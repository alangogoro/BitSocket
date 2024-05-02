//
//  PriceModel.swift
//  BitSocket
//
//  Created by usr on 2024/5/2.
//

struct APIResponse: Codable {
    var data: [PriceData]
    var type : String
    
    private enum CodingKeys: String, CodingKey {
        case data, type
    }
}

struct PriceData: Codable {
    public var p: Float
    
    private enum CodingKeys: String, CodingKey {
        case p
    }
}
