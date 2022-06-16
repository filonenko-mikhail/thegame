// Code generated by github.com/99designs/gqlgen, DO NOT EDIT.

package model

type Card struct {
	ID       string  `json:"id"`
	Text     string  `json:"text"`
	X        float64 `json:"x"`
	Y        float64 `json:"y"`
	Color    int     `json:"color"`
	Flipable bool    `json:"flipable"`
	Flip     bool    `json:"flip"`
	Fliptext string  `json:"fliptext"`
	Prio     int     `json:"prio"`
	Sizex    float64 `json:"sizex"`
	Sizey    float64 `json:"sizey"`
}

type CardAddEvent struct {
	ID       string  `json:"id"`
	Text     string  `json:"text"`
	X        float64 `json:"x"`
	Y        float64 `json:"y"`
	Color    int     `json:"color"`
	Flipable bool    `json:"flipable"`
	Flip     bool    `json:"flip"`
	Fliptext string  `json:"fliptext"`
	Prio     int     `json:"prio"`
	Sizex    float64 `json:"sizex"`
	Sizey    float64 `json:"sizey"`
}

type CardAddPayload struct {
	ID       string  `json:"id"`
	Text     string  `json:"text"`
	X        float64 `json:"x"`
	Y        float64 `json:"y"`
	Color    int     `json:"color"`
	Flipable bool    `json:"flipable"`
	Flip     bool    `json:"flip"`
	Fliptext string  `json:"fliptext"`
	Prio     int     `json:"prio"`
	Sizex    float64 `json:"sizex"`
	Sizey    float64 `json:"sizey"`
}

type CardEvent struct {
	Add    *CardAddEvent    `json:"add"`
	Remove *CardRemoveEvent `json:"remove"`
	Move   *CardMoveEvent   `json:"move"`
}

type CardFlipPayload struct {
	ID   string `json:"id"`
	Flip bool   `json:"flip"`
}

type CardMoveEvent struct {
	ID string  `json:"id"`
	X  float64 `json:"x"`
	Y  float64 `json:"y"`
}

type CardMovePayload struct {
	ID string  `json:"id"`
	X  float64 `json:"x"`
	Y  float64 `json:"y"`
}

type CardMutations struct {
	Add    *Card `json:"add"`
	Move   *Card `json:"move"`
	Remove *Card `json:"remove"`
	Flip   *Card `json:"flip"`
	Prio   *Card `json:"prio"`
}

type CardPrioPayload struct {
	ID   string `json:"id"`
	Prio int    `json:"prio"`
}

type CardQueries struct {
	List []*Card `json:"list"`
}

type CardRemoveEvent struct {
	ID string `json:"id"`
}

type CardRemovePayload struct {
	ID string `json:"id"`
}

type Chip struct {
	ID    string  `json:"id"`
	Color int     `json:"color"`
	X     float64 `json:"x"`
	Y     float64 `json:"y"`
}

type ChipAddPayload struct {
	ID    string  `json:"id"`
	Color int     `json:"color"`
	X     float64 `json:"x"`
	Y     float64 `json:"y"`
}

type ChipMovePayload struct {
	ID string  `json:"id"`
	X  float64 `json:"x"`
	Y  float64 `json:"y"`
}

type ChipMutations struct {
	Add    *Chip `json:"add"`
	Move   *Chip `json:"move"`
	Remove *Chip `json:"remove"`
}

type ChipQueries struct {
	List []*Chip `json:"list"`
}

type DiceMutations struct {
	Set int `json:"set"`
}

type DiceQueries struct {
	Val int `json:"val"`
}

type IntuitionMutations struct {
	Set bool `json:"set"`
}

type IntuitionQueries struct {
	Val bool `json:"val"`
}

type Update struct {
	ID string `json:"id"`
}
