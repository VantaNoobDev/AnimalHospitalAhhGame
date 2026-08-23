--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Services = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Services")
const Controllers = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Controllers")

const PatientService = require(Services:WaitForChild("PatientService"):WaitForChild("PatientServiceClient"))
const ClassService = require(Services:WaitForChild("ClassService"):WaitForChild("ClassServiceClient"))
const SanityService = require(Services:WaitForChild("SanityService"):WaitForChild("SanityServiceClient"))
const ShiftService = require(Services:WaitForChild("ShiftService"):WaitForChild("ShiftServiceClient"))

const DialogueModule = require(Controllers:WaitForChild("DialogueController"))

assert(PatientService, "PatientService not found")
assert(ClassService, "ClassService not found")
assert(SanityService, "SanityService not found")
assert(ShiftService, "ShiftService not found")

assert(DialogueModule, "DialogueModule not found")
