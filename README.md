# Lyre

Download lyrics from MusixMatch and save them to a `.lrc` file.

## Installation

Go to the [releases page](https://github.com/Lexedia/lyre/releases) and download the latest release for your platform.

## Usage

```bash
lyre -a <artist> -s <song>
```

## Example

```bash
lyre -a "The Beatles" -s "Hey Jude"
```

A directory called `lyrics` will be created in the current working directory, and the lyrics will be saved to `lyrics/The Beatles/Hey Jude.lrc`.

## Romanization
To romanize the lyrics, you can use the `-m/--mode` option:

```bash
lyre -a Ado -s Value -m romanize
```
