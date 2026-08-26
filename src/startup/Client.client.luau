--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Require = require(ReplicatedStorage.Shared.Modules.Require) :: any

const Services = Require(ReplicatedStorage, { "Shared", "Services" }) :: any
const Controllers = Require(ReplicatedStorage, { "UI", "Controllers" }) :: any

const PatientService = require(Require(Services, { "PatientService", "PatientServiceClient" })) :: any
const ClassService = require(Require(Services, { "ClassService", "ClassServiceClient" })) :: any
const SanityService = require(Require(Services, { "SanityService", "SanityServiceClient" })) :: any
const ShiftService = require(Require(Services, { "ShiftService", "ShiftServiceClient" })) :: any

const DialogueController = require(Require(Controllers, { "DialogueController" })) :: any

const MultipleAsserts = require(Require(ReplicatedStorage, { "Shared, Modules, MultipleAsserts" })) :: any

MultipleAsserts.All({ PatientService, ClassService, SanityService, ShiftService, DialogueController }, "Not found.")
