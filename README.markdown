# Memorable Password

[Kevin McPhillips](mailto:github@kevinmcphillips.ca),
[Oleksandr Ulianytskyi](mailto:a.ulyanitsky@gmail.com)

## About

This simple gem generates a random password that is easy to read and remember. It uses dictionary words as well as a list of proper names mixed in with numbers and special characters.

It is, of course, by definition less secure than a truly random password. The intention is to create passwords for the users that they will be able to use and remember that are more secure than "iloveyou", "12345", "password", etc. and that they won't have to attach to their monitor with a sticky note.


## Usage

Generates a password with the default length of 8 characters.

    MemorablePassword.new.generate
    => "pad8dune"

Generates a password with a specified length.

    MemorablePassword.new.generate :length => 10
    => "june3eaten"

Generates a password that is at least a certain length.

    MemorablePassword.new.generate :min_length => 8
    => "gale3covalt"

Generates a password that includes special characters.

    MemorablePassword.new.generate :special_characters => true
    => "grace!pi"

Generates a password that mixes upper case in.

    MemorablePassword.new.generate :mixed_case => true
    => "was7Room"

Generates a password that is two 4-char words joined by non-ambiguous digit (not 2 and 4).

    MemorablePassword.new.generate_simple
    => "sons3pied"

## Feedback

Contact me at [github@kevinmcphillips.ca](mailto:github@kevinmcphillips.ca) with questions or feedback.


## Contributions

- knody on August 1, 2013: Improve support for Ruby 1.8.7
