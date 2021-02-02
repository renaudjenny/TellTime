import SwiftUI
import Combine

struct SpeechRecognitionButton: View {
    @EnvironmentObject var speechRecognitionEngine: SpeechRecognitionEngine
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
        .onReceive(speechRecognitionEngine.newUtterance) { utterance in
            recognizedUtterance = utterance
        }
    }

    private func onTapped() {
        guard speechRecognitionEngine.recognitionStatus != .recording
        else {
            speechRecognitionEngine.stopRecording()
            return
        }

        switch speechRecognitionEngine.authorizationStatus {
        case .none:
            speechRecognitionEngine.requestAuthorization {
                DispatchQueue.main.async(execute: onTapped)
            }
        case .denied:
            // Display an alert to the user and lead them to the app configuration
            print("Should display an alert for denied!")
        case .restricted:
            print("Should display an alert for restricted!")
        case .notDetermined:
            print("Should display an alert for not determined!")
        default: break
        }

        guard speechRecognitionEngine.authorizationStatus == .authorized
        else { return }

        do {
            try speechRecognitionEngine.startRecording()
        } catch {
            print(error)
            // FIXME: Should also notify the button state
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
