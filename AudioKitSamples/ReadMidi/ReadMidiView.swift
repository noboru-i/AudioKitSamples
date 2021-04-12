//
//  ReadMidiView.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI
import AudioKit

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02X", $0) }.joined()
    }
}

struct ReadMidiView: View, MyProtocol {
    var controller = ReadMidiController()

    @State private var data: MidiData = MidiData(
        bpm: 60,
        tracks: []
    )
    @State var isShowingPicker = false

    func myFunc(_ url: URL) {
        data = controller.setup(path: url.absoluteString)
    }

    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                Button("Load from file") {
                    isShowingPicker = true
                }
                .sheet(isPresented: $isShowingPicker) {
                    FilePickerController(callback: self)
                }
                Text("\(data.bpm) bpm")
                ForEach(data.tracks.indices, id: \.self) { index in
                    let track = data.tracks[index]
                    Text("Track \(index + 1)")
                    
                    VStack(alignment: .leading) {
                        ForEach((track.eventData ?? []).indices, id: \.self) { index in
                            let message = debugEventData(track.eventData![index])
                            Text(message)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            data = controller.setup(path: Bundle.main.path(forResource: "sample", ofType: "mid") ?? "")
        }
        .onDisappear {
            controller.dispose()
        }

    }
}

struct ReadMidiView_Previews: PreviewProvider {
    static var previews: some View {
        ReadMidiView()
    }
}

protocol MyProtocol {
    func myFunc(_ url: URL)
}

struct FilePickerController: UIViewControllerRepresentable {
    var callback: MyProtocol
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
        // Update the controller
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("Making the picker")
        let controller = UIDocumentPickerViewController(documentTypes: [String("public.data")], in: .open)
        
        controller.delegate = context.coordinator
        print("Setup the delegate \(context.coordinator)")
        
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController
        
        init(_ pickerController: FilePickerController) {
            self.parent = pickerController
            print("Setup a parent")
            print("Callback: \(parent.callback)")
        }
       
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("2 Selected a document: \(urls[0])")
            parent.callback.myFunc(urls[0])
        }
        
        func documentPickerWasCancelled() {
            print("Document picker was thrown away :(")
        }
        
        deinit {
            print("Coordinator going away")
        }
    }
}

class ReadMidiController {
    private var sequencer: AKAppleSequencer!
    
    func setup(path: String) -> MidiData {
        sequencer = AKAppleSequencer(fromURL: URL(fileURLWithPath: path))
        print("tempo \(Int(sequencer.getTempo(at: 0)))")

        return MidiData(
            bpm: Int(sequencer.getTempo(at: 0)),
            tracks: sequencer.tracks
        )
    }

    func dispose() {
    }
}

struct MidiData {
    var bpm: Int
    var tracks: [AudioKit.AKMusicTrack]
}

func typeToName(_ type: MusicEventType) -> String {
    switch type {
    case kMusicEventType_MIDIChannelMessage:
        return "MIDIChannelMessage"
    case kMusicEventType_MIDINoteMessage:
        return "MIDINoteMessage"
    default:
        return "unknown \(type)"
    }
}

func debugEventData(_ event: AppleMIDIEvent) -> String {
    switch event.type {
    case kMusicEventType_MIDINoteMessage:
        let data = UnsafePointer<MIDINoteMessage>(event.data?.assumingMemoryBound(to: MIDINoteMessage.self))
        guard let channel = data?.pointee.channel,
            let note = data?.pointee.note,
            let velocity = data?.pointee.velocity,
            let dur = data?.pointee.duration else {
                return "Problem with raw midi note message"
        }
        return "Note @: \(formatTime(event.time)) - note: \(note) - velocity: \(velocity) - duration: \(formatDuration(dur)) - CH: \(channel)"
    case kMusicEventType_Meta:
        let data = UnsafePointer<MIDIMetaEvent>(event.data?.assumingMemoryBound(to: MIDIMetaEvent.self))
        guard let midiData = data?.pointee.data,
            let length = data?.pointee.dataLength,
            let type = data?.pointee.metaEventType else {
                return "Problem with raw midi meta message"
        }
        return "Meta @ \(formatTime(event.time)) - size: \(length) - type: \(type.toH()) - data: \(midiData)"
    case kMusicEventType_MIDIChannelMessage:
        let data = UnsafePointer<MIDIChannelMessage>(event.data?.assumingMemoryBound(to: MIDIChannelMessage.self))
        guard let data1 = data?.pointee.data1,
            let data2 = data?.pointee.data2,
            let statusData = data?.pointee.status else {
                return "Problem with raw midi channel message"
        }
        if let statusType = AKMIDIStatus(byte: statusData)?.type {
            switch statusType {
            case .programChange:
                return "Program Change @ \(formatTime(event.time)) - program: \(data1) - CH: \(statusData.lowBit)"
            default:
                return "Channel Message @ \(formatTime(event.time)) - data1: \(data1) - data2: \(data2) - status: \(statusType)"
            }
        }
    default:
        return "Other Event @ \(formatTime(event.time))"
    }
    return ""
}

func formatTime(_ time: MusicTimeStamp) -> String {
    return String(format: "%0.2f", time)
}

func formatDuration(_ duration: Float32) -> String {
    return String(format: "%0.3f", duration)
}

extension UInt8 {
    func toH() -> String {
        return String(format: "%02X", self)
    }
}

