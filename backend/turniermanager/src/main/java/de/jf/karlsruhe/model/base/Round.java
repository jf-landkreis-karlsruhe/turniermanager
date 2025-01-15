package de.jf.karlsruhe.model.base;

import jakarta.persistence.*;
import java.util.List;

@Entity
public class Round {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@OneToOne
	private AgeGroup ageGroup;

	@OneToOne
	private League league;

	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
	private List<Game> games;

	public Round() {
	}

	public Round(Long id, AgeGroup ageGroup, League league, List<Game> games) {
		this.id = id;
		this.ageGroup = ageGroup;
		this.league = league;
		this.games = games;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public AgeGroup getAgeGroup() {
		return ageGroup;
	}

	public void setAgeGroup(AgeGroup ageGroup) {
		this.ageGroup = ageGroup;
	}

	public League getLeague() {
		return league;
	}

	public void setLeague(League league) {
		this.league = league;
	}

	public List<Game> getGames() {
		return games;
	}

	public void setGames(List<Game> games) {
		this.games = games;
	}

}
