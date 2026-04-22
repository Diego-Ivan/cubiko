import Foundation

/// Representa la entidad de un estudiante mapeada a la tabla 'Estudiante'.
struct Estudiante: Codable, Equatable {
    let id: Int
    let nombre: String
    let email: String
    let status: Status
    let bloqueado: Bool
    let createdAt: Date
    
    enum Status: String, Codable {
        case activo = "Activo"
        case inactivo = "Inactivo"
        case egresado = "Egresado"
    }
    
    // Si necesitas mantener compatibilidad con alguna lógica que pida "displayName"
    var displayName: String {
        nombre
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case email
        case status
        case bloqueado
        case createdAt = "created_at"
    }
}
