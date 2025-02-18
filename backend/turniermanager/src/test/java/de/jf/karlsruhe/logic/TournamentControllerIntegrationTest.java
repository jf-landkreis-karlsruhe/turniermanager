package de.jf.karlsruhe.logic;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class TournamentControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TournamentRepository tournamentRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private RoundRepository roundRepository;

    @Autowired
    private GameRepository gameRepository;

    @BeforeEach
    public void setUp() {
        createTestData();
    }

    private void createTestData() {
        // Erstellen von Altersgruppen
        AgeGroup u16 = ageGroupRepository.save(AgeGroup.builder().name("U16").build());
        AgeGroup u18 = ageGroupRepository.save(AgeGroup.builder().name("U18").build());

        for (int i = 0; i < 5; i++) {
            // Erstellen von Pitches
            Pitch pitch1 = Pitch.builder().name("Pitch 1" + i).ageGroups(List.of(u16, u18)).build();
            Pitch pitch2 = Pitch.builder().name("Pitch 2" + i).ageGroups(List.of(u18)).build();
            pitchRepository.saveAll(List.of(pitch1, pitch2));
        }

        // Erstellen von Teams für verschiedene Altersgruppen
        List<Team> teams = new ArrayList<>();
        for (int i = 1; i < 12; i++) {
            Team team1 = Team.builder().name("Team " + i).ageGroup(u16).build();
            teams.add(team1);
        }

        teamRepository.saveAll(teams);
    }

    @Test
    public void testCreateTournament() throws Exception {
        // Turnier-Erstellungs-Request an den Controller senden
        String tournamentName = "Indiaca Cup";
        LocalDateTime startTime = LocalDateTime.now();
        int playTime = 15;  // 30 Minuten pro Spiel
        int breakTime = 10; // 10 Minuten Pause zwischen Spielen

        mockMvc.perform(post("/turniersetup/create")
                        .param("name", tournamentName)
                        .param("startTime", startTime.toString())
                        .param("playTime", String.valueOf(playTime))
                        .param("breakTime", String.valueOf(breakTime)))
                .andExpect(status().isOk());

        // Überprüfen, ob das Turnier angelegt wurde
        List<Tournament> tournaments = tournamentRepository.findAll();
        assertThat(tournaments).hasSize(1);

        Tournament tournament = tournaments.get(0);
        assertThat(tournament.getName()).isEqualTo(tournamentName);
    }
}