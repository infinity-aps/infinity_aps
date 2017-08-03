# NervesAPS

NervesAPS is an Elixir-based OpenAPS loop. It is in early stages of development using https://github.com/tmecklem/pummpcomm for pump communication/decoding and https://github.com/tmecklem/twilight_informant for Nightscout integration.

Currently supported features:
* CGM loop with Nightscout reporting
* Date/Time set from NTP, fallback to pump date/time
