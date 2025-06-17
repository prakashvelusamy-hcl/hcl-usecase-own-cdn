Feature: Ensure no security group allows SSH from the public internet

  Scenario: Security groups must not allow port 22 from 0.0.0.0/0
    Given I have aws_security_group defined
    When it contains ingress
    And it contains port 22
    And it contains cidr_blocks
    Then its value must not be 0.0.0.0/0