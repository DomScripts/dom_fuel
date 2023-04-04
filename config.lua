Config = {}

Config.Debug = false

Config.FuelUsage = {
    rpmUsage = {
        [1.0] = 0.14,
		[0.9] = 0.12,
		[0.8] = 0.10,
		[0.7] = 0.09,
		[0.6] = 0.08,
		[0.5] = 0.07,
		[0.4] = 0.05,
		[0.3] = 0.04,
		[0.2] = 0.02,
		[0.1] = 0.01,
		[0.0] = 0.00,
    },
    classUsage = {
        [13] = 0.0, -- Cycles
    }
}

Config.Blip = {
    Toggle = true,
    Sprite = 361, -- Jerry Can
    Scale = 0.7,
    Color = 47, -- Orange
}

Config.PumpTarget = {
    Radius = 1.0,
    Distance = 1.5,
}

Config.Refill = {
    RefillValue = 0.50,
    RefillTick = 250,
}

Config.FuelOrder = {
    NPCModel = 'ig_floyd',
    NPCLocation = vec3(1716.624, -1622.355, 111.476),
    NPCHeading = (189.012),
    NPCZoneSize = vec3(55, 60, 20),
    NPCZoneRotation = 10,

    FuelTruck = 'hauler',
    FuelTruckLocation = vec4(1726.776, -1617.651, 112.651, 188.199),
    FuelTrailer = 'tanker',
    FuelTrailerLocation = vec4(1726.015, -1611.914, 112.463, 188.956),

    DropOffSize = vec3(20, 20, 10),

    Small = {fuel = 5000, cost = 15000, duration = 30000},
    Medium = {fuel = 10000, cost = 30000, duration = 60000},
    Large = {fuel = 15000, cost = 45000, duration = 90000},

    MaxFuel = 100000
}