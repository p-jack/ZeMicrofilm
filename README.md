# Ze Microfilm

Ze Microfilm is a WIP password manager for iOS that notably does not connect 
to the Internet.

## Cryptography

The app only uses the cryptographic operations provided by the platform (via CloudKit.)
It uses ChaChaPoly to encrypt the password records at rest. It uses HKDF to derive a 
cryptographic key from the master password text, and again uses HKDF to derive per-record
keys from the master key.

Since ChaChaPoly operates in counter mode (CTR), encryption requires a nonce, but 
ChaChaPoly uses a 96-bit nonce. That makes collisions non-negligible if the nonces are
randomly generated. Instead, I randomly generate a 256-bit uuid for each password record.
I use that UUID as the "info" input to HKDF to derive a record-specific key from the
master key.

## Roadmap

Although the app is usable in its current form, it needs some love:

1. I'm working with a designer to add some images. Right now I don't even have an app icon.
2. I'm going to add the ability to bundle the vault into an archived file for transfer to
   other devices.
3. I'm also going to integrate with the AuthenticationServices framework so you can directly
   access the passwords from Safari and other apps.

