package io.pivotal.pcf.sme.ers.client.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(exclude = "id")
public class Attendee {
	
	private Long id;
	
	private String firstName;
	private String lastName;	
	private String address;
	private String city;
	private String state;
	private String zipCode;
	private String phoneNumber;
	private String emailAddress;

}
