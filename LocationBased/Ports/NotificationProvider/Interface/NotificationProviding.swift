import Foundation

struct NotificationMessage {
    let title: String
    let body: String
    var region: LocationRegion? = nil
}

protocol NotificationProviding {
    func sendNotification(with message: NotificationMessage)
    func requestPermission(completion: @escaping (Result<Void, Error>) -> Void)
}

protocol HasNotificationProvider {
    var notificationProvider: NotificationProviding { get }
}
