package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.game.GameControll;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.game.GameTable;
import de.jf.karlsruhe.model.repos.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/tournament")
public class TournamentGameController {

    @Autowired
    private GameControllerRepository gameControllerRepository;

    @Autowired
    private GameSettingsRepository gameSettingsRepository;

    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private RoundRepository roundRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Autowired
    private GameRepository gameRepository;


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


    /**
     * Ein einziger REST-Call für den kompletten Ablauf:
     * 1. Spielrunde erstellen
     * 2. Ligen erstellen
     * 3. Teams automatisch zuweisen
     */
    @PostMapping("/setup")
    public ResponseEntity<String> setupTournament(@RequestParam Long ageGroupId,
                                                  @RequestParam String roundName,
                                                  @RequestParam int leagueCount) {
        // 1. Spielrunde erstellen
        AgeGroup ageGroup = ageGroupRepository.findById(ageGroupId)
                .orElseThrow(() -> new RuntimeException("Altersklasse nicht gefunden."));

        Round round = new Round();
        round.setName(roundName);
        round.setAgeGroup(ageGroup);
        Round savedRound = roundRepository.save(round);

        // 2. Ligen erstellen
        List<League> leagues = new ArrayList<>();
        for (int i = 1; i <= leagueCount; i++) {
            League league = new League();
            league.setName("League " + i);
            league.setAgeGroup(ageGroup);
            league.setRound(savedRound); // Verknüpft Liga mit der Runde
            leagues.add(leagueRepository.save(league));
        }

        // 3. Teams automatisch zuweisen
        List<Team> teams = teamRepository.findByAgeGroupId(ageGroupId);
        if (teams.isEmpty()) {
            throw new RuntimeException("Keine Teams für die Altersgruppe vorhanden.");
        }

        if (leagues.isEmpty()) {
            throw new RuntimeException("Keine Ligen für diese Runde erstellt.");
        }

        // Verteilung der Teams auf die Ligen
        int leagueIndex = 0;
        for (Team team : teams) {
            League currentLeague = leagues.get(leagueIndex);
            currentLeague.getTeams().add(team);
            leagueRepository.save(currentLeague);

            // Wechsel zur nächsten Liga
            leagueIndex = (leagueIndex + 1) % leagues.size();
        }

        return ResponseEntity.ok("Turnier wurde erstellt: Runde '" + roundName + "' mit " + leagueCount
                + " Ligen und " + teams.size() + " Teams zugewiesen.");
    }

