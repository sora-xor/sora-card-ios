class SCBalanceConverter {

    static let eurMinorUnitsCount = 100  // TODO: check minor units currency

    static func formatedBalance(balance: Int) -> String {
        let balanceDecimal = Decimal(balance / Self.eurMinorUnitsCount)
        let balanceString = NumberFormatter.fiat.stringFromDecimal(balanceDecimal) ?? ""
        return "€\(balanceString)"
    }
}
