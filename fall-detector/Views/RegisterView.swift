//
//  RegisterView.swift
//  fall-detector
//
//  Created by Harry Wixley on 01/01/2022.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    
    @State var email: String = ""
    @State var password1: String = ""
    @State var password2: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MyColours.b1.edgesIgnoringSafeArea(.all)
                VStack(spacing:40) {
                    HStack(spacing:10) {
                        VStack(spacing: 50) {
                            Text("")
                            Text("●")
                                .foregroundColor(password1 == "" ? .white : isValidPass(password1) && password1 == password2 ? .green : isValidPass(password1) ? .orange : .red)
                            Text("●")
                                .foregroundColor(password2 == "" ? .white : isValidPass(password1) && password1 == password2 ? .green : isValidPass(password2) ? .orange : .red)
                        }
                        .padding(.leading, 10)
                        
                        VStack {
                            Textfield(title: "Email", contentType: UITextContentType.emailAddress, keyboardType: UIKeyboardType.emailAddress, labelWidth: 90, output: $email)
                            SecureTextfield(title: "Password", labelWidth: 90, output: $password1)
                            SecureTextfield(title: "Re-enter Password", labelWidth: 90, output: $password2)
                        }
                    }
                    .padding(.top, 10)
                    
                    Button(action: {
                        if isValidEmail(email) && password1 == password2 && isValidPass(password1) {
                            self.appState.inappState.page = .main
                        }
                    }) {
                        MainButton(title: "Register", image: "")
                    }
                    .buttonStyle(ClassicButtonStyle(useGradient: true))
                }
                .modifier(NavigationBarStyle(title: "Register", page: .entry, hideBackButton: false, appState: appState))
            }
            .modifier(BackgroundStack(appState: appState, backPage: .entry))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
