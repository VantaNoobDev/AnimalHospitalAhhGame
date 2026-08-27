--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const SharedServices = ReplicatedStorage.Shared.Services

const PatientService = require(SharedServices.PatientService.PatientServiceClient)
const ClassService = require(SharedServices.ClassService.ClassServiceClient)
const SanityService = require(SharedServices.SanityService.SanityServiceClient)
const ShiftService = require(SharedServices.ShiftService.ShiftServiceClient)
const DialogueController = require(ReplicatedStorage.UI.Controllers.DialogueController)

--// Client startup
PatientService.Init()
ClassService.Init()
SanityService.Init()
ShiftService.Init()
DialogueController.Init()
