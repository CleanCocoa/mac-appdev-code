import Foundation

struct DefaultIntegerIdGenerator: GeneratesIntegerId {
    func integerId() -> IntegerId {
        arc4random_stir()
        var urandom: UInt64
        urandom = (UInt64(arc4random()) << 32) | UInt64(arc4random())

        let random: IntegerId = (IntegerId) (urandom & 0x7FFFFFFFFFFFFFFF)

        return random
    }
}
