import Foundation

struct NotificationMessage: Identifiable {
    let id: String
    let title: String
    let body: String
    var region: LocationRegion? = nil
}

protocol NotificationProviding {
    func sendNotification(with message: NotificationMessage)
    func requestPermission(completion: @escaping (Result<Void, Error>) -> Void)
    func scheduledNotifications(callback: @escaping ([NotificationMessage]) -> Void) 
    func removeNotification(with identifier: String)
    func deliveredNotifications(callback: @escaping ([NotificationMessage]) -> Void)
}

protocol HasNotificationProvider {
    var notificationProvider: NotificationProviding { get }
}
