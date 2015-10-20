//
//  main.swift
//  domain-modeling
//
//  Created by Lijuan Zhang on 10/14/15.
//  Copyright © 2015 Lijuan Zhang. All rights reserved.
//

import Foundation

enum Currency {
    case USD, GBP, EUR, CAN
}

protocol Mathematics {
    func +(left: Self, right: Self) -> Self
    func -(left: Self, right: Self) -> Self
}

struct Money: CustomStringConvertible, Mathematics {
    var amount: Double
    var currency: Currency
    
    init(amount: Double, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
    
    //Stringify amount and currency properties in order to print
    var stringified: String {
        get {
            let cur: String
            switch currency {
            case .USD: cur = "USD"
            case .GBP: cur = "GBP"
            case .EUR: cur = "EUR"
            case .CAN: cur = "CAN"
            }
            
            return "\(amount) " + cur
        }
    }
    
    //Implement description property of CustomStringConvertible, similar to stringified property
    var description: String { get {
        let cur: String
        switch currency {
        case .USD: cur = "USD"
        case .GBP: cur = "GBP"
        case .EUR: cur = "EUR"
        case .CAN: cur = "CAN"
        }
        
        return cur + "\(amount)"
        }
    }
    
    func convert(toCurrency: Currency) -> Money {
        /*exchangeRate stores exchange rates from USD to other currencies. For example, exchangeRate[Currency.GBP] is the rate to convert USD to GBP,
        so the rate to change GBP to USD is 1/exchangeRate[Currency.GBP]!
        */
        let exchangeRate: Dictionary<Currency, Double> = [Currency.USD: 1, Currency.GBP: 0.5, Currency.EUR: 1.5, Currency.CAN: 1.25]
        
        //When converting, convert the currency to USD, and then convert from USD to target currency
        let amountAfterConvert = self.amount * (1/exchangeRate[self.currency]!) * (exchangeRate[toCurrency]!)
        return Money(amount: amountAfterConvert, currency: toCurrency)
    }
    
    //When adding different currencies, will convert them to the most left currency
    static func add(moneys: Money...) -> Money {
        let outCurrency: Currency = moneys[0].currency
        var outputAmount: Double = 0.0
        for money in moneys {
            if money.currency != outCurrency {
                let convertedMoney = money.convert(outCurrency)
                outputAmount += convertedMoney.amount
            }
            else {
                outputAmount += money.amount
            }
        }
        return Money(amount: outputAmount, currency: outCurrency)
    }
    
    //When subtracting different currencies, will convert them to the most left currency
    static func subtract(moneys: Money...) -> Money {
        let outCurrency: Currency = moneys[0].currency
        var outputAmount: Double = moneys[0].amount
        for var i = 1; i < moneys.count; i++ {
            let money = moneys[i]
            if money.currency != outCurrency {
                let convertedMoney = money.convert(outCurrency)
                outputAmount -= convertedMoney.amount
            }
            else {
                outputAmount -= money.amount
            }
        }
        return Money(amount: outputAmount, currency: outCurrency)
    }
}

//Since operators are only allowed at global scope, implement here
func + (left: Money, right: Money) -> Money {
    return Money.add(left, right)
}

func -(left: Money, right: Money) -> Money {
    return Money.subtract(left, right)
}

//Test of Money
print("Test of Money")
let money = Money(amount: 10, currency: Currency.GBP)
let convertToUSD = money.convert(Currency.USD)
print("Convert 10 GBP to USD: " + convertToUSD.stringified)
let convertToCAN = money.convert(Currency.CAN)
print("Convert 10 GBP to CAN: " + convertToCAN.stringified)
let eurToCAN = Money(amount: 6, currency: Currency.EUR).convert(Currency.CAN)
print("Convert 6 EUR to CAN: " + eurToCAN.stringified)
print("10 GBP + 20 USD: " + Money.add(money, convertToUSD).stringified)
print("20 USD + 20 USD: " + Money.add(convertToUSD, convertToUSD).stringified)
print("10 GBP + 20 USD + 5 CAN: " + Money.add(money, convertToUSD, eurToCAN).stringified)
let moneyLeft = Money(amount: 50, currency: Currency.EUR)
print("50 EUR - 10 GBP: " + Money.subtract(moneyLeft, money).stringified)
print("50 EUR - 20 EUR: " + Money.subtract(moneyLeft, Money(amount: 20, currency: Currency.EUR)).stringified)
print("50 EUR - 20 EUR - 20 EUR: " + Money.subtract(moneyLeft, Money(amount: 20, currency: Currency.EUR), Money(amount: 20, currency: Currency.EUR)).stringified)

//Extention of Double
extension Double {
    var USD: Money {return Money(amount: self, currency: Currency.USD)}
    var EUR: Money {return Money(amount: self, currency: Currency.EUR)}
    var GBP: Money {return Money(amount: self, currency: Currency.GBP)}
    var CAN: Money {return Money(amount: self, currency: Currency.CAN)}
}

//Job
class Job: CustomStringConvertible {
    var title: String
    var salary: Money
    var isSalaryPerHour: Bool
    
