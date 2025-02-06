package de.jf.karlsruhe.service;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;

import jakarta.transaction.Transactional;
import org.hibernate.Hibernate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PitchService {

    private final PitchRepository pitchRepository;
    private final AgeGroupRepository ageGroupRepository;

    public PitchService(PitchRepository pitchRepository, AgeGroupRepository ageGroupRepository) {
        this.pitchRepository = pitchRepository;
        this.ageGroupRepository = ageGroupRepository;
    }

    // Erstellt einen Pitch
    @Transactional
    public Pitch createPitch(Pitch pitch) {
        // Speichere die AgeGroups zuerst
        List<AgeGroup> ageGroups = ageGroupRepository.saveAll(pitch.getAgeGroups());
        pitch.setAgeGroups(ageGroups);

        // Speichere den Pitch
        return pitchRepository.save(pitch);
    }

    // Erstellt mehrere Pitches
    @Transactional
    public List<Pitch> createMultiplePitches(List<Pitch> pitches) {
        for (Pitch pitch : pitches) {
            List<AgeGroup> ageGroups = ageGroupRepository.saveAll(pitch.getAgeGroups());
            pitch.setAgeGroups(ageGroups);
        }
        return pitchRepository.saveAll(pitches);
    }

    // Löscht Pitch nach ID
    @Transactional
    public void deletePitch(Long id) {
        if (!pitchRepository.existsById(id)) {
            throw new RuntimeException("Pitch mit ID " + id + " wurde nicht gefunden.");
        }
        pitchRepository.deleteById(id);
    }

    // Holt alle Pitches inkl. AgeGroups (mit "join fetch")
    @Transactional
    public Pitch getPitchById(Long id) {
        Pitch pitch = pitchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pitch mit ID " + id + " wurde nicht gefunden."));
        Hibernate.initialize(pitch.getAgeGroups()); // Manuell Lazy-Collection initialisieren
        return pitch;
    }


    @Transactional
    public List<Pitch> getAllPitches() {
        return pitchRepository.findAllWithAgeGroups();
    }

}