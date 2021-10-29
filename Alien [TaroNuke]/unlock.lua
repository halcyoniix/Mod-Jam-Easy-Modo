local prof = PROFILEMAN:GetMachineProfile();
return prof:GetHighScoreForSongAndSteps( THIS_SONG, 4 ) and prof:GetHighScoreForSongAndSteps( THIS_SONG, 4 ):GetPercentDP() >= 0.5;