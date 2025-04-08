package com.tmq.jeelab2.model;


import jakarta.persistence.*;

@Entity
@Table(name = "attributes")
public class Attribute {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String attributeName;

    @Column(nullable = false)
    private String attributeValue;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Gettery i Settery
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAttributeName() { return attributeName; }
    public void setAttributeName(String attributeName) { this.attributeName = attributeName; }

    public String getAttributeValue() { return attributeValue; }
    public void setAttributeValue(String attributeValue) { this.attributeValue = attributeValue; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
}
