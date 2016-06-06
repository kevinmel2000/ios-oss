import Foundation
import XCTest
import ReactiveCocoa
import Result
import KsApi
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import KsApi_TestHelpers

internal final class SettingsViewModelTests: TestCase {
  let vm = SettingsViewModel()
  let backingsSelected = TestObserver<Bool, NoError>()
  let commentsSelected = TestObserver<Bool, NoError>()
  let creatorNotificationsHidden = TestObserver<Bool, NoError>()
  let followerSelected = TestObserver<Bool, NoError>()
  let friendActivitySelected = TestObserver<Bool, NoError>()
  let gamesNewsletterOn = TestObserver<Bool, NoError>()
  let goToAppStoreRating = TestObserver<String, NoError>()
  let goToFindFriends = TestObserver<Void, NoError>()
  let goToHelpType = TestObserver<HelpType, NoError>()
  let goToManageProjectNotifications = TestObserver<Void, NoError>()
  let happeningNewsletterOn = TestObserver<Bool, NoError>()
  let logout = TestObserver<Void, NoError>()
  let mobileBackingsSelected = TestObserver<Bool, NoError>()
  let mobileCommentsSelected = TestObserver<Bool, NoError>()
  let mobileFollowerSelected = TestObserver<Bool, NoError>()
  let mobileFriendActivitySelected = TestObserver<Bool, NoError>()
  let mobilePostLikesSelected = TestObserver<Bool, NoError>()
  let mobileUpdatesSelected = TestObserver<Bool, NoError>()
  let postLikesSelected = TestObserver<Bool, NoError>()
  let projectNotificationsCount = TestObserver<String, NoError>()
  let promoNewsletterOn = TestObserver<Bool, NoError>()
  let showConfirmLogoutPrompt = TestObserver<(message: String, cancel: String, confirm: String), NoError>()
  let showOptInPrompt = TestObserver<String, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updatesSelected = TestObserver<Bool, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()
  let weeklyNewsletterOn = TestObserver<Bool, NoError>()
  let versionText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backingsSelected.observe(backingsSelected.observer)
    self.vm.outputs.commentsSelected.observe(commentsSelected.observer)
    self.vm.outputs.creatorNotificationsHidden.observe(creatorNotificationsHidden.observer)
    self.vm.outputs.followerSelected.observe(followerSelected.observer)
    self.vm.outputs.friendActivitySelected.observe(friendActivitySelected.observer)
    self.vm.outputs.gamesNewsletterOn.observe(gamesNewsletterOn.observer)
    self.vm.outputs.goToAppStoreRating.observe(goToAppStoreRating.observer)
    self.vm.outputs.goToFindFriends.observe(goToFindFriends.observer)
    self.vm.outputs.goToHelpType.observe(goToHelpType.observer)
    self.vm.outputs.goToManageProjectNotifications.observe(goToManageProjectNotifications.observer)
    self.vm.outputs.happeningNewsletterOn.observe(happeningNewsletterOn.observer)
    self.vm.outputs.logout.observe(logout.observer)
    self.vm.outputs.mobileBackingsSelected.observe(mobileBackingsSelected.observer)
    self.vm.outputs.mobileCommentsSelected.observe(mobileCommentsSelected.observer)
    self.vm.outputs.mobileFollowerSelected.observe(mobileFollowerSelected.observer)
    self.vm.outputs.mobileFriendActivitySelected.observe(mobileFriendActivitySelected.observer)
    self.vm.outputs.mobilePostLikesSelected.observe(mobilePostLikesSelected.observer)
    self.vm.outputs.mobileUpdatesSelected.observe(mobileUpdatesSelected.observer)
    self.vm.outputs.postLikesSelected.observe(postLikesSelected.observer)
    self.vm.outputs.projectNotificationsCount.observe(projectNotificationsCount.observer)
    self.vm.outputs.promoNewsletterOn.observe(promoNewsletterOn.observer)
    self.vm.outputs.showConfirmLogoutPrompt.observe(showConfirmLogoutPrompt.observer)
    self.vm.outputs.showOptInPrompt.observe(showOptInPrompt.observer)
    self.vm.outputs.unableToSaveError.observe(unableToSaveError.observer)
    self.vm.outputs.updatesSelected.observe(updatesSelected.observer)
    self.vm.outputs.updateCurrentUser.observe(updateCurrentUser.observer)
    self.vm.outputs.weeklyNewsletterOn.observe(weeklyNewsletterOn.observer)
    self.vm.outputs.versionText.observe(versionText.observer)
  }

  func testCreatorNotificationsHidden() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.creatorNotificationsHidden.assertValues([true], "Creator notifications hidden from non-creator.")
  }

  func testCreatorNotificationsShown() {
    let creator = User.template |> User.lens.stats.createdProjectsCount .~ 2

    withEnvironment(apiService: MockService(fetchUserSelfResponse: creator)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: creator))

      self.vm.inputs.viewDidLoad()
      self.creatorNotificationsHidden.assertValues([false], "Creator notifications shown for creator.")
    }
  }

  func testCreatorNotificationsTapped() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 2
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.backingsSelected.assertValues([false], "All creator notifications turned off as test default.")
    self.commentsSelected.assertValues([false])
    self.mobileBackingsSelected.assertValues([false])
    self.mobileCommentsSelected.assertValues([false])
    self.mobilePostLikesSelected.assertValues([false])
    self.postLikesSelected.assertValues([false])

    self.vm.inputs.mobileBackingsTapped(selected: true)
    self.mobileBackingsSelected.assertValues([false, true], "Mobile backings notifications on.")
    self.backingsSelected.assertValues([false], "Backings notifications remain unchanged.")

    self.vm.inputs.mobileBackingsTapped(selected: false)
    self.mobileBackingsSelected.assertValues([false, true, false], "Mobile backings notifications off.")
    self.mobileCommentsSelected.assertValues([false], "Mobile comments notifications remain unchanged.")

    self.vm.inputs.mobileBackingsTapped(selected: false)
    self.mobileBackingsSelected.assertValues([false, true, false],
                                             "Mobile backings notifications remain off.")

    self.vm.inputs.backingsTapped(selected: true)
    self.vm.inputs.commentsTapped(selected: true)
    self.vm.inputs.mobileBackingsTapped(selected: true)
    self.vm.inputs.mobileCommentsTapped(selected: true)
    self.vm.inputs.mobilePostLikesTapped(selected: true)
    self.vm.inputs.postLikesTapped(selected: true)

    self.backingsSelected.assertValues([false, true], "All creator notifications toggled on.")
    self.commentsSelected.assertValues([false, true])
    self.mobileBackingsSelected.assertValues([false, true, false, true])
    self.mobileCommentsSelected.assertValues([false, true])
    self.mobilePostLikesSelected.assertValues([false, true])
    self.postLikesSelected.assertValues([false, true])
    self.unableToSaveError.assertValueCount(0, "Error did not happen.")
  }

  func testGoToAppStoreRating() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.rateUsTapped()

    XCTAssertEqual(["Settings View", "App Store Rating Open"], self.trackingClient.events)
    self.goToAppStoreRating.assertValueCount(1, "Go to App Store.")
  }

  func testGoToFindFriends() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.findFriendsTapped()
    self.goToFindFriends.assertValueCount(1, "Go to Find Friends screen.")
  }

  func testGoToHelpType() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.helpTypeTapped(helpType: .Contact)
    self.goToHelpType.assertValues([.Contact], "Go to compose contact email.")
    XCTAssertEqual(["Settings View", "Contact Email Open"], self.trackingClient.events)

    self.vm.inputs.helpTypeTapped(helpType: .Cookie)
    self.goToHelpType.assertValues([.Contact, .Cookie], "Go to Cookie Policy screen.")

    self.vm.inputs.helpTypeTapped(helpType: .FAQ)
    self.goToHelpType.assertValues([.Contact, .Cookie, .FAQ], "Go to FAQ screen.")

    self.vm.inputs.helpTypeTapped(helpType: .HowItWorks)
    self.goToHelpType.assertValues([.Contact, .Cookie, .FAQ, .HowItWorks],
                                   "Go to How Kickstarter Works screen.")

    self.vm.inputs.helpTypeTapped(helpType: .Privacy)
    self.goToHelpType.assertValues([.Contact, .Cookie, .FAQ, .HowItWorks, .Privacy],
                                   "Go to Privacy Policy screen.")

    self.vm.inputs.helpTypeTapped(helpType: .Terms)
    self.goToHelpType.assertValues([.Contact, .Cookie, .FAQ, .HowItWorks, .Privacy, .Terms],
                                   "Go to Terms of Use screen.")
  }

  func testGoToManageProjectNotifications() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.manageProjectNotificationsTapped()
    self.goToManageProjectNotifications.assertValueCount(1, "Go to manage project notifications screen.")
  }

  func testNewslettersToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.gamesNewsletterOn.assertValues([false])
    self.happeningNewsletterOn.assertValues([false])
    self.promoNewsletterOn.assertValues([false])
    self.weeklyNewsletterOn.assertValues([false])
    XCTAssertEqual(["Settings View"], self.trackingClient.events)

    self.vm.inputs.gamesNewsletterTapped(on: true)
    self.gamesNewsletterOn.assertValues([false, true], "Games newsletter toggled on.")
    XCTAssertEqual(["Settings View", "Newsletter Subscribe"], self.trackingClient.events)

    self.vm.inputs.happeningNewsletterTapped(on: true)
    self.happeningNewsletterOn.assertValues([false, true], "Happening newsletter toggled on.")

    self.vm.inputs.promoNewsletterTapped(on: true)
    self.promoNewsletterOn.assertValues([false, true], "Promo newsletter toggled on.")

    self.vm.inputs.weeklyNewsletterTapped(on: true)
    self.weeklyNewsletterOn.assertValues([false, true], "Weekly newsletter toggled on.")

    self.vm.inputs.gamesNewsletterTapped(on: false)
    self.gamesNewsletterOn.assertValues([false, true, false], "Games newsletter toggled off.")

    self.vm.inputs.happeningNewsletterTapped(on: false)
    self.happeningNewsletterOn.assertValues([false, true, false], "Happening newsletter toggled off.")

    self.vm.inputs.promoNewsletterTapped(on: false)
    self.promoNewsletterOn.assertValues([false, true, false], "Promo newsletter toggled off.")

    self.vm.inputs.weeklyNewsletterTapped(on: false)
    self.weeklyNewsletterOn.assertValues([false, true, false], "Weekly newsletter toggled off.")
    XCTAssertEqual(["Settings View", "Newsletter Subscribe", "Newsletter Subscribe", "Newsletter Subscribe",
                    "Newsletter Subscribe", "Newsletter Unsubscribe", "Newsletter Unsubscribe",
                    "Newsletter Unsubscribe", "Newsletter Unsubscribe"],
                   self.trackingClient.events)
  }

  func testOptInPromptNotShown() {
    withEnvironment(countryCode: "US") {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.happeningNewsletterTapped(on: true)
      self.showOptInPrompt.assertDidNotEmitValue("Non-German locale does not require double opt-in.")
    }
  }

  func testProjectNotificationsCount() {
    let user = User.template |> User.lens.stats.backedProjectsCount .~ 42
    withEnvironment(apiService: MockService(fetchUserSelfResponse: user)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "dabbadoo", user: user))
      self.vm.inputs.viewDidLoad()
      self.projectNotificationsCount.assertValues(["42"], "Project notifications count emits.")
    }
  }

  func testProjectUpdateNotifications() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.updatesSelected.assertValues([false], "Project update notifications turned off as test default.")
    self.mobileUpdatesSelected.assertValues([false])

    self.vm.inputs.updatesTapped(selected: true)
    self.vm.inputs.mobileUpdatesTapped(selected: true)

    self.updatesSelected.assertValues([false, true], "Project update notifications toggled on.")
    self.mobileUpdatesSelected.assertValues([false, true])
  }

  func testLogoutFlow() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.logoutTapped()
    self.showConfirmLogoutPrompt.assertValueCount(1, "Should show confirm logout prompt.")
    self.logout.assertDidNotEmitValue("User should not actually be logged out yet.")

    self.vm.inputs.logoutConfirmed()
    self.logout.assertValueCount(1, "User should be logged out.")
  }

  func testShowOptInPrompt() {
    withEnvironment(config: ConfigFactory.deConfig) {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.gamesNewsletterTapped(on: true)
      self.showOptInPrompt.assertValueCount(1, "German locale requires double opt-in.")

      self.vm.inputs.gamesNewsletterTapped(on: false)
      self.showOptInPrompt.assertValueCount(1, "Prompt not shown again when newsletter toggled off.")
    }
  }

  func testSocialNotificationsToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.followerSelected.assertValues([false], "All social notifications turned off as test default.")
    self.friendActivitySelected.assertValues([false])
    self.mobileFollowerSelected.assertValues([false])
    self.mobileFriendActivitySelected.assertValues([false])

    self.vm.inputs.followerTapped(selected: true)
    self.vm.inputs.friendActivityTapped(selected: true)
    self.vm.inputs.mobileFollowerTapped(selected: true)
    self.vm.inputs.mobileFriendActivityTapped(selected: true)

    self.followerSelected.assertValues([false, true], "All social notifications toggled on.")
    self.friendActivitySelected.assertValues([false, true])
    self.mobileFollowerSelected.assertValues([false, true])
    self.mobileFriendActivitySelected.assertValues([false, true])

    self.vm.inputs.mobileFollowerTapped(selected: false)
    self.vm.inputs.mobileFriendActivityTapped(selected: false)

    self.mobileFollowerSelected.assertValues([false, true, false], "Mobile social notifications toggled off.")
    self.mobileFriendActivitySelected.assertValues([false, true, false])
  }

  func testUpdateError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to save."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(updateUserSelfError: error)) {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()

      self.updatesSelected.assertValues([false], "Updates notifications turned off as default.")

      self.vm.inputs.updatesTapped(selected: true)

      self.updatesSelected.assertValues([false, true], "Updates immediately flipped to true on tap.")

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1, "Updating user errored.")
      self.updatesSelected.assertValues([false, true, false], "Did not successfully save preference.")
    }
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.gamesNewsletterTapped(on: true)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")

    self.vm.inputs.commentsTapped(selected: true)
    self.updateCurrentUser.assertValueCount(4, "User should be updated.")
  }

  func testVersionTextEmits() {
    self.vm.inputs.viewDidLoad()
    XCTAssertEqual(["Settings View"], self.trackingClient.events)
    self.versionText.assertValues(["Version \(self.mainBundle.bundleShortVersionString)"],
                              "Build version string emitted.")
  }
}