import Foundation
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

/// HTTP client for communicating with the Docker Engine API via Unix socket.
///
/// Usage:
/// ```swift
/// let client = DockerClient()
/// let response = try await client.api.ContainerList()
/// ```
@available(macOS 15.0, *)
public struct DockerClient: Sendable {
    /// Default Unix socket path for the Docker daemon.
    public static let defaultSocketPath = "/var/run/docker.sock"

    /// Default server URL matching the OpenAPI spec base path.
    public static let defaultServerURL = try! Servers.Server1.url()

    /// The generated OpenAPI client — use this to call Docker API operations.
    public let api: Client

    /// The underlying AsyncHTTPClient instance (for lifecycle management).
    private let httpClient: HTTPClient

    /// Creates a new Docker client targeting the given Unix socket path.
    ///
    /// - Parameter socketPath: Path to the Docker daemon Unix socket.
    public init(socketPath: String = DockerClient.defaultSocketPath) {
        let httpClient = HTTPClient(
            eventLoopGroupProvider: .singleton
        )
        let transport = AsyncHTTPClientTransport(
            configuration: .init(client: httpClient)
        )
        self.httpClient = httpClient
        self.api = Client(
            serverURL: Self.defaultServerURL,
            transport: transport
        )
    }

    /// Gracefully shut down the underlying HTTP client.
    public func shutdown() async throws {
        try await httpClient.shutdown()
    }
}
