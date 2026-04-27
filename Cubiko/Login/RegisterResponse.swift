//
//  RegisterResponse.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/14/26.
//


import SwiftUI

struct RegisterResponse: Decodable {
    let success: Bool
    let data: RegisterData?
    let message: String?
    struct RegisterData: Decodable {
        let access_token: String
        let refresh_token: String?
        let expires_in: String
    }
}