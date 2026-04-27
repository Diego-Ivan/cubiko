import Foundation

final class ObtenerQrAccesoUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reservaId: Int) async throws -> Data {
        let base64String = try await repository.obtenerQrAcceso(reservaId: reservaId)
        
        // El string viene como Data URL: "data:image/png;base64,iVBORw..."
        // Necesitamos extraer solo la parte de base64
        let components = base64String.components(separatedBy: "base64,")
        
        guard components.count == 2,
              let data = Data(base64Encoded: components[1], options: .ignoreUnknownCharacters) else {
            throw NSError(domain: "ObtenerQrAcceso", code: 400, userInfo: [NSLocalizedDescriptionKey: "Formato de QR inválido"])
        }
        
        return data
    }
}
