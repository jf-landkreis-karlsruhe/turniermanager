package de.jf.karlsruhe.logic;

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
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class TournamentIntegrationTest {

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

    private UUID tournamentId;

    @BeforeEach
    public void setUp() {
        createAgeGroups();
        createTeams();
        createPitches();
    }

    private void createAgeGroups() {
        ageGroupRepository.save(AgeGroup.builder().name("U16").build());
        ageGroupRepository.save(AgeGroup.builder().name("U18").build());
        assertThat(ageGroupRepository.count()).isEqualTo(2);
    }

    private void createTeams() {
        AgeGroup u16 = ageGroupRepository.findByName("U16").getFirst();
        AgeGroup u18 = ageGroupRepository.findByName("U18").getFirst();

        List<Team> teams = new ArrayList<>();
        for (int i = 1; i <= 6; i++) {
            teams.add(Team.builder().name("Team U16-" + i).ageGroup(u16).build());
            teams.add(Team.builder().name("Team U18-" + i).ageGroup(u18).build());
        }
        teamRepository.saveAll(teams);
        assertThat(teamRepository.count()).isEqualTo(12);
    }

    private void createPitches() {
        AgeGroup u16 = ageGroupRepository.findByName("U16").getFirst();
        AgeGroup u18 = ageGroupRepository.findByName("U18").getFirst();

        pitchRepository.save(Pitch.builder().name("Pitch 1").ageGroups(List.of(u16, u18)).build());
        pitchRepository.save(Pitch.builder().name("Pitch 2").ageGroups(List.of(u18)).build());
        assertThat(pitchRepository.count()).isEqualTo(2);
    }

    @Test
    public void testTournamentWorkflow() throws Exception {
        createTournament();
        createQualificationRound();
        createMainRound();
    }

    private void createTournament() throws Exception {
        String tournamentName = "Test Tournament";
        LocalDateTime startTime = LocalDateTime.now();
        int playTime = 15;
        int breakTime = 5;

        mockMvc.perform(post("/turniersetup/create")
                        .param("name", tournamentName)
                        .param("startTime", startTime.toString())
                        .param("playTime", String.valueOf(playTime))
                        .param("breakTime", String.valueOf(breakTime)))
                .andExpect(status().isOk());

        Tournament tournament = tournamentRepository.findAll().get(0);
        tournamentId = tournament.getId();

        assertThat(tournament.getName()).isEqualTo(tournamentName);
    }

    private void createQualificationRound() throws Exception {
        mockMvc.perform(post("/turniersetup/create/qualification")
                        .param("tournamentId", tournamentId.toString()))
                .andExpect(status().isOk());

        assertThat(leagueRepository.count()).isGreaterThan(0);
        assertThat(roundRepository.count()).isGreaterThan(0);
    }

    private void createMainRound() throws Exception {
        mockMvc.perform(post("/turniersetup/create/round")
                        .param("tournamentId", tournamentId.toString())
                        .param("roundName", "Main Round"))
                .andExpect(status().isOk());

        assertThat(roundRepository.count()).isGreaterThan(1);
    }
}
