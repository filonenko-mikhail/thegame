CREATE TABLE cards(
    card_id UUID NOT NULL,
    body TEXT NOT NULL,
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL,

    color BIGINT NOT NULL,

    flipable BOOLEAN NOT NULL,
    flip BOOLEAN NOT NULL,
    fliptext TEXT NOT NULL,
    prio INT NOT NULL,

    sizex DOUBLE NOT NULL,
    sizey DOUBLE NOT NULL,
    PRIMARY KEY(card_id)
);

CREATE TABLE chips(
    chip_id UUID NOT NULL,
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL,
    color BIGINT NOT NULL,
    PRIMARY KEY(chip_id)
)
