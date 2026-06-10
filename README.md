# o-channel

Personal Guix channel for my own packages.

## Package naming convention

Every package in this channel must be prefixed with `omiya-`.

## Adding the channel

Add the following to `~/.config/guix/channels.scm`:

```scheme
(channel
  (name 'o-channel)
  (url "https://github.com/ottojung/o-channel.git")
  (branch "main"))
```

## Testing locally

```sh
guix build -L . omiya-hello
guix search -L . omiya-hello
```

## Authentication

Channel authentication is intentionally not configured yet.
