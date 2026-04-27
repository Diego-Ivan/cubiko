//
//  LoginResponse.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/13/26.
//


import SwiftUI

struct LoginResponse: Decodable {
    let success: Bool
    let data: LoginData?
    let message: String?
    let error: String?
    
    struct LoginData: Decodable {
        let access_token: String
        let refresh_token: String?
        let expires_in: String
    }
}
