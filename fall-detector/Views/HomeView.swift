//
//  HomeView.swift
//  fall-detector
//
//  Created by Harry Wixley on 02/01/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MyColours.g0.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ConnectionView(appState: self.appState)
                        .cornerRadius(20)
                    
                    if self.appState.inappState.connection == .connected {
                        DetectorView(appState: self.appState)
                            .cornerRadius(20)
                    }
                }
                .padding(.all, 10)
            }
            .modifier(BackgroundStack(appState: appState, backPage: nil))
            .modifier(NavigationBarStyle(title: "Home", page: .entry, hideBackButton: true, appState: appState))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState(inappState: InAppState()))
    }
}
