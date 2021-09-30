//
//  ContentView.swift
//  VNProgressBar
//
//  Created by Spotlight Deveaux on 2021-09-29.
//

import SwiftUI

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
    @State private var window: NSWindow?

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
                        ProgressView()
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
                VisionHandler().bleh()
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
