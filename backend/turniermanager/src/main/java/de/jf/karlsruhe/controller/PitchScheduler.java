package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.base.GameSettings;
import de.jf.karlsruhe.model.repos.GameRepository;
import de.jf.karlsruhe.model.repos.GameSettingsRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@Component
public class PitchScheduler {

    private final PitchRepository pitchRepository; // Repository, um sicherzustellen, dass die Pitches korrekt geladen werden
    private final GameRepository gameRepository;
    private final GameSettingsRepository gamesettingsRepository;

    private List<Pitch> pitches; // Liste der verfügbaren Spielfelder
    private GameSettings gameSettings; // Spieleinstellungen (Dauer, Pausen...)
    private Map<Pitch, LocalDateTime> pitchSchedules = new HashMap<>(); // Nächste verfügbare Zeit für jedes Spielfeld

    public PitchScheduler(PitchRepository pitchRepository, GameRepository gameRepository, GameSettingsRepository gamesettingsRepository) {
        this.pitchRepository = pitchRepository;
        this.gameRepository = gameRepository;
        this.gamesettingsRepository = gamesettingsRepository;
        List<GameSettings> settings = gamesettingsRepository.findAll();
        this.pitches = pitchRepository.findAll();

        if (!settings.isEmpty() && !pitches.isEmpty()) {
            this.gameSettings = settings.getFirst();
            loadSchedules();
        }
    }

    private void loadSchedules() {
        pitchSchedules.clear(); // Stelle sicher, dass die Map leer ist, bevor sie neu befüllt wird

        List<Game> allGames = gameRepository.findAllByOrderByStartTimeAsc();

        for (Game game : allGames) {
            Pitch pitch = game.getPitch();
            LocalDateTime startTime = game.getStartTime();

            // Wenn das Feld noch nicht in der Map ist, füge es hinzu
            pitchSchedules.putIfAbsent(pitch, gameSettings.getStartTime());

            // Aktualisiere die Startzeit, wenn das Spiel später als die aktuelle geplante Zeit ist
            if (startTime.isAfter(pitchSchedules.get(pitch))) {
                pitchSchedules.put(pitch, startTime.plusMinutes(gameSettings.getPlayTime() + gameSettings.getBreakTime()));
            }
        }

        // Falls es Spielfelder gibt, für die keine Spiele geplant sind, initialisiere sie mit der Startzeit der Spieleinstellungen
        for (Pitch pitch : pitches) {
            pitchSchedules.putIfAbsent(pitch, gameSettings.getStartTime());
        }
    }

    /**
     * Initialisiert den Scheduler mit Feldern und Spieleinstellungen.
     *
     * @param pitches      Liste der verfügbaren Felder
     * @param gameSettings Spieleinstellungen (Länge, Pausen, etc.)
     */
    public void initialize(List<Pitch> pitches, GameSettings gameSettings) {
        pitchSchedules.clear();
        this.pitches = pitches;
        this.gameSettings = gameSettings;

        // Alle Felder starten gleich
        pitches.forEach(pitch -> pitchSchedules.put(pitch, gameSettings.getStartTime()));
    }

    /**
     * Sichert, dass die Pitches und ihre Altersgruppen ordnungsgemäß geladen werden, um LazyLoading-Probleme zu vermeiden
     */
    public void preLoadPitchData() {
        // Lade alle relevanten Daten für Pitches vorab, damit keine LazyInitializationException auftritt
        pitches = pitchRepository.findAll(); // Sicherstellen, dass die Pitches und ihre Altersgruppen in der aktuellen Transaktion sind
    }


    /**
     * Plant die Spiele auf die verfügbaren Felder, sodass Felder gleichmäßig verteilt werden.
     *
     * @param games Liste der zu planenden Spiele
     * @return Geplante Spiele mit zugewiesenen Feldern und Zeiten
     */
    public List<Game> scheduleGames(List<Game> games) {
        // Falls die Pitches nicht geladen sind, sicherstellen, dass sie vorab geladen werden
        if (pitches == null || pitches.isEmpty()) {
            preLoadPitchData();
        }

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

    /**
     * Verzögert alle Spiele, die nach einem bestimmten Zeitpunkt geplant sind.
     *
     * @param afterTime Zeitpunkt, ab dem alle Spiele verzögert werden sollen
     * @param minutes   Anzahl der Minuten, um die jedes Spiel verzögert werden soll
     */
    public void delayGamesAfter(LocalDateTime afterTime, int minutes) {
        List<Game> allGames = gameRepository.findAll();
        for (Game game : allGames) {
            if (game.getStartTime().isAfter(afterTime) || game.getStartTime().isEqual(afterTime)) {
                game.setStartTime(game.getStartTime().plusMinutes(minutes));
            }
        }
        gameRepository.saveAll(allGames);
        updatePitchSchedules();
    }

    public void advanceGamesAfter(LocalDateTime afterTime, int minutes) {
        List<Game> allGames = gameRepository.findAll();
        for (Game game : allGames) {
            if (game.getStartTime().isAfter(afterTime) || game.getStartTime().isEqual(afterTime)) {
                game.setStartTime(game.getStartTime().minusMinutes(minutes));
            }
        }
        gameRepository.saveAll(allGames);
        updatePitchSchedules();
    }

    public void shiftGamesBetweenForward(LocalDateTime startTime, LocalDateTime endTime, int minutes) {
        List<Game> allGames = gameRepository.findAll();
        for (Game game : allGames) {
            if ((game.getStartTime().isAfter(startTime) || game.getStartTime().isEqual(startTime)) &&
                    (game.getStartTime().isBefore(endTime) || game.getStartTime().isEqual(endTime))) {
                game.setStartTime(game.getStartTime().minusMinutes(minutes));
            }
        }
        gameRepository.saveAll(allGames);
        updatePitchSchedules();
    }

    public void shiftGamesBetweenBackward(LocalDateTime startTime, LocalDateTime endTime, int minutes) {
        List<Game> allGames = gameRepository.findAll();
        for (Game game : allGames) {
            if ((game.getStartTime().isAfter(startTime) || game.getStartTime().isEqual(startTime)) &&
                    (game.getStartTime().isBefore(endTime) || game.getStartTime().isEqual(endTime))) {
                game.setStartTime(game.getStartTime().plusMinutes(minutes));
            }
        }
        gameRepository.saveAll(allGames);
        updatePitchSchedules();
    }

    private void updatePitchSchedules() {
        pitchSchedules.clear();
        List<Game> allGames = gameRepository.findAll();
        for (Game game : allGames) {
            Pitch pitch = game.getPitch();
            LocalDateTime startTime = game.getStartTime();
            pitchSchedules.putIfAbsent(pitch, gameSettings.getStartTime());
            if (startTime.isAfter(pitchSchedules.get(pitch))) {
                pitchSchedules.put(pitch, startTime.plusMinutes(gameSettings.getPlayTime() + gameSettings.getBreakTime()));
            }
        }
        for (Pitch pitch : pitches) {
            pitchSchedules.putIfAbsent(pitch, gameSettings.getStartTime());
        }
    }



}
