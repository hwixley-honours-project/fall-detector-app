//
//  CustomStyles.swift
//  fall-detector
//
//  Created by Harry Wixley on 01/01/2022.
//

import Foundation
import UIKit
import SwiftUI


//MARK: Navigation

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}

struct NavigationBarStyle: ViewModifier {
    var title: String
    var superState: SuperState? = nil
    var onboardingState: OnboardingState? = nil
    var inappState: InAppState? = nil
    
    @ObservedObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(false)
            .background(NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = .blue
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white, .font : UIFont(name: fontfamily, size: 30)!]
            })
            .navigationBarItems(leading:
                Button(action: {
                if superState != nil {
                    appState.superState = superState!
                }
                if onboardingState != nil {
                    appState.onboardingState = onboardingState!
                }
                if inappState != nil {
                    appState.inappState = inappState!
                }
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.purple)
                    }
                })
    }
}

//MARK: Buttons

struct ClassicButtonStyle: ButtonStyle {
    var useGradient: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(useGradient ? MyColours.g0 : MyColours.gb)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
    }
}


//MARK: Textfields

struct DefaultTextfieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .modifier(VPadding(pad: 15))
            .modifier(HPadding(pad: 10))
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(MyColours.b2)
            ).padding(.trailing, 10)
    }
}
