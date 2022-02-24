//
//  CustomViews.swift
//  fall-detector
//
//  Created by Harry Wixley on 01/01/2022.
//

import Foundation
import SwiftUI
import Charts
import Shapes
import MessageUI


//MARK: Input fields

struct Warning : View {
    let text: String
    
    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .foregroundColor(Color(UIColor.systemPink))
    }
}

struct CustLabel : View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .modifier(SubtitleText())
                .multilineTextAlignment(.leading)
            Text(value)
                .modifier(LabelText())
        }
    }
}


struct Textfield : View {
    let title: String
    let contentType : UITextContentType
    let keyboardType : UIKeyboardType
    let labelWidth: CGFloat
    var placeholder: String = "Tap to enter..."
    
    @Binding var output : String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .modifier(LabelText())
                .frame(width: labelWidth, alignment: .trailing)
            
            TextField(placeholder, text: $output)
                .onSubmit {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .textFieldStyle(DefaultTextfieldStyle())
                .textContentType(contentType)
                .keyboardType(keyboardType)
        }
        .frame(height: 60)
    }
}

struct SecureTextfield : View {
    let title: String
    let labelWidth: CGFloat
    
    @Binding var output : String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .modifier(LabelText())
                .frame(width: labelWidth, alignment: .trailing)
            
            SecureField("Tap to enter...", text: $output)
                .onSubmit {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .textFieldStyle(DefaultTextfieldStyle())
                .textContentType(.password)
        }
        .frame(height: 60)
    }
}



struct MainButton : View {
    let title: String
    let image: String
    var color: Color? = nil
    
    var body: some View {
        if image == "" {
            Text(title)
                .modifier(ClassicButtonText(color: color))
        } else {
            Label(title, systemImage: image)
                .modifier(ClassicButtonText(color: color))
        }
    }
}

struct SubButton : View {
    let title: String
    var width: CGFloat? = nil
    var image: String? = nil
    
    var body: some View {
        if image == nil {
            Text(title)
                .modifier(ClassicSubButtonText(width: width ?? UIScreen.screenWidth - 20))
        } else {
            Label(title, systemImage: image!)
                .modifier(ClassicSubButtonText(width: width ?? UIScreen.screenWidth - 20))
        }
    }
}

struct ConnectionView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var polarManager : PolarBleSdkManager
    
    var body: some View {
        VStack(spacing: 15) {
            let image = (self.polarManager.deviceConnectionState == .connected(self.polarManager.deviceId)) ? "antenna.radiowaves.left.and.right" : (self.polarManager.deviceConnectionState == .disconnected) ? "antenna.radiowaves.left.and.right.slash" : self.appState.inappState.connection == .searching ? "magnifyingglass" : "exclamationmark.circle"
            let statusMessage = (self.polarManager.deviceConnectionState == .connected(self.polarManager.deviceId)) ? "Connected" : (self.polarManager.deviceConnectionState == .disconnected) ? "Disconnected" : self.appState.inappState.connection == .searching ? "Searching for your device..." : "We could not find your device. Please make sure it is turned on and try again."
            
            Text("Polar H10 Status:")
                .modifier(DefaultText(size: 25))
                .multilineTextAlignment(.center)
            
            Divider()
            
            Label(statusMessage, systemImage: image)
                .modifier(DefaultText(size: 22))
                .multilineTextAlignment(.center)
            
            if self.appState.inappState.connection == .searching && self.polarManager.deviceConnectionState != .connected(self.polarManager.deviceId) {
                ProgressView()
                    .padding(.bottom, 10)
            } else {
                Button(action: {
                    if self.polarManager.deviceConnectionState == .connected(self.polarManager.deviceId) {
                        self.appState.inappState.connection = .disconnected
                        polarManager.disconnectFromDevice()
                    } else if self.polarManager.deviceConnectionState == .disconnected { //appState.inappState.connection == .disconnected || appState.inappState.connection == .retry {
                        connect()
                    }
                }) {
                    SubButton(title: self.polarManager.deviceConnectionState == .connected(MyData.polarDeviceID) ? "Disconnect" : self.polarManager.deviceConnectionState == .disconnected ? "Connect" : "Try again", width: UIScreen.screenWidth - 40)
                }
                .buttonStyle(ClassicButtonStyle(useGradient: true))
            }
        }
        .frame(width: UIScreen.screenWidth - 20)
        .modifier(VPadding(pad: 10))
        .background(MyColours.b1)
    }
    
    func connect() {
        self.appState.inappState.connection = .searching
        
        polarManager.autoConnect()
        
        var time = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            time += 2
            
            if self.polarManager.deviceConnectionState == .connected(MyData.polarDeviceID) {
                self.appState.inappState.connection = .connected
            } else if time == 10 {
                self.appState.inappState.connection = .retry
                timer.invalidate()
            }
        }
    }
}

