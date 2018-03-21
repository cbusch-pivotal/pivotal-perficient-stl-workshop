package io.pivotal.pcf.sme.ers.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(exclude = "id")
public class Attendee {
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;
	
	@Column(nullable = false) 
	private String firstName;
	
	private String lastName;
	private String address;
	private String city;	
	private String state;
	private String zipCode;
	private String phoneNumber;
	private String emailAddress;
		

}
