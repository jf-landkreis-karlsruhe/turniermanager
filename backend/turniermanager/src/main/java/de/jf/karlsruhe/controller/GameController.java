package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.base.Team;
import de.jf.karlsruhe.model.repos.GameRepository;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/games")
@RequiredArgsConstructor
public class GameController {

    private final GameRepository gameRepository;
    private final PitchScheduler pitchScheduler;

    /**
     * Spielergebnisse eintragen/aktualisieren
     *
     * @param gameId     ID des Spiels
     * @param teamAScore Punktzahl von Team A
     * @param teamBScore Punktzahl von Team B
     * @return Das aktualisierte Spiel
     */
    @PostMapping("/updatebyid/{gameId}")
    public ResponseEntity<Game> updateGameScores(@PathVariable UUID gameId,
                                                 @RequestParam int teamAScore,
                                                 @RequestParam int teamBScore) {
        // Spiel aus der Datenbank abrufen
        Game game = gameRepository.findById(gameId)
                .orElseThrow(() -> new IllegalArgumentException("Spiel mit ID " + gameId + " nicht gefunden"));

        // Ergebnisse setzen
        game.setTeamAScore(teamAScore);
        game.setTeamBScore(teamBScore);

        // Aktualisiertes Spiel speichern
        Game updatedGame = gameRepository.save(game);
        return ResponseEntity.ok(updatedGame);
    }

    @PostMapping("/update/{gameNumber}")
    public ResponseEntity<Game> updateGameScoresByNumber(@PathVariable int gameNumber,
                                                         @RequestParam int teamAScore,
                                                         @RequestParam int teamBScore) {
        // Spiel anhand der gameNumber abrufen
        Game game = gameRepository.findByGameNumber(gameNumber)
                .orElseThrow(() -> new IllegalArgumentException("Spiel mit Nummer " + gameNumber + " nicht gefunden"));

        // Ergebnisse setzen
        game.setTeamAScore(teamAScore);
        game.setTeamBScore(teamBScore);

        // Spiel aktualisieren
        Game updatedGame = gameRepository.save(game);
        return ResponseEntity.ok(updatedGame);
    }


    /**
     * Ausgabe für ein bestimmtes Spiel erstellen
     *
     * @param gameId ID des Spiels
     * @return Details zum Spiel
     */
    @GetMapping("/{gameId}/details")
    public ResponseEntity<String> getGameDetails(@PathVariable UUID gameId) {
        Game game = gameRepository.findById(gameId)
                .orElseThrow(() -> new IllegalArgumentException("Spiel mit ID " + gameId + " nicht gefunden"));

        // Details des Spiels formatiert zurückgeben
        String gameDetails = String.format(
                "Spiel-ID: %s\n" +
                        "Spielbeginn: %s\n" +
                        "Team A: %s [Punkte: %d]\n" +
                        "Team B: %s [Punkte: %d]\n" +
                        "Spielfeld: %s",
                game.getId(),
                game.getStartTime(),
                game.getTeamA().getName(), game.getTeamAScore(),
                game.getTeamB().getName(), game.getTeamBScore(),
                game.getPitch() != null ? game.getPitch().getName() : "Kein Spielfeld"
        );
        return ResponseEntity.ok(gameDetails);
    }

    /**
     * Alle Spiele für ein bestimmtes Spielfeld ausgeben
     *
     * @param pitchId ID des Spielfelds
     * @return Eine Liste von Spielen auf dem Spielfeld
     */
    @GetMapping("/pitch/{pitchId}")
    public ResponseEntity<List<Game>> getGamesByPitch(@PathVariable UUID pitchId) {
        // Alle Spiele für das betreffende Spielfeld abrufen
        List<Game> games = gameRepository.findByPitchId(pitchId);

        if (games.isEmpty()) {
            return ResponseEntity.noContent().build(); // Falls keine Spiele vorhanden sind
        }

        return ResponseEntity.ok(games);
    }

    @PostMapping("/refreshTimings")
    public ResponseEntity<String> refreshTimings(@RequestBody TimingRequest request) {
        LocalDateTime startTime = request.getStartTime();
        LocalDateTime actualStartTime = request.getActualStartTime();

        if (actualStartTime.isBefore(startTime)) {
            Duration duration = Duration.between(actualStartTime, startTime);
            long minutes = duration.toMinutes();
            pitchScheduler.advanceGamesAfter(startTime, (int) minutes);
            return ResponseEntity.ok("Actual start time was " + minutes + " minutes early.");
        } else if (actualStartTime.isAfter(startTime)) {
            Duration duration = Duration.between(startTime, actualStartTime);
            long minutes = duration.toMinutes();
            pitchScheduler.delayGamesAfter(startTime, (int) minutes);
            return ResponseEntity.ok("Actual start time was " + minutes + " minutes late.");
        } else {
            return ResponseEntity.ok("Actual start time was on time.");
        }
    }

    @GetMapping("/activeGamesSortedDateTimeList")
    public List<GameScheduleDateTimeDTO> getActiveGamesSortedDateTimeList() {
        List<Game> activeGames = gameRepository.findByRound_ActiveTrueOrderByStartTimeAsc();
        TreeMap<LocalDateTime, List<GameDTO>> groupedGames = new TreeMap<>();

        for (Game game : activeGames) {
            LocalDateTime startTime = game.getStartTime();
            TeamDTO teamADTO = new TeamDTO(game.getTeamA().getId(), game.getTeamA().getName());
            TeamDTO teamBDTO = new TeamDTO(game.getTeamB().getId(), game.getTeamB().getName());
            PitchDTO pitchDTO = new PitchDTO(game.getPitch().getId(), game.getPitch().getName());
            GameDTO gameDTO = new GameDTO(game.getId(), game.getGameNumber(), teamADTO, teamBDTO, pitchDTO);
            groupedGames.computeIfAbsent(startTime, k -> new ArrayList<>()).add(gameDTO);
        }

        List<GameScheduleDateTimeDTO> result = new ArrayList<>();
        groupedGames.forEach((startTime, games) -> result.add(new GameScheduleDateTimeDTO(startTime, games)));

        return result;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public class GameScheduleDateTimeDTO {
        private LocalDateTime startTime;
        private List<GameDTO> games;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public class GameDTO {
        private UUID id;
        private long gameNumber;
        private TeamDTO teamA;
        private TeamDTO teamB;
        private PitchDTO pitch;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public class PitchDTO {
        private UUID id;
        private String name;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public class TeamDTO {
        private UUID id;
        private String name;
    }

    @Data
    private static class TimingRequest {
        private LocalDateTime startTime;
        private LocalDateTime actualStartTime;
        private LocalDateTime endTime;
    }
}