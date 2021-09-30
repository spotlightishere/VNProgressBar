//
//  ContentView.swift
//  VNProgressBar
//
//  Created by Spotlight Deveaux on 2021-09-29.
//

import SwiftUI
import Vision

// https://stackoverflow.com/a/63439982
struct WindowPurity: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            let window = view.window!

            // Hide buttons
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            // Hide title text
            window.titleVisibility = .hidden
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

struct ContentView: View {
    @State var progress: Double?
    let handler = VisionHandler()

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                HStack {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 64.0, height: 64.0)
                        .padding(.leading)
                    VStack(alignment: .leading) {
                        Text("Finding Software")
                            .bold()
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .padding(.trailing)
                        Text("About two millennia remaining")
                    }
                }
                Button(action: {}) {
                    Text("Stop")
                }
                .padding(.trailing)
            }
        }.frame(width: 500.0, height: 125.0)
            .background(WindowPurity())
            .onAppear(perform: {
                handler.bleh({ genericRequest, error in
                    if let nsError = error as NSError? {
                        print("Face Detection Error", nsError)
                        return
                    }
                    
                    guard let request = genericRequest as VNRequest? else {
                        print("Weird request issue")
                        return
                    }
                    

                    DispatchQueue.main.async {
                        guard let results = request.results as? [VNFaceObservation] else {
                            return
                        }

                        print(results)

                        if results.isEmpty {
                            progress = 0.5
                        } else {
                            progress = nil
                        }
                    }
                })
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
