//
//  ImageListPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Observation
import SwiftUI

@Observable
@MainActor
class ImageListPresenter {
    private let interactor: any ImageListInteractor
    private let router: any ImageListRouter

    private(set) var images = [ImageAsset]()
    private(set) var isLoadingMore = false
    private(set) var viewState: ImageListView.ViewState = .loading
    private(set) var layyoutId = 4

    private var emptyReason: ImageListView.ViewState.EmptyReason {
        searchText.isEmpty ? .noFetchedResults : .notFoundForString(searchText: searchText)
    }

    var searchText = ""

    init(interactor: any ImageListInteractor, router: any ImageListRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onSelectImage(_ image: ImageAsset) {
        router.showImageDetails(delegate: .init(image: image))
    }

    func loadInitialImages() async {
        viewState = .loading
        do {
            let fetchedImages = try await interactor.getInitialMessages(query: "dog")
            await MainActor.run {
                images = fetchedImages
            }
            viewState = .loaded
        } catch {
            viewState = .empty(emptyReason)
        }
    }

    func loadMoreData(image: ImageAsset) {
        Task {
            updateLoadingStatus(to: true)
            defer { updateLoadingStatus(to: false) }
            do {
                guard image.id == images.last?.id else { return }
                let moreImages = try await interactor.loadMoreImages(query: "dog", isPaginating: true)
                guard !moreImages.isEmpty else { return }
                await MainActor.run {
                    images.append(contentsOf: moreImages)
                }
            } catch {
//                interactor.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }

    private func updateLoadingStatus(to isLoading: Bool) {
        withAnimation {
            isLoadingMore = isLoading
        }
    }


//    enum Event: LoggableEvent {
//        case signOutStart
//        case signOutSuccess
//        case signOutFail(error: Error)
//        case deleteAccountStart
//        case deleteAccountStartConfirm
//        case deleteAccountSuccess
//        case deleteAccountFail(error: Error)
//        case createAccountPressed
//        case contactUsPressed
//        case ratingsPressed
//        case ratingsYesPressed
//        case ratingsNoPressed
//
//        var eventName: String {
//            switch self {
//            case .signOutStart:                 return "SettingsView_SignOut_Start"
//            case .signOutSuccess:               return "SettingsView_SignOut_Success"
//            case .signOutFail:                  return "SettingsView_SignOut_Fail"
//            case .deleteAccountStart:           return "SettingsView_DeleteAccount_Start"
//            case .deleteAccountStartConfirm:    return "SettingsView_DeleteAccount_StartConfirm"
//            case .deleteAccountSuccess:         return "SettingsView_DeleteAccount_Success"
//            case .deleteAccountFail:            return "SettingsView_DeleteAccount_Fail"
//            case .createAccountPressed:         return "SettingsView_CreateAccount_Pressed"
//            case .contactUsPressed:             return "SettingsView_ContactUs_Pressed"
//            case .ratingsPressed:               return "SettingsView_Ratings_Pressed"
//            case .ratingsYesPressed:            return "SettingsView_RatingsYes_Pressed"
//            case .ratingsNoPressed:             return "SettingsView_RatingsNo_Pressed"
//            }
//        }
//
//        var parameters: [String: Any]? {
//            switch self {
//            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
//                return error.eventParameters
//            default:
//                return nil
//            }
//        }
//
//        var type: LogType {
//            switch self {
//            case .signOutFail, .deleteAccountFail:
//                return .severe
//            default:
//                return .analytic
//            }
//        }
//    }

}