    //Implement description property of CustomStringConvertible
    var description: String {
        get {
            return "JobTitle: " + title + ", Salary: " + salary.description + (isSalaryPerHour ? " per hour" : " per year")
        }
    }
    
    init(title: String, salary: Money, isSalaryPerHour: Bool) {
        self.title = title
        self.salary = salary
        self.isSalaryPerHour = isSalaryPerHour
    }
    
    func calculateIncome(numberOfHours: Double) -> Money {
        if (self.isSalaryPerHour) {
            let income = Money(amount: salary.amount * numberOfHours, currency: salary.currency)
            return income
        }
        return salary
    }
    
    func raise(raisePercent: Double) -> Money {
        salary.amount = salary.amount * (1 + raisePercent * 0.01)
        return salary
    }
}

//Test of Job
print("\nTest of Job")
print("Generate a testJob with title: 'SDE', salary: 100000 USD and the salary is per year.")
let testJob = Job(title: "SDE", salary: Money(amount: 100000, currency: Currency.USD), isSalaryPerHour: false)
print("testJob.calculateIncome(2080): \(testJob.calculateIncome(2080).stringified)")
print("Salary of testJob after raise 20%: \(testJob.raise(20).stringified)")
print("Generate a testJob2 with title: 'SDE', salary: 40 USD and the salary is per hour.")
let testJob2 = Job(title: "UX Designer", salary: Money(amount: 40, currency: Currency.USD), isSalaryPerHour: true)
print("testJob.calculateIncome(2080): \(testJob2.calculateIncome(2080).stringified)")
print("Salary of testJob after raise 20%: \(testJob2.raise(20).stringified)")

//Person
class Person: CustomStringConvertible {
    var firstName: String
    var lastName: String
    var age: Int
    var job: Job?
    var spouse: Person?
    
    //Implement description property of CustomStringConvertible, similar to toString()
    var description: String {
        get {
            var selfString = "firstName: " + firstName + ", lastName: " + lastName + ", age: \(age)"
            if job != nil {
                selfString = selfString + ", " + job!.description
            }
            else {
                selfString += ", job: nil"
            }
            
            if spouse != nil {
                selfString += ", spouseFirstName: " + spouse!.firstName + ", spouseLastName: " + spouse!.lastName
            }
            else {
                selfString += ", spouse: nil"
            }
            
            return selfString
        }
    }
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.job = nil
        self.spouse = nil
    }
    
    init(firstName: String, lastName: String, age: Int, job: Job?, spouse: Person?) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        
        if age < 16 {
            self.job = nil
        }
        else {
            self.job = job
        }
        
        if age < 18 {
            self.spouse = nil
        }
        else {
            self.spouse = spouse
        }
    }
    
    func toString() -> String {
        var selfString = "firstName: " + firstName + ", lastName: " + lastName + ", age: \(age)"
        
        if job != nil {
            selfString = selfString + ", jobTitle: " + job!.title + ", jobSalary: " + job!.salary.stringified + (job!.isSalaryPerHour ? " per hour" : " per year")
        }
        else {
            selfString += ", job: nil"
        }
        
        if spouse != nil {
            selfString += ", spouseFirstName: " + spouse!.firstName + ", spouseLastName: " + spouse!.lastName
        }
        else {
            selfString += ", spouse: nil"
        }
        
        return selfString
    }
}

