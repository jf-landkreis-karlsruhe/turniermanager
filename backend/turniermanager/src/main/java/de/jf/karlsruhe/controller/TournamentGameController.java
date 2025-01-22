package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.game.GameControll;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.game.GameTable;
import de.jf.karlsruhe.model.repos.GameControllerRepository;
import de.jf.karlsruhe.model.repos.GameSettingsRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turnierverwaltung")
public class TournamentGameController {

	@Autowired
	private GameControllerRepository gameControllerRepository;

	@Autowired
	private GameSettingsRepository gameSettingsRepository;
	
    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private TeamRepository teamRepository;


	@PostMapping("/createTournament")
	public ResponseEntity<GameControll> createGameControll(@RequestBody GameControll gameControll) {
		GameSettings settings = gameControll.getSettings();
		if (settings != null) {
			if (settings.getId() == null) {
				settings = gameSettingsRepository.save(settings);
			}
			gameControll.setSettings(settings);
		}
		GameControll savedGameControll = gameControllerRepository.save(gameControll);
		return ResponseEntity.ok(savedGameControll);
	}
	
	@PostMapping("/initGame")
	public void createGameTable(@RequestParam Long gameControllId){
		
		GameControll gameControll = gameControllerRepository.findById(gameControllId)
                .orElseThrow(() -> new RuntimeException("GameControll not found"));

	      GameSettings gameSettings = gameControll.getSettings();
	        LocalDateTime startTime = gameSettings.getStartTime();
	        int breakTime = gameSettings.getBreakTime();
	        int playTime = gameSettings.getPlayTime();
	}
}
