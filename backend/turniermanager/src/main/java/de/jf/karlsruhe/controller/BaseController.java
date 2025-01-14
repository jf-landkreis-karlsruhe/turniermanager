package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.base.Team;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.LeagueRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class BaseController {

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private TeamRepository teamRepository;

    @PostMapping("/createAgeGroup")
    public ResponseEntity<AgeGroup> createAgeGroup(@RequestBody AgeGroup ageGroup) {
        AgeGroup savedAgeGroup = ageGroupRepository.save(ageGroup);
        return ResponseEntity.ok(savedAgeGroup);
    }

    @PostMapping("/createLeague")
    public ResponseEntity<League> createLeague(@RequestBody League league) {
        League savedLeague = leagueRepository.save(league);
        return ResponseEntity.ok(savedLeague);
    }

    @PostMapping("/createPitch")
    public ResponseEntity<Pitch> createPitch(@RequestBody Pitch pitch) {
        Pitch savedPitch = pitchRepository.save(pitch);
        return ResponseEntity.ok(savedPitch);
    }

    @PostMapping("/createTeam")
    public ResponseEntity<Team> createTeam(@RequestBody Team team) {
        Team savedTeam = teamRepository.save(team);
        return ResponseEntity.ok(savedTeam);
    }
}
