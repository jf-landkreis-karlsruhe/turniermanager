package de.jf.karlsruhe.model.game;

import jakarta.persistence.Entity;

import java.util.List;

public class GameTable {



	private Long leagueId;         // ID der Liga
	private String leagueName;     // Name der Liga (z. B. "U16 Liga 1")
	private String ageGroupName;   // Altersgruppe (z. B. "U16")

	private List<GameInfo> games;  // Liste aller Spiele in dieser Liga

	public GameTable() {}

	// Konstruktor
	public GameTable(Long leagueId, String leagueName, String ageGroupName, List<GameInfo> games) {
		this.leagueId = leagueId;
		this.leagueName = leagueName;
		this.ageGroupName = ageGroupName;
		this.games = games;
	}

	// Getter und Setter
	public Long getLeagueId() {
		return leagueId;
	}

	public void setLeagueId(Long leagueId) {
		this.leagueId = leagueId;
	}

	public String getLeagueName() {
		return leagueName;
	}

	public void setLeagueName(String leagueName) {
		this.leagueName = leagueName;
	}

	public String getAgeGroupName() {
		return ageGroupName;
	}

	public void setAgeGroupName(String ageGroupName) {
		this.ageGroupName = ageGroupName;
	}

	public List<GameInfo> getGames() {
		return games;
	}

	public void setGames(List<GameInfo> games) {
		this.games = games;
	}

	// Subclass GameInfo - enthält Details für einzelne Spiele
	public static class GameInfo {
		private Long gameId;         // ID des Spiels
		private String match;        // Beschreibung des Spiels (z. B. "Team 1 vs Team 3")
		private String result;       // Ergebnis des Spiels (z. B. "2 : 2")
		private String pitch;        // Platz (z. B. "Pitch 1")
		private String startTime;    // Uhrzeit (z. B. "10:15")

		// Konstruktor
		public GameInfo(Long gameId, String match, String result, String pitch, String startTime) {
			this.gameId = gameId;
			this.match = match;
			this.result = result;
			this.pitch = pitch;
			this.startTime = startTime;
		}

		// Getter und Setter
		public Long getGameId() {
			return gameId;
		}

		public void setGameId(Long gameId) {
			this.gameId = gameId;
		}

		public String getMatch() {
			return match;
		}

		public void setMatch(String match) {
			this.match = match;
		}

		public String getResult() {
			return result;
		}

		public void setResult(String result) {
			this.result = result;
		}

		public String getPitch() {
			return pitch;
		}

		public void setPitch(String pitch) {
			this.pitch = pitch;
		}

		public String getStartTime() {
			return startTime;
		}

		public void setStartTime(String startTime) {
			this.startTime = startTime;
		}
	}
}