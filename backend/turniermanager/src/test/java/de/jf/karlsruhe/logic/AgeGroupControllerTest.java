package de.jf.karlsruhe.logic;

import com.fasterxml.jackson.databind.ObjectMapper;
import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.AssertionsForInterfaceTypes.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

@SpringBootTest
@AutoConfigureMockMvc
public class AgeGroupControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Test
    public void testCreateAgeGroup() throws Exception {
        // Arrange: Beispiel-Daten für die JSON-Anforderung
        AgeGroup ageGroup = new AgeGroup();
        ageGroup.setName("U18");

        // Act: HTTP-POST-Anfrage an das "/turniersetup/agegroup"-Endpoint senden
        mockMvc.perform(post("/turniersetup/agegroup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(ageGroup))) // JSON-Daten senden
                .andExpect(status().isOk()) // Überprüfen, ob Status 200 zurückkommt
                .andExpect(jsonPath("$.name").value("U18")); // Überprüfen, ob die Antwort korrekt ist

        // Clean-Up (optional): Datenbankeinträge nach dem Test entfernen
        ageGroupRepository.deleteAll();
    }

    @Test
    public void testCreateMultipleAgeGroups() throws Exception {
        // Arrange: Beispiel-Daten für die JSON-Anfrage
        AgeGroup ageGroup1 = new AgeGroup();
        ageGroup1.setName("U12");

        AgeGroup ageGroup2 = new AgeGroup();
        ageGroup2.setName("U15");

        AgeGroup ageGroup3 = new AgeGroup();
        ageGroup3.setName("U18");

        List<AgeGroup> ageGroups = Arrays.asList(ageGroup1, ageGroup2, ageGroup3);

        // Act: HTTP-POST-Anfrage an das "/turniersetup/agegroups"-Endpoint senden
        mockMvc.perform(post("/turniersetup/agegroups")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(ageGroups)))
                .andExpect(status().isOk()) // Überprüfen, ob Status 200 zurückkommt
                .andExpect(jsonPath("$[0].name").value("U12")) // Erster Eintrag
                .andExpect(jsonPath("$[1].name").value("U15")) // Zweiter Eintrag
                .andExpect(jsonPath("$[2].name").value("U18")); // Dritter Eintrag

        // Assert: Überprüfen, dass die Daten korrekt in der Datenbank gespeichert wurden
        List<AgeGroup> savedAgeGroups = ageGroupRepository.findAll();
        assertThat(savedAgeGroups).hasSize(3);
        assertThat(savedAgeGroups).extracting("name").containsExactlyInAnyOrder("U12", "U15", "U18");

        // Clean-Up: Ggf. gespeicherte Testdaten entfernen
        ageGroupRepository.deleteAll();
    }

}