//Test of Person
print("\nTest of Person")
print("Generate a testPerson without job and spouse.")
let testPerson = Person(firstName: "Jane", lastName: "Doe", age: 16)
print("testPerson.toString(): \(testPerson.toString())")

print("Generate a testPerson2 without spouse.")
let testPerson2 = Person(firstName: "Jenifer", lastName: "Doe", age: 17, job: testJob, spouse: nil)
print("testPerson2.toString(): \(testPerson2.toString())")

print("Generate tow persons: Lily and Jim and they are spouse")
let lily = Person(firstName: "Lily", lastName: "Joe", age: 25, job: testJob2, spouse: nil)
let jim = Person(firstName: "Jim", lastName: "Green", age: 28, job: testJob, spouse: lily)
lily.spouse = jim
print("lily.toString(): \(lily.toString())")
print("jim.toString(): \(jim.toString())")


//Family
enum FamilyInitError: ErrorType{
    case IllegalInitilization
}

class Family: CustomStringConvertible {
    var members: [Person]
    
    //Implement description property of CustomStringConvertible
    var description: String {
        get {
            var desc: String = ""
            for member in members {
                desc += member.description + "\n"
            }
            return desc
        }
    }
    
    init(members: [Person]) throws {
        var isLegal: Bool = false
        for member in members {
            if member.age >= 21 {
                isLegal = true
            }
        }
        self.members = members
        
        if !isLegal {
            print("No person is over age 21, illegal.")
            throw FamilyInitError.IllegalInitilization
        }
    }
    
    //In order to calculate householdIncome, working hours of each member are needed. members who do not have a job has 0 working hour
    func householdIncome(workingHours: [Double]) -> Money {
        var combinedIncome: Money = Money(amount: 0, currency: Currency.USD)
        
        for var i = 0; i < members.count; i++ {
            let member = members[i]
            if member.job != nil {
                combinedIncome = Money.add(combinedIncome, member.job!.calculateIncome(workingHours[i]))
            }
        }
        
        return combinedIncome
    }
    
    func haveChild(firstName: String, lastName: String) -> Void {
        let child = Person(firstName: firstName, lastName: lastName, age: 0)
        self.members.append(child)
    }
    
    //return family members' firstName and lastName
    func displayMembers() -> Void {
        for member in members {
            print(member.toString())
        }
    }
}

print("\nTest of Family")
print("Generating a family with a person of age 5: ")
let child = Person(firstName: "Jhon", lastName: "Doe", age: 5)
do {
    var family = try Family(members: [child])
}
catch FamilyInitError.IllegalInitilization{
    print("Must have at least one person over age 21 to create a family")
}

print("\nGenerating a family with Lily and Jim: ")
do {
    var family = try Family(members: [lily, jim])
    print("householdIncome while both of them work 2080 hours per year: " + family.householdIncome([2080, 2080]).stringified)
    print("family members: ")
    family.displayMembers()
    //Add child
    family.haveChild("Laura", lastName: "Green")
    print("\nfamily members after have a child: ")
    family.displayMembers()
}
catch FamilyInitError.IllegalInitilization{
    print("Must have at least one person over age 21 to create a family")
}

//Test for Domain Modeling (Part 2)
print("\nTest for Domain Modeling (Part 2)")
//Test of description
//Test of Implementation of Mathematics protocal in Money
Money(amount: 10, currency: Currency.EUR) + Money(amount: 10, currency: Currency.CAN)
print("Money(amount: 10, currency: Currency.EUR) + Money(amount: 10, currency: Currency.CAN)\((Money(amount: 10, currency: Currency.EUR) + Money(amount: 10, currency: Currency.CAN)).description)")
//Test of extension of Double


