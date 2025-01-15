package de.jf.karlsruhe.model.base;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;

@Entity
public class Game {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private int points;
	
	private int againstPoints;

	@OneToOne
	private Pitch pitch;

	@OneToOne
	private Team teamOne;

	@OneToOne
	private Team teamTwo;

	public Game() {
	}

	public Game(Long id, Pitch pitch, Team teamOne, Team teamTwo) {
		this.id = id;
		this.pitch = pitch;
		this.teamOne = teamOne;
		this.teamTwo = teamTwo;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Pitch getPitch() {
		return pitch;
	}

	public void setPitch(Pitch pitch) {
		this.pitch = pitch;
	}

	public Team getTeamOne() {
		return teamOne;
	}

	public void setTeamOne(Team teamOne) {
		this.teamOne = teamOne;
	}

	public Team getTeamTwo() {
		return teamTwo;
	}

	public void setTeamTwo(Team teamTwo) {
		this.teamTwo = teamTwo;
	}

	public int getPoints() {
		return points;
	}

	public void setPoints(int points) {
		this.points = points;
	}

	public int getAgainstPoints() {
		return againstPoints;
	}

	public void setAgainstPoints(int againstPoints) {
		this.againstPoints = againstPoints;
	}
}
