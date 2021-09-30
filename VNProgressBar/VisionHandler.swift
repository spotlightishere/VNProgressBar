//
//  VisionHandler.swift
//  VisionHandler
//
//  Created by Spotlight Deveaux on 2021-09-29.
//

import AVFoundation
import Foundation
import Vision

class VisionHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    var captureDevice: AVCaptureDevice?
    var captureDeviceResolution = CGSize()
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?

    // MARK: AVCapture Setup

    func bleh() {
        session = setupAVCaptureSession()
        session?.startRunning()
    }

    /// - Tag: CreateCaptureSession
    func setupAVCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        do {
            let inputDevice = try configureFrontCamera(for: captureSession)
            configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
            captureSession.sessionPreset = .high
            return captureSession
        } catch let executionError as NSError {
            print("An error occurred:", executionError)
        } catch {
            print("An unexpected failure has occured")
        }

        teardownAVCapture()
        return nil
    }

    func teardownAVCapture() {
        videoDataOutput = nil
        videoDataOutputQueue = nil
    }

    func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        if let device = AVCaptureDevice.default(for: .video) {
            // Attempt to obtain video dimensions first.
            let formatDescription = device.activeFormat.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            let deviceResolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))

            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }

                return (device, deviceResolution)
            }
        }

        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }

    /// - Tag: CreateSerialDispatchQueue
    func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "space.joscomputing.VNProgressBar.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }

        videoDataOutput.connection(with: .video)!.isEnabled = true

        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue

        captureDevice = inputDevice
        captureDeviceResolution = resolution
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    /// - Tag: PerformRequests
    // Handle delegate method callback on receiving a sample buffer.
    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        print("hi")

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }

        let requests: [VNRequest] = [VNDetectFaceRectanglesRequest(completionHandler: handleDetectedFaces)]
        // We're on a Mac, so our orientation is (hopefully) always up.
        // Watch some sort of new Mac come out and ruin this innocent assumption in a few years
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .up,
                                                        options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
            }
        }
    }

    func handleDetectedFaces(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print("Face Detection Error", nsError)
            return
        }

        DispatchQueue.main.async {
            guard let results = request?.results as? [VNFaceObservation] else {
                return
            }
            print(results)
        }
    }
}
