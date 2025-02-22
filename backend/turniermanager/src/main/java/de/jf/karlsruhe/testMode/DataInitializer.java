package de.jf.karlsruhe.testMode;

import de.jf.karlsruhe.controller.TournamentController;
import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.base.Team;
import de.jf.karlsruhe.model.base.Tournament;
import de.jf.karlsruhe.model.repos.GameRepository;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.UUID;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initData(AgeGroupRepository ageGroupRepository, PitchRepository pitchRepository, TeamRepository teamRepository, GameRepository gameRepository, TournamentController tournamentController) {
        return args -> {
            // Altersgruppen initialisieren
            if (ageGroupRepository.count() == 0) {
                AgeGroup kinder = ageGroupRepository.save(AgeGroup.builder().name("Kinder").build());
                AgeGroup jugendliche = ageGroupRepository.save(AgeGroup.builder().name("Jugendliche").build());
                System.out.println("Drei AgeGroups wurden initial gespeichert.");

                // Pitches initialisieren
                if (pitchRepository.count() == 0) {
                    pitchRepository.save(Pitch.builder().name("Platz1").ageGroups(List.of(kinder, jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz2").ageGroups(List.of(kinder, jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz3").ageGroups(List.of(kinder, jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz4").ageGroups(List.of(jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz5").ageGroups(List.of(jugendliche)).build());
                    pitchRepository.save(Pitch.builder().name("Platz6").ageGroups(List.of(jugendliche)).build());
                    System.out.println("Zwei Pitches wurden initial gespeichert.");
                }
            }

            // Teams initialisieren
            if (teamRepository.count() == 0) {
                for (int i = 1; i <= 30; i++) {
                    AgeGroup ageGroup = (i % 2 == 0) ? ageGroupRepository.findAll().getFirst() : ageGroupRepository.findAll().getLast();
                    teamRepository.save(Team.builder().name("Team " + i).ageGroup(ageGroup).build());
                }
                System.out.println("30 Teams wurden initial gespeichert.");
            }
            Tournament tournament;
            // Test-Turnier erstellen
            if (true) {
                tournament = tournamentController.createTournament("Test-Tournier", LocalDateTime.now(), 10, 1);
                tournamentController.createQualificationTournament(tournament.getId());

                // Zufällige Scores für alle Spiele setzen
                updateAllGamesWithRandomScores(gameRepository);
            }
            
            if(true){
                UUID id = tournament.getId();
                tournamentController.createTournamentRound(id, "World Cup FW");
            }
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
        for (Game game : games) {
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
