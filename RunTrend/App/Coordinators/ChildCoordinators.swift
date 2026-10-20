final class ChildCoordinators {
    private var items: [Coordinator] = []

    func add(_ coordinator: Coordinator) {
        guard !items.contains(where: { $0 === coordinator }) else { return }
        items.append(coordinator)
    }

    func remove(_ coordinator: Coordinator) {
        items.removeAll { $0 === coordinator }
    }
}
