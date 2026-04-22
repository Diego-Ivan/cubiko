//
//  AvailableRoomsResponse.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//


struct AvailableRoomsResponse: Decodable {
    struct RoomDTO: Decodable {
        let numero: Int
        let ubicacion: String
        let maxPersonas: Int
        let minPersonas: Int?

        enum CodingKeys: String, CodingKey {
            case numero
            case ubicacion
            case maxPersonas
            case minPersonas
        }
    }

    let data: [RoomDTO]
}
