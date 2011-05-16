# Memorable Password

[Kevin McPhillips](mailto:github@kevinmcphillips.ca)


## About

This simple gem generates a random password that is easy to read and remember. It uses dictionary words as well as a list of proper names mixed in with numbers and special characters.

It is, of course, by definition less secure than a truly random password. The intention is to create passwords for the users that they will be able to use and remember that are more secure than "iloveyou", "12345", "password", etc. and that they won't have to attach to their monitor with a sticky note.


## Usage

Generates a password with the default length of 8 characters.

    MemorablePassword.generate
    => "pad8dune"

Generates a password with a specified length.

    MemorablePassword.generate :length => 10
    => "june3eaten"

Generates a password that includes special characters.

    MemorablePassword.generate :special_characters => true
    => "grace!pi"

Generates a password that mixes upper case in.

    MemorablePassword.generate :mixed_case => true
    => "was7Room"


## Feedback

Contact me at [github@kevinmcphillips.ca](mailto:github@kevinmcphillips.ca) with questions or feedback.


