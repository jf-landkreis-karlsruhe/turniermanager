package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.game.GameTable;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.GameRepository;
import de.jf.karlsruhe.model.repos.LeagueRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/league")
public class LeagueController {

	@Autowired
	private LeagueRepository leagueRepository;

	@Autowired
	private GameRepository gameRepository;

	@GetMapping("/table")
	public ResponseEntity<List<GameTable>> getAllLeaguesTable() {

		// Alle Ligen abrufen
		List<League> leagues = leagueRepository.findAll();

		// Alle GameTables erstellen
		List<GameTable> gameTables = leagues.stream()
				.map(league -> {
					// Altersgruppe und Ligainformationen
					String leagueName = league.getName();
					String ageGroupName = league.getAgeGroup().getName();

					// Spiele in dieser Liga abrufen
					List<Game> games = gameRepository.findByLeagueId(league.getId());

					// GameInfo-Einträge erstellen
					List<GameTable.GameInfo> gameInfos = games.stream()
							.map(game -> new GameTable.GameInfo(
									game.getId(),
									game.getTeamA().getName() + " vs " + game.getTeamB().getName(),
									game.getTeamAScore() != 0 && game.getTeamBScore() != 0
											? game.getTeamAScore() + " : " + game.getTeamBScore()
											: "Noch offen",
									game.getPitch().getName(),
									game.getStartTime().toLocalTime().toString()))
							.toList();

					return new GameTable(league.getId(), leagueName, ageGroupName, gameInfos);
				})
				.toList();

		return ResponseEntity.ok(gameTables);
	}





}
