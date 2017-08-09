# NervesAPS

NervesAPS is an Elixir-based OpenAPS loop. It is in early stages of development using https://github.com/tmecklem/pummpcomm for pump communication/decoding and https://github.com/tmecklem/twilight_informant for Nightscout integration.

## Why does this project exist?

NervesAPS is a project to help people with Type 1 Diabetes "close the loop". A closed loop is a system that monitors blood sugar, insulin delivery, and other factors, predicts future blood glucose and insulin levels, and controls the flow of insulin without manual intervention.

## Project Goals

* Build a system to communicate with an insulin pump and continuous glucose monitor in order to monitor, predict and control
* Implement monitor and control layers
* Integrate the OpenAPS prediction algorithm (oref0) to determine basal adjustments needed
* Enable people with T1D to avoid having to learn linux system administration (cron jobs, log rotation, permissions, dependency installation, etc) in order to learn and start using a close loop system
* A power-on to functioning loop in less than 15 seconds
* Tolerance to real world conditions like sudden power loss and flaky wireless communications without corrupting the system

## How can I get involved?

NervesAPS is still very early in development. Your help is needed to push it from a CGM monitoring only solution to a fully closed loop. Join the [Type 1 Diabetes + Elixir Discord server](https://discord.gg/XfJ78mA) and learn more about how to get involved.
