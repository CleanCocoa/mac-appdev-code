import Foundation

struct IdGenerator<Id: Identifiable> {
    let integerIdGenerator: GeneratesIntegerId
    let integerIdIsTaken: (IntegerId) -> Bool

    func nextId() -> Id {
        return Id(unusedIntegerId())
    }

    func unusedIntegerId() -> IntegerId {
        var identifier: IntegerId

        repeat {
            identifier = integerId()
        } while integerIdIsTaken(identifier)

        return identifier
    }

    func integerId() -> IntegerId {
        return integerIdGenerator.integerId()
    }
}
