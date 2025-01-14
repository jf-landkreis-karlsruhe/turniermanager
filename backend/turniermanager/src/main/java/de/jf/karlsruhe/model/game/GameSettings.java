package de.jf.karlsruhe.model.game;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalDateTime;

@Entity
public class GameSettings {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private LocalDateTime startTime;
	private int breakTime;
	private int playTime;

	private int greatBreakTime;
	private LocalDateTime greatBreakStartTime;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public LocalDateTime getStartTime() {
		return startTime;
	}

	public void setStartTime(LocalDateTime startTime) {
		this.startTime = startTime;
	}

	public int getBreakTime() {
		return breakTime;
	}

	public void setBreakTime(int breakTime) {
		this.breakTime = breakTime;
	}

	public int getPlayTime() {
		return playTime;
	}

	public void setPlayTime(int playTime) {
		this.playTime = playTime;
	}

	public int getGreatBreakTime() {
		return greatBreakTime;
	}

	public void setGreatBreakTime(int greatBreakTime) {
		this.greatBreakTime = greatBreakTime;
	}

	public LocalDateTime getGreatBreakStartTime() {
		return greatBreakStartTime;
	}

	public void setGreatBreakStartTime(LocalDateTime greatBreakStartTime) {
		this.greatBreakStartTime = greatBreakStartTime;
	}

}
