package de.jf.karlsruhe.model.game;

import java.util.List;

import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.repos.GameTableEntryRepository;
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
	private List<TableEntry> entries;

	public GameTable() {
	}

	public GameTable(Long id, League league, List<TableEntry> entries) {
		this.id = id;
		this.league = league;
		this.entries = entries;
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

	public List<TableEntry> getEntries() {
		return entries;
	}

	public void setEntries(List<TableEntry> entries) {
		this.entries = entries;
	}

}
