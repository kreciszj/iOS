import SwiftUI

struct ContentView: View {
    @State private var counter: Int = 0
    @State private var inputText: String = ""
    @State private var submittedText: String = ""
    @State private var toggleOn: Bool = false
    @State private var sliderValue: Double = 50
    @State private var pickerSelection: String = "A"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .accessibilityIdentifier("globeImage")

                Text("Hello, world!")
                    .accessibilityIdentifier("greetingText")

                HStack {
                    Button {
                        counter += 1
                    } label: {
                        Text("Tap me")
                    }
                    .accessibilityIdentifier("tapButton")

                    Spacer()

                    Text("Counter: \(counter)")
                        .accessibilityIdentifier("counterLabel")
                }
                .padding(.horizontal)

                HStack {
                    TextField("Input..", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("inputField")

                    Button {
                        submittedText = inputText
                        inputText = ""
                    } label: {
                        Text("Submit")
                    }
                    .accessibilityIdentifier("submitButton")
                }
                .padding(.horizontal)

                Text("Submitted: \(submittedText)")
                    .accessibilityIdentifier("submittedLabel")


                Toggle("Toggle", isOn: $toggleOn)
                    .accessibilityIdentifier("toggleSwitch")
                    .padding(.horizontal)

                Text(toggleOn ? "Toggle is ON" : "Toggle is OFF")
                    .accessibilityIdentifier("toggleStatusLabel")

                VStack {
                    Slider(value: $sliderValue, in: 0...100)
                        .accessibilityIdentifier("volumeSlider")
                    Text("Volume: \(Int(sliderValue))")
                        .accessibilityIdentifier("volumeLabel")
                }
                .padding(.horizontal)

                VStack {
                    Picker("Option", selection: $pickerSelection) {
                        Text("A").tag("A")
                        Text("B").tag("B")
                        Text("C").tag("C")
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("segmentPicker")

                    Text("Selected: \(pickerSelection)")
                        .accessibilityIdentifier("selectionLabel")
                }
                .padding(.horizontal)

                NavigationLink {
                    DetailView()
                } label: {
                    Text("Open Detail")
                }
                .accessibilityIdentifier("openDetailButton")
                .padding(.top, 6)

                List {
                    ForEach(1...3, id: \.self) { i in
                        NavigationLink {
                            RowDetailView(row: i)
                        } label: {
                            HStack {
                                Text("Row \(i)")
                                    .accessibilityIdentifier("row_\(i)")
                                Spacer()
                            }
                        }
                    }
                }
                .accessibilityIdentifier("mainList")
                .frame(height: 200)
            }
            .navigationTitle("Main")
            .padding()
        }
    }
}

struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Screen")
                .accessibilityIdentifier("detailViewLabel")
            Spacer()
        }
        .padding()
    }
}

struct RowDetailView: View {
    let row: Int
    var body: some View {
        VStack {
            Text("Row \(row) Detail")
                .accessibilityIdentifier("rowDetailLabel_\(row)")
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
