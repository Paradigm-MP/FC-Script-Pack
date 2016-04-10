Events:Subscribe("GameRender", function()
        for player in Client:GetStreamedPlayers() do
                state = player:GetBaseState()
                if (state == 110) or (state == 208) then
                        res = Physics:Raycast(
                                player:GetBonePosition("ragdoll_" .. ((state == 110) and "Head" or "Spine1")), 
                                player:GetAngle() * ((state == 110) and Vector3(0, -1, 0) or Vector3(0, 0, -1)), 0.1, 70
                        )
                        Render:DrawLine(player:GetBonePosition("ragdoll_LeftHand"), res.position, Color(40, 40, 40))
                end
        end
end)