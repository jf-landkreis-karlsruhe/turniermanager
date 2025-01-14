package de.jf.karlsruhe.model.base;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;

@Entity
public class Team {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String name;
	
	@OneToOne
	private AgeGroup agegroup;

	public Team() {
	}

	public Team(Long id, String name, AgeGroup agegroup) {
		this.id = id;
		this.name = name;
		this.agegroup = agegroup;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public AgeGroup getAgegroup() {
		return agegroup;
	}

	public void setAgegroup(AgeGroup agegroup) {
		this.agegroup = agegroup;
	}

}