struct DetectorView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var coremotionData: CoreMotionData
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Toggle(isOn: $appState.inappState.fallDetection) {
                Label("Fall detection is " + (self.appState.inappState.fallDetection ? "ON" : "OFF"), systemImage: "waveform.path.ecg")
            }
            .onChange(of: appState.inappState.fallDetection, perform: { value in
                if !value {
                    self.showAlert = true
                } else {
                    self.coremotionData.start()
                }
            })
            .alert("Are you sure you want to turn off fall detection?", isPresented: $showAlert) {
                Button("Yes", role: .destructive) {
                    self.appState.inappState.fallDetection = false
                    self.coremotionData.stop()
                }
                .modifier(ClassicButtonText())
                Button("No, cancel", role: .cancel) {
                    self.showAlert = false
                    self.appState.inappState.fallDetection = true
                }
                .modifier(ClassicButtonText())
            }
            .labelStyle(CustomLabelStyle())
            .modifier(DefaultText(size: 30))
            .modifier(HPadding(pad: 10))
            .tint(MyColours.p0)
        }
        .frame(width: UIScreen.screenWidth - 20, height: 100)
        .modifier(VPadding(pad: 10))
        .background(MyColours.b1)
    }
}

struct ContactView: View {
    let contact: Person
    
    var body: some View {
        HStack {
            Text(contact.name)
                .modifier(SubtitleText())
                .multilineTextAlignment(.leading)
            Label(contact.phone, systemImage: "phone.fill")
                .modifier(LabelText())
        }
    }
}

struct LiveMovementView: View {
    @ObservedObject var appState : AppState
    @ObservedObject var polarManager : PolarBleSdkManager
    
    @State var displayStats = true
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button(action: {
                    self.displayStats = !self.displayStats
                }) {
                    Image(systemName: self.displayStats ? "chevron.down" : "chevron.right")
                        .scaledToFit()
                        .foregroundColor(MyColours.p0)
                        .padding(.leading, 10)
                }
                
                Spacer()
                
                Text(self.polarManager.deviceId)
                    .modifier(DefaultText(size: 18))
                    .frame(alignment: .center)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "battery.\(String(self.polarManager.battery))")
                    Text("\(self.polarManager.battery)%")
                        .modifier(DefaultText(size: 18))
                }
                .padding(.trailing, 10)
            }
            .modifier(VPadding(pad: 5))
            
            if self.displayStats {

                Divider()
                
                Spacer()
                
                
                if !self.polarManager.ecg.isEmpty {
                    let maxEcg = (self.polarManager.ecg.max() ?? 1) > -1*(self.polarManager.ecg.min() ?? 1) ? (self.polarManager.ecg.max() ?? 1) : (self.polarManager.ecg.min() ?? 1)
                    let data = self.polarManager.ecg.map { $0 / Double(maxEcg) }
                    
                    Chart(data: data)
                        .chartStyle(LineChartStyle(.quadCurve, lineColor: .red, lineWidth: 1))
                        .frame(width: UIScreen.screenWidth - 20, height: 60)
                    
                    Spacer()
                    
                    if self.polarManager.l_hr != 0 {
                        Text("\(Int(self.polarManager.l_hr)) BPM")
                            .modifier(DefaultText(size: 21))
                    }
                    
                    Spacer()
                    
                } else if self.polarManager.ecgStreamFail ?? false {
                    Text("ECG data stream failed :(")
                        .modifier(DefaultText(size: 21))
                    
                    Spacer()
                    
                    Button(action: {
                        if !self.polarManager.ecgEnabled {
                            self.polarManager.ecgToggle()
                        }
                        if !self.polarManager.accEnabled {
                            self.polarManager.accToggle()
                        }
                        self.polarManager.ecgStreamFail = nil
                    }) {
                        SubButton(title: "Try again", width: UIScreen.screenWidth - 40)
                    }
                    .buttonStyle(ClassicButtonStyle(useGradient: true))
                    
                } else {
                    Text("Retrieving ECG data...")
                        .modifier(DefaultText(size: 21))
                    ProgressView()
                        .padding(.bottom, 10)
                    Spacer()
                }
            }
        }
        .onAppear(perform: {
            self.polarManager.isRecording = true
        })
        .frame(width: UIScreen.screenWidth - 20)
        .modifier(VPadding(pad: 10))
        .background(MyColours.b1)
        .frame(maxWidth: .infinity)
    }
}

struct StatView: View {
    @ObservedObject var appState : AppState
    @ObservedObject var polarManager : PolarBleSdkManager
    
    var body: some View {
        VStack {
            
        }
        .frame(width: UIScreen.screenWidth - 20)
        .modifier(VPadding(pad: 10))
        .background(MyColours.b1)
        .frame(maxWidth: .infinity)
    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden && !remove {
            self.hidden()
        } else {
            self
        }
    }
}


