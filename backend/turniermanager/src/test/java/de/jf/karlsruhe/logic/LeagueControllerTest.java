package de.jf.karlsruhe.logic;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;

@SpringBootTest // Startet den gesamten Spring-Kontext
@AutoConfigureMockMvc // Initiert MockMvc für Integrationstests
@Transactional // Alle Datenbankänderungen werden nach jedem Test zurückgesetzt
public class LeagueControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private GameRepository gameRepository;

    @Autowired
    TeamRepository teamRepository;

    @Autowired
    AgeGroupRepository ageGroupRepository;

    @Autowired
    PitchRepository pitchRepository;

    @BeforeEach
    public void setupTestData() {
        // Alle verknüpften Daten löschen (wichtig für Tests mit persistenten Datenbanken)
        gameRepository.deleteAll();
        leagueRepository.deleteAll();
        teamRepository.deleteAll();
        pitchRepository.deleteAll();
        ageGroupRepository.deleteAll();

        // 1. Mehrere Teams erstellen (z. B. 10 Teams)
        List<Team> teams = new ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            Team team = new Team();
            team.setName("Team " + i);
            teams.add(team); // Speichern in der Datenbank
        }
        teamRepository.saveAll(teams);

        // 2. Pitches erstellen (3 Plätze)
        List<Pitch> pitches = new ArrayList<>();
        for (int i = 1; i <= 3; i++) {
            Pitch pitch = new Pitch();
            pitch.setName("Pitch " + i);
            pitches.add(pitchRepository.save(pitch)); // Speichern in der Datenbank
        }

        // 3. AgeGroup erstellen
        AgeGroup ageGroup = new AgeGroup();
        ageGroup.setName("U18");
        ageGroup = ageGroupRepository.save(ageGroup);

        // 4. League erstellen
        League league = new League();
        league.setName("Champion League");
        league.setAgeGroup(ageGroup);
        league = leagueRepository.save(league); // Speichern

        List<Game> games = new ArrayList<>();
        // 5. Spiele erstellen (Teams in zufälligen Kombinationen)
        LocalDateTime startTime = LocalDateTime.of(2023, 11, 10, 15, 0);
        for (int i = 0; i < teams.size(); i++) {
            for (int j = i + 1; j < teams.size(); j++) {
                Game game = new Game();

                // Setze die Teams
                game.setTeamA(teams.get(i));
                game.setTeamB(teams.get(j));

                // Liga zuweisen
                game.setLeague(league);

                // Platz rotierend auswählen
                game.setPitch(pitches.get((i + j) % pitches.size()));

                // Startzeit mit einem eindeutigen Offset versehen
                game.setStartTime(startTime.plusHours(i + j)); // Verschiedene Startzeit für jede Paarung

                // Zufällige Punktestände generieren (falls benötigt)
                game.setTeamAScore((int) (i));
                game.setTeamBScore((int) (j));

                // Eindeutigen Game-Eintrag zur Liste hinzufügen
                games.add(game);
            }
        }

        gameRepository.saveAll(games);
    }

    @Test
    public void testGetAllLeaguesTable_ReturnsDataFromDatabase() throws Exception {
        List<Game> all = gameRepository.findAll();
        mockMvc.perform(get("/league/table"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].leagueName", equalTo("Champion League")))
                .andExpect(jsonPath("$[0].ageGroupName", equalTo("U18")))
                .andExpect(jsonPath("$[0].games", hasSize(45)))
                .andExpect(jsonPath("$[0].games[0].match", equalTo("Team 1 vs Team 2")))
                .andExpect(jsonPath("$[0].games[0].result", equalTo("Noch offen")))
                .andExpect(jsonPath("$[0].games[0].pitch", equalTo("Pitch 2")))
                .andExpect(jsonPath("$[0].games[0].startTime", equalTo("16:00")));
    }

    @Test
    public void testGetAllLeaguesTable_NoGamesInLeague_ReturnsEmptyGamesList() throws Exception {
        // Arrange: Leere Liga anlegen
        AgeGroup ageGroup = new AgeGroup();
        ageGroup.setName("U16");
        ageGroup = ageGroupRepository.save(ageGroup); // ageGroup manuell persistieren

        League emptyLeague = new League();
        emptyLeague.setName("Empty League");
        emptyLeague.setAgeGroup(ageGroup); // Persistierte AgeGroup zuweisen
        leagueRepository.save(emptyLeague);

        // Act & Assert
        mockMvc.perform(get("/league/table"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2))) // Es gibt jetzt 2 Ligen
                .andExpect(jsonPath("$[1].leagueName", equalTo("Empty League")))
                .andExpect(jsonPath("$[1].games", hasSize(0))); // Keine Spiele
    }

    @Test
    public void testGetAllLeaguesTable_NoLeagues_ReturnsEmptyList() throws Exception {
        // Arrange + Act: Datenbank zurücksetzen, alle Einträge löschen
        gameRepository.deleteAll();
        leagueRepository.deleteAll();

        // Act & Assert
        mockMvc.perform(get("/league/table"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }
}