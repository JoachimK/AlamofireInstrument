import os

@available(iOSApplicationExtension 12.0, *)
private enum SignpostLog {
    static let networking = OSLog(subsystem: "org.alamofire", category: "networking")
    
    static let logger = Logger()
    
    class Logger {
        var observers: [NSObjectProtocol] = []
        
        func startObservingNetworkRequestsIfNecessary() {
            guard observers.isEmpty else { return }
            observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.Task.DidResume, object: nil, queue: nil) { (notification) in
                guard let task = notification.userInfo?[Notification.Key.Task] as? URLSessionTask,
                    let request = task.originalRequest,
                    let url = request.url else {
                        return
                }
                let signpostId = OSSignpostID(log: networking, object: task)
                os_signpost(.begin, log: SignpostLog.networking, name: "Request", signpostID: signpostId, "Request Method %{public}@ to host: %{public}@, path: %@, parameters: %@", request.httpMethod ?? "", url.host ?? "Unknown", url.path, url.query ?? "")
            })
            observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { (notification) in
                guard let task = notification.userInfo?[Notification.Key.Task] as? URLSessionTask else { return }
                let signpostId = OSSignpostID(log: networking, object: task)
                os_signpost(.end, log: SignpostLog.networking, name: "Request", signpostID: signpostId, "Status: %@, Bytes Received: %llu", "Cancelled", task.countOfBytesReceived)
            })
            observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.Task.DidSuspend, object: nil, queue: nil) { (notification) in
                guard let task = notification.userInfo?[Notification.Key.Task] as? URLSessionTask else { return }
                let signpostId = OSSignpostID(log: networking, object: task)
                os_signpost(.end, log: SignpostLog.networking, name: "Request", signpostID: signpostId, "Status: %@, Bytes Received: %llu", "Suspended", task.countOfBytesReceived)
            })
            observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.Task.DidComplete, object: nil, queue: nil) { (notification) in
                guard let task = notification.userInfo?[Notification.Key.Task] as? URLSessionTask else { return }
                let signpostId = OSSignpostID(log: networking, object: task)
                let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 0
                os_signpost(.end, log: SignpostLog.networking, name: "Request", signpostID: signpostId, "Status: %@, Bytes Received: %llu, error: %d, statusCode: %d", "Completed", task.countOfBytesReceived, task.error == nil ? 0 : 1, statusCode)
            })
        }
    }
}
