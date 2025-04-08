package de.jf.karlsruhe.testMode;

import de.jf.karlsruhe.controller.GamePlanController;
import de.jf.karlsruhe.controller.RoundStatsController;
import de.jf.karlsruhe.controller.TournamentController;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.UUID;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initData(AgeGroupRepository ageGroupRepository, PitchRepository pitchRepository, TeamRepository teamRepository, GameRepository gameRepository, TournamentController tournamentController, RoundStatsController statsController, TournamentRepository tournamentRepository, RoundRepository roundRepository, GamePlanController gamePlanController) {
        return args -> {
            if(false) return;
            // Altersgruppen initialisieren
            if (ageGroupRepository.count() == 0) {
                AgeGroup kinder = ageGroupRepository.save(AgeGroup.builder().name("Kinder").build());
                AgeGroup jugendliche = ageGroupRepository.save(AgeGroup.builder().name("Jugendliche").build());
                AgeGroup erwachsene = ageGroupRepository.save(AgeGroup.builder().name("Erwachsene").build());
                System.out.println("Drei AgeGroups wurden initial gespeichert.");

                // Pitches initialisieren
                if (pitchRepository.count() == 0) {
                    pitchRepository.save(Pitch.builder().name("Platz1").ageGroups(List.of(kinder)).build());
                    pitchRepository.save(Pitch.builder().name("Platz2").ageGroups(List.of(jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz3").ageGroups(List.of(erwachsene)).build());
                    //pitchRepository.save(Pitch.builder().name("Platz4").ageGroups(List.of(jugendliche)).build());
                    //pitchRepository.save(Pitch.builder().name("Platz5").ageGroups(List.of(jugendliche)).build());
                    //pitchRepository.save(Pitch.builder().name("Platz6").ageGroups(List.of(jugendliche)).build());
                    System.out.println("Zwei Pitches wurden initial gespeichert.");
                }
            }

            // Teams initialisieren
            if (teamRepository.count() == 0) {
                for (int i = 1; i <= 20; i++) {
                    int j = i % 3;
                    AgeGroup ageGroup;
                    if(j == 0) {
                        ageGroup = ageGroupRepository.findAll().getFirst();
                        teamRepository.save(Team.builder().name("Team " + i).ageGroup(ageGroup).build());
                    }else if(j == 1) {
                        ageGroup = ageGroupRepository.findAll().get(1);
                        teamRepository.save(Team.builder().name("Team " + i).ageGroup(ageGroup).build());

                    } else {
                        ageGroup = ageGroupRepository.findAll().getLast();
                        teamRepository.save(Team.builder().name("Team " + i).ageGroup(ageGroup).build());

                    }
                }
                System.out.println("20 Teams wurden initial gespeichert.");
            }
            UUID tournamentId;
            // Test-Turnier erstellen
            if (true) {
                tournamentId = tournamentController.createTournament("Test-Tournier", LocalDateTime.now(), 2, 1);
                tournamentController.createQualificationTournament();

                // Zufällige Scores für alle Spiele setzen
                updateAllGamesWithRandomScores(gameRepository);
            }
            if(true)return;

            if (true) {
                tournamentController.createTournamentRound(new TournamentController.TournamentRoundRequest(null,null));
                updateAllGamesWithRandomScores(gameRepository);
            }

            if (false) {
                AgeGroup one = ageGroupRepository.findAll().getFirst();
                ResponseEntity<GamePlanController.GamePlan> gamePlanByAgeGroup = gamePlanController.getGamePlanByAgeGroup(one.getId());
                System.out.println(gamePlanByAgeGroup.getBody());
            }


            //gamePlanController.getGamePlanByAgeGroup();


            if (true) return;
            Tournament first = tournamentRepository.findAll().getFirst();
            ResponseEntity<List<RoundStatsController.RoundStatsDTO>> roundStatsByTournament = statsController.getRoundStatsForTournament();
            System.out.println(roundStatsByTournament.toString());


            Round last = roundRepository.findAll().getLast();
            ResponseEntity<RoundStatsController.RoundStatsDTO> roundStats = statsController.getRoundStats(last.getId());
            System.out.println(roundStats.toString());
            //tournament.getRounds().forEach(round -> {
            //    ResponseEntity<RoundStatsController.RoundStatsDTO> roundStats = statsController.getRoundStats(round.getId());
            //    System.out.println(roundStats.getBody());
            //});
        };
    }

    /**
     * Methode zum Erstellen zufälliger Scores für alle Spiele.
     * Diese Methode wird verwendet, um alle Spiele mit zufälligen Ergebnissen zu versehen.
     */
    private void updateAllGamesWithRandomScores(GameRepository gameRepository) {
        // Alle Spiele aus der Datenbank abrufen
        List<Game> games = gameRepository.findAll();

        // Zufallszahlengenerator
        Random random = new Random();

        // Durch jedes Spiel iterieren und zufällige Scores zuweisen
        int i = 0;
        for (Game game : games) {
            //if (i++ == 30) break;
            // Zufällige Scores für Team A und Team B generieren (zum Beispiel zwischen 0 und 5)
            int teamAScore = random.nextInt(6); // Zufallszahl zwischen 0 und 5
            int teamBScore = random.nextInt(6); // Zufallszahl zwischen 0 und 5

            // Setzen der Scores für das Spiel
            game.setTeamAScore(teamAScore);
            game.setTeamBScore(teamBScore);

            // Spiel mit den neuen Scores speichern
            gameRepository.save(game);
        }
        System.out.println("Alle Spiele wurden mit zufälligen Scores aktualisiert.");
    }
}
