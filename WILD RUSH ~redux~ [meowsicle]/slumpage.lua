local prof = PROFILEMAN:GetMachineProfile();
			
if prof:GetHighScoreForSongAndSteps( THIS_SONG, 4 ) and prof:GetHighScoreForSongAndSteps( THIS_SONG, 4 ):GetPercentDP() >= 0.9 then return true end

return false