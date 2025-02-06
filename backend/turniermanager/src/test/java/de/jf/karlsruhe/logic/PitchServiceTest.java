package de.jf.karlsruhe.logic;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import de.jf.karlsruhe.service.PitchService;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class PitchServiceTest {

    @Autowired
    private PitchService pitchService;

    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    // Bereinige die Datenbank nach jedem Test
    //@AfterEach
    //public void cleanup() {
    //    pitchRepository.deleteAll();
    //    ageGroupRepository.deleteAll();
    //}

    /**
     * Test: Einen einzelnen Pitch mit zugeordneten AgeGroups erstellen.
     */
    @Transactional
    @Test
    public void testCreatePitch() {
        // Arrange: AgeGroups erstellen und speichern
        AgeGroup ageGroup1 = new AgeGroup();
        ageGroup1.setName("U16");

        AgeGroup ageGroup2 = new AgeGroup();
        ageGroup2.setName("U18");

        List<AgeGroup> savedAgeGroups = ageGroupRepository.saveAll(Arrays.asList(ageGroup1, ageGroup2));

        // Ein Pitch mit den gespeicherten AgeGroups anlegen
        Pitch pitch = new Pitch();
        pitch.setName("Main Pitch");
        pitch.setAgeGroups(savedAgeGroups);

        // Act: Pitch durch den Service speichern
        Pitch savedPitch = pitchService.createPitch(pitch);

        // Assert: Sicherstellen, dass der Pitch korrekt gespeichert wurde
        assertThat(savedPitch.getId()).isNotNull();
        assertThat(savedPitch.getName()).isEqualTo("Main Pitch");
        assertThat(savedPitch.getAgeGroups()).hasSize(2);
        assertThat(savedPitch.getAgeGroups())
                .extracting(AgeGroup::getName)
                .containsExactlyInAnyOrder("U16", "U18");

        // Zusätzlich: Sicherstellen, dass in der Datenbank alles korrekt ist
        List<Pitch> allPitches = pitchRepository.findAll();
        assertThat(allPitches).hasSize(1);
        Pitch databasePitch = allPitches.get(0);

        assertThat(databasePitch.getAgeGroups()).hasSize(2); // Kein LazyInitializationException mehr
    }

    /**
     * Test: Mehrere Pitches mit verschiedenen AgeGroups erstellen.
     */
    @Test
    public void testCreateMultiplePitches() {
        // Arrange: AgeGroups erstellen und speichern
        AgeGroup ageGroup1 = new AgeGroup();
        ageGroup1.setName("U10");

        AgeGroup ageGroup2 = new AgeGroup();
        ageGroup2.setName("U14");

        AgeGroup ageGroup3 = new AgeGroup();
        ageGroup3.setName("U18");

        List<AgeGroup> ageGroups = ageGroupRepository.saveAll(Arrays.asList(ageGroup1, ageGroup2, ageGroup3));

        // Zwei Pitches mit verschiedenen AgeGroups vorbereiten
        Pitch pitch1 = new Pitch();
        pitch1.setName("Pitch 1");
        pitch1.setAgeGroups(List.of(ageGroup1, ageGroup2)); // Zwei AgeGroups zu Pitch 1 hinzufügen

        Pitch pitch2 = new Pitch();
        pitch2.setName("Pitch 2");
        pitch2.setAgeGroups(List.of(ageGroup3)); // Eine AgeGroup zu Pitch 2 hinzufügen

        // Act: Beide Pitches durch den Service speichern
        List<Pitch> savedPitches = pitchService.createMultiplePitches(Arrays.asList(pitch1, pitch2));

        // Assert: Sicherstellen, dass beide Pitches korrekt gespeichert wurden
        assertThat(savedPitches).hasSize(2);

        // Sicherstellen, dass Pitch 1 korrekt ist
        Pitch savedPitch1 = savedPitches.stream()
                .filter(p -> p.getName().equals("Pitch 1"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Pitch 1 not found"));
        assertThat(savedPitch1.getAgeGroups()).hasSize(2);
        assertThat(savedPitch1.getAgeGroups())
                .extracting(AgeGroup::getName)
                .containsExactlyInAnyOrder("U10", "U14");

        // Sicherstellen, dass Pitch 2 korrekt ist
        Pitch savedPitch2 = savedPitches.stream()
                .filter(p -> p.getName().equals("Pitch 2"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Pitch 2 not found"));
        assertThat(savedPitch2.getAgeGroups()).hasSize(1);
        assertThat(savedPitch2.getAgeGroups())
                .extracting(AgeGroup::getName)
                .containsExactly("U18");

        // Zusätzlich: Sicherstellen, dass beide Pitches in der Datenbank existieren
        List<Pitch> allPitches = pitchRepository.findAll();
        assertThat(allPitches).hasSize(2);
    }

    /**
     * Test: Löschen eines Pitch anhand der ID.
     */
    @Test
    public void testDeletePitch() {
        // Arrange: Pitch mit AgeGroups erstellen und speichern
        AgeGroup ageGroup = new AgeGroup();
        ageGroup.setName("U18");
        ageGroup = ageGroupRepository.save(ageGroup); // Speichern

        Pitch pitch = new Pitch();
        pitch.setName("Delete Test Pitch");
        pitch.setAgeGroups(List.of(ageGroup));
        pitch = pitchService.createPitch(pitch); // Speichern

        // Sicherstellen, dass der Pitch initial existiert
        assertThat(pitchRepository.existsById(pitch.getId())).isTrue();

        // Act: Den Pitch löschen lassen
        pitchService.deletePitch(pitch.getId());

        // Assert: Sicherstellen, dass der Pitch wirklich gelöscht wurde
        assertThat(pitchRepository.existsById(pitch.getId())).isFalse();
    }

    /**
     * Test: Alle Pitches laden.
     */
    @Test
    public void testGetAllPitches() {
        // Arrange: Zwei Pitches erstellen und speichern
        AgeGroup ageGroup1 = new AgeGroup();
        ageGroup1.setName("U10");

        AgeGroup ageGroup2 = new AgeGroup();
        ageGroup2.setName("U16");

        List<AgeGroup> savedAgeGroups = ageGroupRepository.saveAll(Arrays.asList(ageGroup1, ageGroup2));

        Pitch pitch1 = new Pitch();
        pitch1.setName("Pitch 1");
        pitch1.setAgeGroups(List.of(savedAgeGroups.get(0))); // U10 zu Pitch 1

        Pitch pitch2 = new Pitch();
        pitch2.setName("Pitch 2");
        pitch2.setAgeGroups(List.of(savedAgeGroups.get(1))); // U16 zu Pitch 2

        pitchService.createMultiplePitches(List.of(pitch1, pitch2));

        // Act: Alle Pitches über den Service abrufen
        List<Pitch> allPitches = pitchService.getAllPitches();

        // Assert: Sicherstellen, dass beide Pitches geladen wurden
        assertThat(allPitches).hasSize(2);
        assertThat(allPitches)
                .extracting(Pitch::getName)
                .containsExactlyInAnyOrder("Pitch 1", "Pitch 2");
    }

    @Test
    @Transactional
    public void testLazyLoading_WithTransactionalTest() {
        // Arrange: Pitch und AgeGroups vorbereiten
        AgeGroup ageGroup = new AgeGroup();
        ageGroup.setName("U15");
        ageGroup = ageGroupRepository.save(ageGroup);

        Pitch pitch = new Pitch();
        pitch.setName("Lazy Pitch");
        pitch.setAgeGroups(List.of(ageGroup));
        pitch = pitchService.createPitch(pitch);

        // Act und Assert: Pitch und AgeGroups direkt überprüfen
        Pitch loadedPitch = pitchService.getPitchById(pitch.getId());
        assertThat(loadedPitch.getAgeGroups()).hasSize(1); // Kein LazyInitializationException
        assertThat(loadedPitch.getAgeGroups().get(0).getName()).isEqualTo("U15");
    }
}