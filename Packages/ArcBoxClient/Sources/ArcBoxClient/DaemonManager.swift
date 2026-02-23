import Foundation
import Observation

/// Daemon connection state.
public enum DaemonState: Sendable, Equatable {
    case stopped
    case starting
    case running
    case error(String)

    public var isRunning: Bool { self == .running }
}

/// Manages the arcbox daemon lifecycle: discovery, health checking, and startup.
@Observable
@MainActor
public final class DaemonManager {
    /// Current daemon state.
    public private(set) var state: DaemonState = .stopped

    /// Path to the Docker-compatible socket used for health checks.
    public nonisolated(unsafe) static let dockerSocketPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.arcbox/docker.sock"
    }()

    private var daemonProcess: Process?

    public init() {}

    // MARK: - Binary Discovery

    /// Search for the arcboxd binary in standard locations.
    ///
    /// Search order:
    /// 1. App bundle Resources
    /// 2. Directory alongside the app bundle
    /// 3. Sibling workspace (../arcbox/target/{release,debug}/arcboxd)
    /// 4. System PATH
    public nonisolated func findBinary() -> String? {
        // 1. App bundle
        if let url = Bundle.main.url(forResource: "arcboxd", withExtension: nil) {
            return url.path
        }

        // 2. Alongside the app bundle
        let bundleDir = Bundle.main.bundleURL.deletingLastPathComponent()
        let siblingBin = bundleDir.appendingPathComponent("arcboxd")
        if FileManager.default.isExecutableFile(atPath: siblingBin.path) {
            return siblingBin.path
        }

        // 3. Sibling workspace
        let workspaceDir = bundleDir.deletingLastPathComponent()
        for config in ["release", "debug"] {
            let candidate = workspaceDir
                .appendingPathComponent("arcbox/target/\(config)/arcboxd")
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate.path
            }
        }

        // 4. PATH lookup
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["arcboxd"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                    !path.isEmpty {
                    return path
                }
            }
        } catch {}

        return nil
    }

    // MARK: - Health Check

    /// Check if the daemon is reachable by sending HTTP GET /_ping to the Docker socket.
    ///
    /// Uses raw POSIX socket API to communicate over Unix domain socket.
    public nonisolated func healthCheck() -> Bool {
        let path = Self.dockerSocketPath

        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return false }
        defer { close(fd) }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = path.utf8CString
        let maxLen = MemoryLayout.size(ofValue: addr.sun_path)
        guard pathBytes.count <= maxLen else { return false }

        _ = withUnsafeMutablePointer(to: &addr.sun_path) { sunPath in
            pathBytes.withUnsafeBufferPointer { buf in
                memcpy(sunPath, buf.baseAddress!, buf.count)
            }
        }

        let connectResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                Darwin.connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connectResult == 0 else { return false }

        let request = "GET /_ping HTTP/1.0\r\nHost: localhost\r\n\r\n"
        let written = request.withCString { cstr in
            write(fd, cstr, strlen(cstr))
        }
        guard written > 0 else { return false }

        var buffer = [UInt8](repeating: 0, count: 256)
        let bytesRead = read(fd, &buffer, buffer.count - 1)
        guard bytesRead > 0 else { return false }

        let response = String(bytes: buffer[0..<bytesRead], encoding: .utf8) ?? ""
        return response.contains("200")
    }

    // MARK: - Daemon Lifecycle

    /// Start the daemon and wait for it to become ready.
    ///
    /// If the daemon is already running (health check passes), transitions directly to `.running`.
    /// Otherwise, attempts to find and launch the daemon binary.
    public func startDaemon() async {
        // Already healthy?
        if healthCheck() {
            state = .running
            return
        }

        state = .starting

        guard let binary = findBinary() else {
            state = .error("arcboxd binary not found")
            return
        }

        // Launch daemon process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: binary)
        process.arguments = ["daemon"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            state = .error("Failed to start daemon: \(error.localizedDescription)")
            return
        }

        daemonProcess = process

        // Poll for readiness (up to 10 seconds)
        for _ in 0..<20 {
            try? await Task.sleep(for: .milliseconds(500))

            if healthCheck() {
                state = .running
                return
            }

            // Process died
            if !process.isRunning {
                state = .error("Daemon exited with code \(process.terminationStatus)")
                return
            }
        }

        state = .error("Daemon did not become ready in time")
    }

    /// Stop the daemon process if we started it.
    public func stopDaemon() {
        daemonProcess?.terminate()
        daemonProcess = nil
        state = .stopped
    }
}
