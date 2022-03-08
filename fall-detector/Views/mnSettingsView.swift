//
//  mnSettingsView.swift
//  fall-detector
//
//  Created by Harry Wixley on 06/01/2022.
//

import SwiftUI
import CoreLocation

struct mnSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    @State var modelChoice: Int = 0
    @State var featureChoice = 0 //: Int = 0
    @State var lagChoice = 0 //: Int = 0
    @State var arcChoice = 0 //: Int = 0
    
    let featureChoices = [0: "All Polar", 1: "All CoreMotion", 2:"Polar ECG", 3:"Polar Accelerometer", 4:"All"]
    let featureNames = ["polar", "coremotion", "ecg", "acc", "all"]
    let lagChoices = [0: "0 ms", 1: "100 ms", 2: "200 ms"]
    let arcChoices = ["CNN", "LSTM"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MyColours.g0.edgesIgnoringSafeArea(.all)
                VStack {
                    Form {
                        /*Section("Fall Detection Model") {
                            CustLabel(title: "Type of Model:", value: "CNN")
                            CustLabel(title: "Features Used:", value: "All")
                            CustLabel(title: "Metric:", value: "high TPR")
                        }
                        Button("send text") {
                            sendMessage(contact: Person(id: "", name: "Harry", phone: "+4407484111141", isOnFirebase: true)) { response in
                                if response {
                                    print("fukc yea")
                                } else {
                                    print("shit no")
                                }
                            }
                        }*/
                        /*Section("Energy/Cellular Usage") {
                            Text("You can choose whether the ML fall detection model should be executed on your phone or in the cloud based on your energy/cellular requirements.\nExecuting on your phone results in higher energy consumption, and executing in the cloud results in higher cellular data consumption.")
                                .modifier(DefaultText(size: 18, color: MyColours.t1))
                            
                            HStack(spacing: 10) {
                                Text("Model Execution")
                                    .modifier(LabelText())
                                    .frame(width: 90, alignment: .trailing)
                                Picker("Model Execution", selection: $modelChoice) {
                                    Text("Cloud")
                                        .modifier(LabelText())
                                        .tag(0)
                                    Text("Phone")
                                        .modifier(LabelText())
                                        .tag(1)
                                }
                                .frame(height: 40)
                                .modifier(HPadding(pad: 5))
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .modifier(VPadding(pad: 5))
                        }*/
                        
                        Section("Model Settings") {
                            Text("You can choose custom model settings to play around with the performance of different models")
                                .modifier(DefaultText(size: 18, color: MyColours.t1))
                                      
                            HStack(spacing: 10) {
                                Text("Feature\nChoice")
                                    .modifier(SubtitleText())
                                    .frame(width: 70, alignment: .trailing)
                                Picker(selection: $featureChoice, label: Text("")) {
                                    ForEach(self.featureChoices.keys.sorted(), id: \.self) { key in
                                        Text(self.featureChoices[key]!).tag(key)
                                    }
                                }
                                .tint(MyColours.p0)
                            }
                            
                            HStack(spacing: 10) {
                                Text("Lag\nSize")
                                    .modifier(SubtitleText())
                                    .frame(width: 40, alignment: .trailing)
                                Picker(selection: $lagChoice, label: Text("")) {
                                    ForEach(self.lagChoices.keys.sorted(), id: \.self) { key in
                                        Text(self.lagChoices[key]!).tag(key)
                                    }
                                }
                                .tint(MyColours.p0)
                            }
                            
                            HStack(spacing: 10) {
                                Text("Architecture")
                                    .modifier(SubtitleText())
                                    .frame(width: 110, alignment: .trailing)
                                Picker(selection: $arcChoice, label: Text("")) {
                                    ForEach(0..<self.arcChoices.count) { idx2 in
                                        if idx2 < self.arcChoices.count {
                                            Text(self.arcChoices[idx2]).tag(idx2)
                                        }
                                     }
                                }
                                .tint(MyColours.p0)
                            }
                        }
                    }
                }
                .modifier(NavigationBarStyle(title: "Settings", page: .main, hideBackButton: false, appState: appState))
            }
            .modifier(BackgroundStack(appState: appState, backPage: .main))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            let locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            print(self.arcChoices[self.arcChoice])
            print(self.featureChoices[self.featureChoice]!)
            print(self.lagChoices[self.lagChoice]!)
            MyData.fallModel = Models().getModel(arch: self.arcChoices[self.arcChoice], features: self.featureChoices[self.featureChoice]!, lag: self.lagChoice*100)
        }
    }
}

struct mnSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        mnSettingsView()
    }
}

