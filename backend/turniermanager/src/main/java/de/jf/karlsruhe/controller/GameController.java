package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.game.GameControll;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.repos.GameControllerRepository;
import de.jf.karlsruhe.model.repos.GameSettingsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turnierverwaltung")
public class GameController {

	@Autowired
	private GameControllerRepository gameControllerRepository;

	@Autowired
	private GameSettingsRepository gameSettingsRepository;

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
}
