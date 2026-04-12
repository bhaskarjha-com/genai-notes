# Anki And Spaced Repetition

These exports are the low-friction version of Phase 8a: track-based interview decks that work with Anki immediately, without introducing a packaging dependency chain.

## What You Get

- A [Master Deck](../downloads/anki/master-deck.tsv) covering every generated interview card in the repo
- A [Universal Foundation deck](../downloads/anki/universal-foundation.tsv) covering Part 1 of the curriculum
- One deck per learning track:
  - [Track A](../downloads/anki/track-a-application-and-integration-builder.tsv)
  - [Track B](../downloads/anki/track-b-ai-systems-and-orchestration-engineer.tsv)
  - [Track C](../downloads/anki/track-c-ml-and-production-engineer.tsv)
  - [Track D](../downloads/anki/track-d-research-and-foundation-model.tsv)
  - [Track E](../downloads/anki/track-e-safety-ethics-and-governance.tsv)
- A generated catalog at [downloads/anki/README.md](../downloads/anki/README.md)

## Why TSV Instead Of `.apkg`

The repo now ships the safest portable format first:

- direct import into Anki
- no Python packaging dependency
- easy regeneration in CI
- easy inspection in GitHub before import

If the repo later adds a dedicated `.apkg` packager, these TSV files remain the source-of-truth export layer.

## Suggested Study Flow

1. Start with the track that matches your target role.
2. Review the cards after finishing each note instead of waiting until the end.
3. Use the [progress tracker](./progress-tracker.md) so card review stays aligned with the curriculum.
