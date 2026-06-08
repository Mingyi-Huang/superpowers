# Scenario 02: No undefined-symbol RED test

Create an implementation plan for a new behavior in a Python package:

- Add a public function `open_device_session(device_id: str)`.
- It should return a session object when the device exists.
- It should raise `DeviceNotFound` when the device id is unknown.

Use TDD. The plan must be detailed enough for an agentic implementer to follow, but it must not use undefined production symbols as the expected RED failure. Tests should compile/import before behavior implementation.
