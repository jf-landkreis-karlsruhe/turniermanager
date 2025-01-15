package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class PitchController {

    @Autowired
    private PitchRepository pitchRepository;
    
    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @PostMapping("/pitch")
    public ResponseEntity<Pitch> createPitch(@RequestBody Pitch pitch) {
        AgeGroup ageGroup = pitch.getAgegroup();
        AgeGroup savedAgeGroup = ageGroupRepository.save(ageGroup);
        pitch.setAgegroup(savedAgeGroup);
        Pitch savedPitch = pitchRepository.save(pitch);
        return ResponseEntity.ok(savedPitch);
    }
    
    @DeleteMapping("/pitch/{id}")
    public ResponseEntity<Void> deletePitch(@PathVariable Long id) {
        if (pitchRepository.existsById(id)) {
            pitchRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
