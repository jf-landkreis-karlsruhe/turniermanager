package de.jf.karlsruhe.model.game;

import java.util.List;

import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.League;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

@Entity
public class GameTable {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@OneToOne
	private League league;

	@OneToMany
	private List<Game> games;

	public GameTable() {
	}

	public GameTable(Long id, League league, List<Game> games) {
		this.id = id;
		this.league = league;
		this.games = games;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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
