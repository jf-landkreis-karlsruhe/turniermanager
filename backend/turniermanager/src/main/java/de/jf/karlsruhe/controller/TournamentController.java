package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.logic.GameScheduler;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.repos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tournament")
@RequiredArgsConstructor
public class TournamentController {

    private final TournamentRepository tournamentRepository;
    private final TeamRepository teamRepository;
    private final PitchRepository pitchRepository;
    private final AgeGroupRepository ageGroupRepository;
    private final LeagueRepository leagueRepository;
    private final RoundRepository roundRepository;
    private final GameRepository gameRepository;
    private final GameScheduler gameScheduler;

    @PostMapping("/create")
    public Tournament createTournament(@RequestParam String name,
                                       @RequestParam LocalDateTime startTime,
                                       @RequestParam int playTime,
                                       @RequestParam int breakTime) {
        // Turniereinstellungen erstellen
        GameSettings gameSettings = GameSettings.builder()
                .startTime(startTime)
                .playTime(playTime)
                .breakTime(breakTime)
                .build();

        Tournament tournament = Tournament.builder()
                .name(name)
                .gameSettings(gameSettings)
                .build();

        tournamentRepository.save(tournament);

        // Spielfelder laden und Scheduler initialisieren
        List<Pitch> pitches = pitchRepository.findAll();
        gameScheduler.initialize(pitches, startTime);

        // Altersgruppen laden und Ligen erstellen
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();

        for (AgeGroup ageGroup : ageGroups) {
            League league = League.builder()
                    .name("Liga " + ageGroup.getName())
                    .tournament(tournament)
                    .build();
            leagueRepository.save(league);

            // Teams der Altersgruppe laden
            List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId());
            for (Team team : teams) {
                team.setLeague(league);
                teamRepository.save(team);
            }

            // Qualifikationsspiele erstellen
            createQualificationGames(league, teams, pitches, playTime, breakTime);

            // Liga-Runden erstellen
            createLeagueRounds(league, teams, pitches, playTime, breakTime);
        }

        return tournament;
    }


    private void createQualificationGames(League league, List<Team> teams, List<Pitch> pitches,
                                          int playTime, int breakTime) {
        Round qualificationRound = Round.builder()
                .name("Qualification Round")
                .league(league)
                .build();
        roundRepository.save(qualificationRound);

        // Altersgruppe aus der Liga extrahieren
        AgeGroup ageGroup = ageGroupRepository.findByTournamentIdAndLeagueId(
                league.getTournament().getId(),
                league.getId()
        );

        // Planung der Spiele
        for (int i = 0; i < teams.size(); i += 2) {
            if (i + 1 < teams.size()) {
                Team teamA = teams.get(i);
                Team teamB = teams.get(i + 1);

                // Spiel erstellen
                Game game = Game.builder()
                        .teamA(teamA)
                        .teamB(teamB)
                        .round(qualificationRound)
                        .build();

                // Spiel über den Scheduler planen
                game = gameScheduler.scheduleGame(game, ageGroup, playTime, breakTime);

                // Speichern des geplanten Spiels
                gameRepository.save(game);
            }
        }
    }


    private void createLeagueRounds(League league, List<Team> teams, List<Pitch> pitches,
                                    int playTime, int breakTime) {
        int totalRounds = teams.size() - 1;

        // Altersgruppe aus der Liga extrahieren
        AgeGroup ageGroup = ageGroupRepository.findByTournamentIdAndLeagueId(
                league.getTournament().getId(),
                league.getId()
        );


        for (int roundIndex = 0; roundIndex < totalRounds; roundIndex++) {
            Round round = Round.builder()
                    .name("League Round " + (roundIndex + 1))
                    .league(league)
                    .build();
            roundRepository.save(round);

            // Planung der Spiele für die Runde
            for (int i = 0; i < teams.size(); i += 2) {
                if (i + 1 < teams.size()) {
                    Team teamA = teams.get(i);
                    Team teamB = teams.get(i + 1);

                    // Spiel erstellen
                    Game game = Game.builder()
                            .teamA(teamA)
                            .teamB(teamB)
                            .round(round)
                            .build();

                    // Spiel über den Scheduler planen
                    game = gameScheduler.scheduleGame(game, ageGroup, playTime, breakTime);

                    // Speichern des geplanten Spiels
                    gameRepository.save(game);
                }
            }
        }
    }
}