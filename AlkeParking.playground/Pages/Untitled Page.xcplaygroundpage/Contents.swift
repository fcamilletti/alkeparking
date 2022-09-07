import Foundation

// Estructura del estacionamiento
struct Parking {
    private (set) var vehicles: Set<Vehicle> = []
    private var maxVehicles: Int = 20
    var todayStats: (earnings: Int, vehicles: Int) = (0,0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle,_ onFinish: (Bool) -> Void) {
        guard self.vehicles.count < maxVehicles && !self.vehicles.contains(vehicle) else {
            onFinish(false)
            print("Sorry, the check-in failed.")
            return
        }
        self.vehicles.insert(vehicle)
        onFinish(true)
        print("Welcome to AlkeParking!")
    }
    
    mutating func checkOutVehicle(plate: String, onSuccess: (Int) -> Void, onError: () -> Void ) {
        let vehicleExists = self.vehicles.first(where: { $0.plate == plate })
        guard let vehicle = vehicleExists else {
            onError()
            return
        }
        self.vehicles.remove(vehicle)
        let hasDiscount = vehicle.discountCard != nil
        let checkoutFee = self.calculateFee(vehicleType: vehicle.type, parkedTime: vehicle.parkedTime, hasDiscountCard: hasDiscount)
        self.todayStats.earnings += checkoutFee
        self.todayStats.vehicles += 1
        onSuccess(checkoutFee)
    }

    func calculateFee(vehicleType: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int {
        let twoHours = 120
        var total = 0
        if parkedTime <= 120 {
            total = vehicleType.rate
        } else {
            let minutesleft = Float(parkedTime - twoHours)
            let feeBlocks = round((minutesleft/15))
            total = vehicleType.rate + Int(feeBlocks) * (vehicleType.rate/4)
        }
        return hasDiscountCard ? Int(floor(Float(total) * 0.85)) : total
    }
    
    
    func listVehicles() {
        self.vehicles.forEach { vehicle in
            print("\(vehicle.plate)")
        }
    }
}

// Estructura del vehiculo
struct Vehicle: Parkable, Hashable {
    let plate: String
    let type: VehicleType
    let checkInTime: Date
    let discountCard: String?
    var parkedTime: Int {
        Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    init(plate: String, type: VehicleType, checkInTime: Date = Date(), discountCard: String? = nil) {
        self.plate = plate
        self.type = type
        self.checkInTime = checkInTime
        self.discountCard = discountCard
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.plate == rhs.plate
    }
}

// Tipos de vehiculos y tarifas por hora
enum VehicleType {
    case moto
    case car
    case miniBus
    case bus
    
    var rate: Int {
        switch self {
        case .moto: return 15
        case .car: return 20
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

// Protocolo: Cumple el vehiculo los requisitos?
protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get }
    var discountCard: String? { get }
    var parkedTime: Int { get }
}

print("Primero se crea nuestro Parking.")
var alkeParking = Parking()

print("-------------------------------------------------------------------------------------------------")
print("Luego se crean y se insertan los 20 vehiculos iniciales:")

let vehicles: [Vehicle] = [
    Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001"),
    Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002"),
    Vehicle(plate: "AA111BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
    Vehicle(plate: "B222CCC", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004"),
    Vehicle(plate: "CC333DD", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005"),
    Vehicle(plate: "AA111CC", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "B222DDD", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333EE", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_006"),
    Vehicle(plate: "AA111DD", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007"),
    Vehicle(plate: "B222EEE", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333FF", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_008"),
    Vehicle(plate: "CC343AF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DC313CF", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "VR333FA", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "BC833FF", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_009"),
    Vehicle(plate: "AC333WF", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
]

vehicles.forEach { vehicle in
    alkeParking.checkInVehicle(vehicle) { canPark in !canPark ? false : true }
}

print("-------------------------------------------------------------------------------------------------")
print("Se crea un vehicle21 para chequear si funciona el máximo de vehiculos:")

let vehicle21 = Vehicle(plate: "BD434FE", type: VehicleType.car, checkInTime: Date(), discountCard: nil)

alkeParking.checkInVehicle(vehicle21) { canPark in !canPark ? false : true }

print("-------------------------------------------------------------------------------------------------")
print("Se crea un vehicle22 con patente repetida para chequear si funciona la restricción de repetidos:")

let vehicle22 = Vehicle(plate: "CC343AF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

alkeParking.checkInVehicle(vehicle22) { canPark in !canPark ? false : true }

print("-------------------------------------------------------------------------------------------------")
print("Se hace el check-out de un vehiculo que estuvo dos horas:")

alkeParking.checkOutVehicle(plate: "AC333WF") { fee in
    print("Your fee is $\(fee). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

print("-------------------------------------------------------------------------------------------------")
print("Se hace el check-out de un vehiculo con descuento:")

alkeParking.checkOutVehicle(plate: "BC833FF") { fee in
    print("Your fee is $\(fee). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

print("-------------------------------------------------------------------------------------------------")
print("Se prueba hacer el check-out de un vehiculo que ya salió:")

alkeParking.checkOutVehicle(plate: "AC333WF") { fee in
    print("Your fee is $\(fee). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

print("-------------------------------------------------------------------------------------------------")
print("Se imprimen las patentes de los vehiculos estacionados:")

alkeParking.listVehicles()

print("-------------------------------------------------------------------------------------------------")
print("Se cierra la caja y se imprimen las ganancias del dia")

print("\(alkeParking.todayStats.vehicles) vehicles have checked out and we earned $\(alkeParking.todayStats.earnings)")
