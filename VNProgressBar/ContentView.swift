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
    @State var progress: Double = 0.0
    private let handler = VisionHandler()
    @State private var timer: Timer?
    @State private var timerRunning: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                HStack {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 64.0, height: 64.0)
                        .padding(.leading)
                    VStack(alignment: .leading) {
                        Text("Downloading software")
                            .bold()
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                            .padding(.trailing)
                        Text("About 2 millennia, 5 minutes remaining")
                            .font(.subheadline)
                    }
                }
                Button(action: {}) {
                    Text("Stop").padding(.horizontal, 4.0)
                }.padding(.trailing)
                .padding(.trailing, 5.0)
            }
        }.frame(width: 500.0, height: 135.0)
            .background(WindowPurity())
            .onAppear(perform: {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    if (timerRunning) {
                        progress += 0.01
                    } else if (progress > 0.0) {
                        progress -= 0.001
                    }
                }
                
                handler.bleh({ hasResults in
                    DispatchQueue.main.async {
                        self.timerRunning = hasResults
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
