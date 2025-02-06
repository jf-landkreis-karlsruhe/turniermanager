package de.jf.karlsruhe.model.base;

import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
public class Game {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int teamAScore;

    private int teamBScore;

    private LocalDateTime startTime;

    // Platz ist ein @ManyToOne, weil ein Platz mehrere Spiele hosten kann
    @ManyToOne
    @JoinColumn(name = "pitch_id", nullable = false) // Fremdschlüssel "pitch_id" in der Tabelle
    private Pitch pitch;

    // Eine Liga kann viele Spiele haben
    @ManyToOne
    @JoinColumn(name = "league_id", nullable = false) // Fremdschlüssel "league_id" in der Tabelle
    private League league;

    // Team A (Fremdschlüssel) - Ein Team spielt in mehreren Spielen
    @ManyToOne
    @JoinColumn(name = "teama_id", nullable = false) // Fremdschlüssel "teama_id" in der Tabelle
    private Team teamA;

    // Team B (Fremdschlüssel) - Zweites Team
    @ManyToOne
    @JoinColumn(name = "teamb_id", nullable = false) // Fremdschlüssel "teamb_id" in der Tabelle
    private Team teamB;

    public Game() {
    }

    public Game(Long id, Pitch pitch, Team teamA, Team teamB, LocalDateTime startTime) {
        this.id = id;
        this.pitch = pitch;
        this.teamA = teamA;
        this.teamB = teamB;
        this.startTime = startTime;
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

    public int getTeamAScore() {
        return teamAScore;
    }

    public void setTeamAScore(int teamAScore) {
        this.teamAScore = teamAScore;
    }

    public int getTeamBScore() {
        return teamBScore;
    }

    public void setTeamBScore(int teamBScore) {
        this.teamBScore = teamBScore;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public void setLeague(League league) {
        this.league = league;
    }

    public League getLeague() {
        return league;
    }

    public Team getTeamA() {
        return teamA;
    }

    public void setTeamA(Team teamA) {
        this.teamA = teamA;
    }

    public Team getTeamB() {
        return teamB;
    }

    public void setTeamB(Team teamB) {
        this.teamB = teamB;
    }
}