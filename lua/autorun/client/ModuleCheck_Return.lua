function Return()
	Events:Fire("ModuleChecker_Return")
end
Events:Subscribe("ModuleChecker_Send", Return)

function LoadModule()
	Events:Fire("RenderUpgradeSequence")
end
Events:Subscribe("ModuleLoad", LoadModule)