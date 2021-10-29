local prof = PROFILEMAN:GetMachineProfile();
return prof:GetHighScoreForSongAndSteps( THIS_SONG, 3 ) and prof:GetHighScoreForSongAndSteps( THIS_SONG, 3 ):GetPercentDP() >= 0.85;