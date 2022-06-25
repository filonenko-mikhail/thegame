// Code generated by github.com/99designs/gqlgen, DO NOT EDIT.

package model

import (
	"fmt"
	"io"
	"strconv"
)

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
	Prio   *CardPrioEvent   `json:"prio"`
	Flip   *CardFlipEvent   `json:"flip"`
}

type CardFlipEvent struct {
	ID   string `json:"id"`
	Flip bool   `json:"flip"`
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

type CardPrioEvent struct {
	ID   string `json:"id"`
	Prio int    `json:"prio"`
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

type ChipAddEvent struct {
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

type ChipEvent struct {
	Add    *ChipAddEvent    `json:"add"`
	Remove *ChipRemoveEvent `json:"remove"`
	Move   *ChipMoveEvent   `json:"move"`
}

type ChipMoveEvent struct {
	ID string  `json:"id"`
	X  float64 `json:"x"`
	Y  float64 `json:"y"`
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

type ChipRemoveEvent struct {
	ID string `json:"id"`
}

type Content struct {
	ID          string       `json:"id"`
	Type        *ContentType `json:"type"`
	Title       *string      `json:"title"`
	Description *string      `json:"description"`
}

type ContentQueries struct {
	List []*Content `json:"list"`
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

type ContentType string

const (
	ContentTypeAngel            ContentType = "ANGEL"
	ContentTypePhysicalKnowing  ContentType = "PHYSICAL_KNOWING"
	ContentTypeEmotionalKnowing ContentType = "EMOTIONAL_KNOWING"
	ContentTypeMentalKnowing    ContentType = "MENTAL_KNOWING"
	ContentTypeSpiritKnowing    ContentType = "SPIRIT_KNOWING"
	ContentTypeInsight          ContentType = "INSIGHT"
	ContentTypeSetback          ContentType = "SETBACK"
	ContentTypeFeedback         ContentType = "FEEDBACK"
)

var AllContentType = []ContentType{
	ContentTypeAngel,
	ContentTypePhysicalKnowing,
	ContentTypeEmotionalKnowing,
	ContentTypeMentalKnowing,
	ContentTypeSpiritKnowing,
	ContentTypeInsight,
	ContentTypeSetback,
	ContentTypeFeedback,
}

func (e ContentType) IsValid() bool {
	switch e {
	case ContentTypeAngel, ContentTypePhysicalKnowing, ContentTypeEmotionalKnowing, ContentTypeMentalKnowing, ContentTypeSpiritKnowing, ContentTypeInsight, ContentTypeSetback, ContentTypeFeedback:
		return true
	}
	return false
}

func (e ContentType) String() string {
	return string(e)
}

func (e *ContentType) UnmarshalGQL(v interface{}) error {
	str, ok := v.(string)
	if !ok {
		return fmt.Errorf("enums must be strings")
	}

	*e = ContentType(str)
	if !e.IsValid() {
		return fmt.Errorf("%s is not a valid ContentType", str)
	}
	return nil
}

func (e ContentType) MarshalGQL(w io.Writer) {
	fmt.Fprint(w, strconv.Quote(e.String()))
}
