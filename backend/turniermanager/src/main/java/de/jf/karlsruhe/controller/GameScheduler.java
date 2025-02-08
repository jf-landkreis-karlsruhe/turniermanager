package de.jf.karlsruhe.logic;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;

@Component
public class GameScheduler {

    // Map für Altersgruppe -> Spielfelder und ihre Verfügbarkeiten
    private final Map<AgeGroup, Map<Pitch, LocalDateTime>> ageGroupPitchAvailability = new HashMap<>();

    /**
     * Initialisiert den Scheduler mit allen Spielfeldern und einer Startzeit.
     *
     * @param pitches   Liste der verfügbaren Spielfelder.
     * @param startTime Startzeit für die Planung.
     */
    public void initialize(List<Pitch> pitches, LocalDateTime startTime) {
        ageGroupPitchAvailability.clear();

        for (Pitch pitch : pitches) {
            for (AgeGroup ageGroup : pitch.getAgeGroups()) {
                ageGroupPitchAvailability
                        .computeIfAbsent(ageGroup, k -> new HashMap<>())
                        .put(pitch, startTime);
            }
        }
    }

    /**
     * Plant ein Spiel basierend auf Spielfeld-Verfügbarkeit der Altersgruppe.
     * Wenn kein freies Spielfeld vorhanden ist, wird das Spiel auf das frühest mögliche Zeitfenster verschoben.
     *
     * @param game      Das zu planende Spiel.
     * @param ageGroup  Die Altersgruppe der Teams.
     * @param playTime  Spielzeit in Minuten.
     * @param breakTime Pausenzeit zwischen Spielen in Minuten.
     * @return Das geplante Spiel mit zugewiesenem Spielfeld und Startzeit.
     */
    public Game scheduleGame(Game game, AgeGroup ageGroup, int playTime, int breakTime) {
        // Prüfen, ob es Pitches für diese Altersgruppe gibt
        Map<Pitch, LocalDateTime> pitchAvailability = ageGroupPitchAvailability.get(ageGroup);

        if (pitchAvailability == null || pitchAvailability.isEmpty()) {
            throw new IllegalArgumentException("No available pitches for age group: " + ageGroup.getName());
        }

        // Freies Spielfeld und frühest mögliche Zeit finden
        Pitch selectedPitch = null;
        LocalDateTime earliestAvailableTime = LocalDateTime.MAX;

        for (Map.Entry<Pitch, LocalDateTime> entry : pitchAvailability.entrySet()) {
            if (entry.getValue().isBefore(earliestAvailableTime)) {
                selectedPitch = entry.getKey();
                earliestAvailableTime = entry.getValue();
            }
        }

        // Spiel auf den frühest möglichen Zeitpunkt und Pitch setzen
        if (selectedPitch != null) {
            game.setPitch(selectedPitch);
            game.setStartTime(earliestAvailableTime);

            // Verfügbarkeit des Pitches aktualisieren
            LocalDateTime newAvailableTime = earliestAvailableTime.plusMinutes(playTime + breakTime);
            pitchAvailability.put(selectedPitch, newAvailableTime);
        }

        return game;
    }
}