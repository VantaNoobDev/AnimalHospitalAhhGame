--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Require = require(ReplicatedStorage.Shared.Modules.Require)

const Services = Require(ReplicatedStorage, { "Shared", "Services" })
const UI = Require(ReplicatedStorage, { "Shared", "UI" })

const PatientService = require(Require(Services, { "PatientService", "PatientServiceClient" }))
const ClassService = require(Require(Services, { "ClassService", "ClassServiceClient" }))
const SanityService = require(Require(Services, { "SanityService", "SanityServiceClient" }))
const ShiftService = require(Require(Services, { "ShiftService", "ShiftServiceClient" }))

const DialogueControllers = require(Require(UI, { "Controllers", "DialogueControllers" }))

assert(PatientService, "PatientService not found")
assert(ClassService, "ClassService not found")
assert(SanityService, "SanityService not found")
assert(ShiftService, "ShiftService not found")
assert(DialogueControllers, "DialogueModule not found")
