package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.game.GameSettings;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;

@Component
public class PitchScheduler {

    private List<Pitch> pitches; // Liste der verfügbaren Spielfelder
    private GameSettings gameSettings; // Spieleinstellungen (Dauer, Pausen...)
    private Map<Pitch, LocalDateTime> pitchSchedules = new HashMap<>(); // Nächste verfügbare Zeit für jedes Spielfeld

    /**
     * Initialisiert den Scheduler mit Feldern und Spieleinstellungen.
     *
     * @param pitches      Liste der verfügbaren Felder
     * @param gameSettings Spieleinstellungen (Länge, Pausen, etc.)
     */
    public void initialize(List<Pitch> pitches, GameSettings gameSettings) {
        pitchSchedules.clear();
        if (this.pitches != null) this.pitches.clear();
        this.pitches = pitches;
        this.gameSettings = gameSettings;
        pitches.forEach(pitch -> pitchSchedules.put(pitch, gameSettings.getStartTime())); // Alle Felder starten gleich
    }

    /**
     * Plant die Spiele auf die verfügbaren Felder, sodass Felder gleichmäßig verteilt werden.
     *
     * @param games Liste der zu planenden Spiele
     * @return Geplante Spiele mit zugewiesenen Feldern und Zeiten
     */
    public List<Game> scheduleGames(List<Game> games) {
        // Rotations-Index für die Felder
        Iterator<Pitch> pitchIterator = pitches.iterator();

        for (Game game : games) {
            // Suche nächstes Feld in Round-Robin-Manier
            if (!pitchIterator.hasNext()) {
                pitchIterator = pitches.iterator(); // Zurück zum ersten Feld
            }

            // Nächstes Spielfeld aus der Rotation auswählen
            Pitch assignedPitch = pitchIterator.next();

            // Erreiche die nächste verfügbare Zeit für dieses Spielfeld
            LocalDateTime assignedStartTime = pitchSchedules.get(assignedPitch);

            // Prüfe, ob das Feld die Altersgruppe des Spiels unterstützt
            while (!supportsAgeGroup(assignedPitch, game)) {
                if (!pitchIterator.hasNext()) {
                    pitchIterator = pitches.iterator(); // Zurück zum ersten Feld
                }
                assignedPitch = pitchIterator.next();
                assignedStartTime = pitchSchedules.get(assignedPitch); // Aktualisiere die Zeit
            }

            // Setze die Startzeit und das Spielfeld für das Spiel
            game.setStartTime(assignedStartTime);
            game.setPitch(assignedPitch);

            // Aktualisiere den Zeitplan für dieses Spielfeld
            pitchSchedules.put(assignedPitch, assignedStartTime.plusMinutes(gameSettings.getPlayTime() + gameSettings.getBreakTime()));
        }

        return games;
    }

    /**
     * Prüft, ob ein Feld für die Altersgruppe des Spiels geeignet ist.
     *
     * @param pitch Das zu prüfende Spielfeld
     * @param game  Das zu prüfende Spiel
     * @return true, wenn das Feld die Altersgruppe der Teams unterstützt; andernfalls false.
     */
    private boolean supportsAgeGroup(Pitch pitch, Game game) {
        AgeGroup teamAAgeGroup = game.getTeamA().getAgeGroup();
        AgeGroup teamBAgeGroup = game.getTeamB().getAgeGroup();
        return pitch.getAgeGroups().contains(teamAAgeGroup) && pitch.getAgeGroups().contains(teamBAgeGroup);
    }

    public void delayGamesAfter(LocalDateTime afterTime, int minutes) {
        for (Map.Entry<Pitch, LocalDateTime> entry : pitchSchedules.entrySet()) {
            LocalDateTime scheduledTime = entry.getValue();

            // Überprüft, ob das Spiel nach der Pausenzeit stattfindet oder genau zur gleichen Stunde und Minute
            if (scheduledTime.isAfter(afterTime) ||
                    (scheduledTime.getHour() == afterTime.getHour() && scheduledTime.getMinute() == afterTime.getMinute())) {
                pitchSchedules.put(entry.getKey(), scheduledTime.plusMinutes(minutes));
            }
        }
    }

}