CREATE TABLE cards(
    card_id UUID NOT NULL,
    body TEXT,
    X FLOAT,
    Y FLOAT,
    info TEXT,

    color BIGINT,

    flipable BOOLEAN,
    PRIMARY KEY(card_id)
);
