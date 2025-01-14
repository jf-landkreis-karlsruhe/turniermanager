package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.base.Team;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.LeagueRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class LeagueController {

	@Autowired
	private TeamRepository teamRepository;

	@Autowired
	private LeagueRepository leagueRepository;

	@Autowired
	private AgeGroupRepository ageGroupRepository;

	// Erstellen einer Liga ohne Teams
	@PostMapping("/league")
	public ResponseEntity<League> createLeague(@RequestBody League league) {
		AgeGroup ageGroup = league.getAgeGroup();
		AgeGroup savedAgeGroup = ageGroupRepository.save(ageGroup);
		league.setAgeGroup(savedAgeGroup);

		League savedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(savedLeague);
	}

	// Teams zu einer einzelnen Liga hinzufügen
	@PostMapping("/league/{leagueId}/addTeams")
	public ResponseEntity<League> addTeamsToLeague(@PathVariable Long leagueId, @RequestBody List<Long> teamIds) {
		League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RuntimeException("League not found"));

		List<Team> teams = new ArrayList<>();
		for (Long teamId : teamIds) {
			Team team = teamRepository.findById(teamId).orElseThrow(() -> new RuntimeException("Team not found"));
			teams.add(team);
		}

		league.setTeams(teams);
		League updatedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(updatedLeague);
	}

	// Teams aus einer Liga entfernen
	@PostMapping("/league/{leagueId}/removeTeams")
	public ResponseEntity<League> removeTeamsFromLeague(@PathVariable Long leagueId, @RequestBody List<Long> teamIds) {
		League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RuntimeException("League not found"));

		List<Team> currentTeams = league.getTeams();
		currentTeams.removeIf(team -> teamIds.contains(team.getId()));

		league.setTeams(currentTeams);
		League updatedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(updatedLeague);
	}

	// Alle Teams für eine Liga festlegen
	@PostMapping("/league/{leagueId}/setTeams")
	public ResponseEntity<League> setTeamsForLeague(@PathVariable Long leagueId, @RequestBody List<Team> teams) {
		League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RuntimeException("League not found"));

		league.setTeams(teams);
		League updatedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(updatedLeague);
	}

	// Ein einzelnes Team zu einer Liga hinzufügen
	@PostMapping("/league/{leagueId}/addTeam/{teamId}")
	public ResponseEntity<League> addTeamToLeague(@PathVariable Long leagueId, @PathVariable Long teamId) {
		League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RuntimeException("League not found"));

		Team team = teamRepository.findById(teamId).orElseThrow(() -> new RuntimeException("Team not found"));

		league.getTeams().add(team);

		League updatedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(updatedLeague);
	}

	// Ein einzelnes Team aus einer Liga entfernen
	@PostMapping("/league/{leagueId}/removeTeam/{teamId}")
	public ResponseEntity<League> removeTeamFromLeague(@PathVariable Long leagueId, @PathVariable Long teamId) {
		League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RuntimeException("League not found"));

		Team team = teamRepository.findById(teamId).orElseThrow(() -> new RuntimeException("Team not found"));

		league.getTeams().remove(team);

		League updatedLeague = leagueRepository.save(league);
		return ResponseEntity.ok(updatedLeague);
	}

}
