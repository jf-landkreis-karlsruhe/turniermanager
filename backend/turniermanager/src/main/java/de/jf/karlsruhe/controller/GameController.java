package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.repos.GameRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/games")
@RequiredArgsConstructor
public class GameController {

    private final GameRepository gameRepository;

    /**
     * Spielergebnisse eintragen/aktualisieren
     *
     * @param gameId      ID des Spiels
     * @param teamAScore  Punktzahl von Team A
     * @param teamBScore  Punktzahl von Team B
     * @return Das aktualisierte Spiel
     */
    @PostMapping("/{gameId}/update")
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

}