    @PostMapping("/createGamesWithPitches")
    public ResponseEntity<String> createGamesWithPitches(@RequestParam Long ageGroupId,
                                                         @RequestParam Long roundId,
                                                         @RequestParam String startTime,
                                                         @RequestParam int playTime,
                                                         @RequestParam int breakTime) {
        // Zeitplan-Konfiguration
        LocalDateTime currentStartTime = LocalDateTime.parse(startTime);

        // Lade alle verfügbaren Plätze für die Altersklasse
        List<Pitch> pitches = pitchRepository.findByAgeGroupId(ageGroupId);
        if (pitches.isEmpty()) {
            throw new RuntimeException("Keine Plätze verfügbar für diese Altersgruppe!");
        }

        // Lade alle Ligen nach Altersgruppe und Runde
        List<League> leagues = leagueRepository.findByAgeGroupIdAndRoundId(ageGroupId, roundId);

        if (leagues.isEmpty()) {
            throw new RuntimeException("Keine Ligen für die Altersgruppe und Spielrunde gefunden.");
        }

        int totalGamesCount = 0;

        // Spiele planen
        for (League league : leagues) {
            List<Team> teams = league.getTeams();

            if (teams.size() < 2) {
                throw new RuntimeException("Liga '" + league.getName() + "' hat nicht genug Teams für Spiele.");
            }

            for (int i = 0; i < teams.size(); i++) {
                for (int j = i + 1; j < teams.size(); j++) {
                    Team teamA = teams.get(i);
                    Team teamB = teams.get(j);

                    // Platzzuweisung
                    Pitch assignedPitch = pitches.get(totalGamesCount % pitches.size());

                    // Spiel erstellen
                    Game game = new Game();
                    game.setTeamA(teamA);
                    game.setTeamB(teamB);
                    game.setLeague(league);
                    game.setStartTime(currentStartTime);
                    game.setPitch(assignedPitch);

                    // Spiel speichern
                    gameRepository.save(game);

                    // Update Zeitplan
                    currentStartTime = currentStartTime.plusMinutes(playTime + breakTime);
                    totalGamesCount++;
                }
            }
        }

        return ResponseEntity.ok(totalGamesCount + " Spiele erfolgreich erstellt und eingeplant.");
    }
	@PostMapping("/playQualificationRound")
	public ResponseEntity<String> playQualificationRound(@RequestParam String startTime,
														 @RequestParam int playTime,
														 @RequestParam int breakTime) {

		// 1. Altersgruppen laden
		List<AgeGroup> ageGroups = ageGroupRepository.findAll();
		if (ageGroups.isEmpty()) {
			throw new RuntimeException("Keine Altersgruppen vorhanden!");
		}

		LocalDateTime currentStartTime = LocalDateTime.parse(startTime);
		int totalGamesCount = 0;

		// 2. Für jede Altersgruppe: Qualifikationsrunde durchführen
		for (AgeGroup ageGroup : ageGroups) {
			List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId()); // Teams je Altersgruppe

			if (teams.size() < 2) {
				throw new RuntimeException("Nicht genug Teams in Altersgruppe " + ageGroup.getName());
			}

			List<Pitch> pitches = pitchRepository.findByAgeGroupId(ageGroup.getId()); // Plätze für Altersgruppe
			if (pitches.isEmpty()) {
				throw new RuntimeException("Keine Plätze für Altersgruppe " + ageGroup.getName());
			}

			// Round-Robin-Spiele
			for (int i = 0; i < teams.size(); i++) {
				for (int j = i + 1; j < teams.size(); j++) {
					Team teamA = teams.get(i);
					Team teamB = teams.get(j);

					Pitch assignedPitch = pitches.get(totalGamesCount % pitches.size());

					// Ergebnis simulieren (kann später durch echte Ergebnisse ersetzt werden)
					int goalsA = (int) (Math.random() * 5);
					int goalsB = (int) (Math.random() * 5);

					if (goalsA > goalsB) {
						teamA.setPoints(teamA.getPoints() + 3);
					} else if (goalsA < goalsB) {
						teamB.setPoints(teamB.getPoints() + 3);
					} else {
						teamA.setPoints(teamA.getPoints() + 1);
						teamB.setPoints(teamB.getPoints() + 1);
					}

					teamA.setGoalDifference(teamA.getGoalDifference() + (goalsA - goalsB));
					teamB.setGoalDifference(teamB.getGoalDifference() + (goalsB - goalsA));

					// Spiel speichern
					Game qualificationGame = new Game();
					qualificationGame.setTeamA(teamA);
					qualificationGame.setTeamB(teamB);
					qualificationGame.setStartTime(currentStartTime);
					qualificationGame.setPitch(assignedPitch);
					gameRepository.save(qualificationGame);

					// Zeitplan updaten
					currentStartTime = currentStartTime.plusMinutes(playTime + breakTime);
					totalGamesCount++;
				}
			}

			// Teams speichern
			teamRepository.saveAll(teams);
		}

		return ResponseEntity.ok(totalGamesCount + " Qualifikationsspiele erfolgreich abgeschlossen.");
	}

	@PutMapping("/games/{gameId}/results")
	public ResponseEntity<String> updateGameResults(@PathVariable Long gameId,
													@RequestParam int teamAScore,
													@RequestParam int teamBScore) {

		// Spiel laden
		Game game = gameRepository.findById(gameId)
				.orElseThrow(() -> new RuntimeException("Spiel mit ID " + gameId + " nicht gefunden!"));

		// Ergebnisse speichern
		game.setTeamAScore(teamAScore);
		game.setTeamBScore(teamBScore);
		gameRepository.save(game);

		// Punkte und Tordifferenzen aktualisieren
		Team teamA = game.getTeamA();
		Team teamB = game.getTeamB();

		// Berechnung von Punkten und Tordifferenz
		if (teamAScore > teamBScore) {
			teamA.setPoints(teamA.getPoints() + 3); // Team A gewinnt
		} else if (teamAScore < teamBScore) {
			teamB.setPoints(teamB.getPoints() + 3); // Team B gewinnt
		} else {
			teamA.setPoints(teamA.getPoints() + 1); // Unentschieden
			teamB.setPoints(teamB.getPoints() + 1);
		}

		// Aktualisiere Tordifferenz
		teamA.setGoalDifference(teamA.getGoalDifference() + (teamAScore - teamBScore));
		teamB.setGoalDifference(teamB.getGoalDifference() + (teamBScore - teamAScore));

		// Teams aktualisieren
		teamRepository.save(teamA);
		teamRepository.save(teamB);

		return ResponseEntity.ok("Ergebnisse für Spiel " + gameId + " erfolgreich gespeichert.");
	}


}