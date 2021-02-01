import SwiftUI
import Speech

struct SpeechRecognitionButton: View {
    @ObservedObject var speechRecognitionEngine = SpeechRecognitionEngine()
    @Binding var recognizedUtterance: String?

    var body: some View {
        Button(action: onTapped) {
            image
                .padding()
                .accentColor(.white)
                .background(Color.red)
                .cornerRadius(8)
        }
        .padding()
        .accessibilityLabel(label)
        .onReceive(speechRecognitionEngine.$recognizedUtterance) { utterance in
            recognizedUtterance = utterance
        }
    }

    private func onTapped() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .denied:
                // Display an alert to the user and lead them to the app configuration
                print("Should display an alert for denied!")
            case .restricted:
                print("Should display an alert for restricted!")
            case .notDetermined:
                print("Not yet authorized!")
            default: break
            }

            guard authStatus == .authorized
            else { return }

            DispatchQueue.main.async {
                do {
                    try speechRecognitionEngine.startRecording()
                } catch {
                    print(error)
                    // FIXME: Should also notify the button state
                }
            }
        }
    }

    private var image: Image {
        switch speechRecognitionEngine.recognitionStatus {
        case .notStarted, .stopped: return Image(systemName: "mouth.fill")
        case .recording: return Image(systemName: "waveform")
        case .stopping: return Image(systemName: "stop")
        }
    }

    private var label: Text {
        switch speechRecognitionEngine.recognitionStatus {
        case .notStarted, .stopped: return Text("Speech Recognition ready")
        case .recording: return Text("Speech Recognition recording...")
        case .stopping: return Text("Speech Recognition stopping...")
        }
    }
}
