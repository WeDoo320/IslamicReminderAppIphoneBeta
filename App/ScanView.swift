import SwiftUI
import AVFoundation
import Vision

/// Kamera-Ansicht, die per Vision-Bildklassifikation eine Gebetsmatte/Teppich erkennt.
struct ScanView: View {
    var onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = MatScanner()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(session: camera.session).ignoresSafeArea()
            VStack(spacing: 12) {
                Text(camera.status).font(.headline).padding().background(.ultraThinMaterial, in: Capsule())
                Button("Abbrechen") { dismiss() }.buttonStyle(.bordered)
            }.padding(.bottom, 40)
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.found) { if $0 { onSuccess() } }
    }
}

final class MatScanner: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var status = "Richte die Kamera auf deine Gebetsmatte"
    @Published var found = false
    let session = AVCaptureSession()
    private var hits = 0
    private var lastCheck = Date.distantPast
    private let queue = DispatchQueue(label: "scan")
    private static let labels = ["rug", "carpet", "mat", "textile", "tapestry", "prayer_rug"]

    func start() {
        queue.async {
            guard self.session.inputs.isEmpty,
                  let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: dev) else { return self.session.startRunning() }
            self.session.addInput(input)
            let out = AVCaptureVideoDataOutput()
            out.setSampleBufferDelegate(self, queue: self.queue)
            self.session.addOutput(out)
            self.session.startRunning()
        }
    }
    func stop() { queue.async { self.session.stopRunning() } }

    func captureOutput(_ o: AVCaptureOutput, didOutput buf: CMSampleBuffer, from c: AVCaptureConnection) {
        guard !found, Date().timeIntervalSince(lastCheck) > 0.5,
              let px = CMSampleBufferGetImageBuffer(buf) else { return }
        lastCheck = Date()
        let req = VNClassifyImageRequest()
        try? VNImageRequestHandler(cvPixelBuffer: px, orientation: .right).perform([req])
        let match = (req.results ?? []).contains { r in
            r.confidence > 0.3 && Self.labels.contains { r.identifier.lowercased().contains($0) }
        }
        hits = match ? hits + 1 : 0
        DispatchQueue.main.async {
            if self.hits >= 3 { self.status = "✅ Gebetsmatte erkannt"; self.found = true }
            else { self.status = match ? "Erkenne… halte still" : "Richte die Kamera auf deine Gebetsmatte" }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView(); v.layer.session = session; v.layer.videoGravity = .resizeAspectFill; return v
    }
    func updateUIView(_ v: PreviewView, context: Context) {}
    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        override var layer: AVCaptureVideoPreviewLayer { super.layer as! AVCaptureVideoPreviewLayer }
    }
}
