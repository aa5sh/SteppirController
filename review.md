# Code Review Report

Reviewed: 2026-09-29

## Scope and approach

This was a static review of the Xojo project, with emphasis on the SteppIR and FlexRadio communication paths, command construction, settings, and preference persistence. The repository does not contain an automated test suite, and a Xojo command-line build tool is not available in this environment, so the findings below were not validated against physical controllers or a compiled application.

## Executive summary

The application is small and its core intent is easy to follow, but the communication code assumes that each socket read aligns with a protocol message. TCP and serial streams do not guarantee that alignment. This creates the most important reliability problems in the project. There is also an inconsistent internal value for the 3/4 direction, and connection teardown handles TCP but not serial. These issues can lead to stale status, repeated commands, direction changes being lost, and serial reconnection failures.

Recommended order of work:

1. Replace the current receive buffering with a loop that extracts and validates every complete frame.
2. Use one representation for direction and one shared command builder.
3. Centralize connection start/stop/write behavior and handle both TCP and serial states.
4. Add input and preference validation.
5. Add protocol-level automated tests using captured byte streams.

## Findings

### High: receive processing can leave complete SteppIR responses stuck in the buffer

Locations: `formMainWindow.xojo_window:1478-1520`, `formMainWindow.xojo_window:2001-2008`, and `formMainWindow.xojo_window:2059-2066`.

`myProcessingMethodSteppir` finds only the first carriage-return-terminated message and processes it once. If a single read contains two or more complete messages, the remaining complete message stays in `SteppirBuffer`. Processing is only scheduled from a later `DataAvailable`/`DataReceived` event, which may never occur. Status can therefore lag behind the controller even though the data has already arrived.

The implementation also stores every byte as a separate `String` array element and repeatedly removes index zero. This creates unnecessary allocations and increasingly expensive array shifting.

Recommendation: keep one binary/string receive buffer, append each `ReadAll`, and loop while a CR terminator exists. Remove one frame at a time, validate it, process it, and continue until only an incomplete tail remains. Put the processing guard cleanup in an exception-safe path or eliminate the guard by keeping all framing on the main event loop.

### High: the 3/4 direction has incompatible internal names and can trigger repeated commands

Locations: `formMainWindow.xojo_window:1539-1550`, `formMainWindow.xojo_window:1581-1589`, `formMainWindow.xojo_window:1605-1613`, `formMainWindow.xojo_window:1691-1699`, and `formMainWindow.xojo_window:2024-2037`.

Decoded controller state assigns `Direction = "3/4"`, while button handling, command encoding, and color updates use `"34"`. After the 3/4 button sets `NewDir` to `"34"`, a response changes `Direction` to `"3/4"`. The timer then continues to see the values as different and attempts another direction command every 1.5 seconds. The 3/4 button also will not receive its active color because `UpdateColors` tests for `"34"`.

Recommendation: represent direction with an enum (Normal, Reverse180, Bidirectional, ThreeQuarter) rather than display strings. Convert to protocol bits and UI captions only at the boundaries. At minimum, change all comparisons and assignments to one canonical string.

### High: Auto, Manual, and Home commands silently discard the 3/4 direction

Locations: `formMainWindow.xojo_window:1909-1916`, `formMainWindow.xojo_window:1943-1952`, and `formMainWindow.xojo_window:1971-1980`.

These three command builders handle BID and 180 but not the 3/4 mode. When the current direction is 3/4, they encode `00`, which is the Normal direction. This can unexpectedly change antenna direction when the user changes tracking mode or homes the controller.

Recommendation: create a single direction-to-byte function and use it in every command builder. A shared `BuildCommand(frequency, direction, operation)` routine would prevent the currently duplicated cases from drifting apart.

### High: serial connections are not shut down during reconfiguration or window close

Locations: `formMainWindow.xojo_window:1432-1437`, `formMainWindow.xojo_window:1625-1630`, `formMainWindow.xojo_window:1634-1655`, and `formSettings.xojo_window:575-589`.

`Shutdown` disconnects only `SteppirSocket1`. Saving settings calls `Shutdown` and then `StartUP`, so an existing serial connection remains open before another serial connection is attempted. Switching from serial to network also leaves the serial device open. Closing the main window disconnects only FlexRadio, not the SteppIR TCP/serial connections or its timer/callbacks.

Recommendation: make `Shutdown` stop `SteppirStatusUpdated`, cancel the delayed processing callback, disconnect/close TCP, disconnect/close serial, and clear receive state. Call it from `Closing` and before every reconfiguration. Make `StartUP` idempotent so calling it twice cannot create overlapping connection attempts.

### Medium: FlexRadio parsing is not stream-safe

Location: `formMainWindow.xojo_window:2075-2086`.

The FlexRadio handler parses each `ReadAll` as though it contains a complete, single status record. TCP may split `RF_frequency=` or its value across reads, or combine several records in one read. The test `IndexOf("RF_frequency=") > 0` also ignores a valid token at position zero. If the following space has not arrived, `EndSt` is `-1` and the substring calculation is invalid or produces incorrect data.

Recommendation: retain an incoming FlexRadio buffer and split it using the protocol's line delimiter. Process all complete lines and retain the incomplete tail. Use `>= 0`, check that the value terminator exists, and use `Try`/validation for numeric conversion. If several slices are reported, explicitly select the intended slice rather than accepting whichever matching update happens to be read.

### Medium: outbound commands and settings accept invalid state without validation

Locations: `formMainWindow.xojo_window:1572-1620`, `formMainWindow.xojo_window:1994-1996`, `formMainWindow.xojo_window:2017-2038`, and `formSettings.xojo_window:575-587`.

The Go field is converted directly with `ToDouble`, with no range or conversion handling. Network ports and baud rates are converted with `Val`, where invalid text becomes zero. Serial writes occur on every timer tick without checking that the connection and device are valid. Other command methods also write without a connected-state check. Invalid input or a disconnected device can therefore produce malformed antenna commands or runtime I/O errors.

Recommendation: validate frequency against the controller-supported range, reject blank/non-numeric values, require a port in `1...65535`, require a supported baud rate, and ensure a serial device is selected. Route all writes through one method that checks connection state, catches/logs I/O errors, and returns success to the UI. Disable command controls until a connection is ready.

### Medium: malformed or partial SteppIR frames are treated as valid responses

Location: `formMainWindow.xojo_window:1525-1567`.

`ProcessResponseSteppir` reads fixed offsets without checking frame length, header bytes, terminator, or numeric fields. Any CR-terminated noise or truncated response can set frequency to zero, change direction/status, or cause a conversion/runtime error. If an exception escapes `myProcessingMethodSteppir`, its static `processingData` flag remains true and all future responses are ignored.

Recommendation: validate the decoded frame length and expected response header before reading fields. Reject and log malformed frames without changing UI state. Ensure the processing flag is reset even on exceptions; preferably, use a framing loop that does not need a static reentrancy flag.

### Medium: opening Settings starts the controller connection again

Location: `formSettings.xojo_window:518-550`.

The Settings `Opening` event calls `formMainWindow.StartUP` before the user saves anything. The main window already calls `StartUP` during its own opening. Merely opening Settings can therefore issue a second connect attempt and re-enable the timer, even if the user cancels.

Recommendation: remove this call. Only restart the connection after validated settings are successfully saved and only when connection-relevant values actually changed.

### Low: preference loading and saving are fragile

Locations: `App.xojo_code:10-31` and `ModernPreferences/Prefs.xojo_code:29-97`.

Defaults are installed only when the entire preference load fails. A valid older/partial JSON file can omit keys, leaving most values as `Nil`; only `FlexRadio` is repaired. `Load` handles invalid JSON but not folder/file access errors. `Save` does not explicitly close the output stream and overwrites the live file directly, so a crash during writing can corrupt the only copy.

Recommendation: apply a default for every missing key after every load, validate loaded types/ranges, catch filesystem exceptions, explicitly close streams, and save atomically through a temporary file followed by replacement. Consider preserving an invalid file for diagnosis instead of immediately overwriting it at application startup.

### Low: there is no automated coverage for protocol behavior

No test project or test files were found.

Recommendation: extract framing, response decoding, and command construction into classes/functions independent of UI controls. Add tests for:

- a response split over multiple reads;
- multiple responses in one read;
- leading noise and malformed/short frames;
- every direction's decode/encode round trip;
- Auto, Manual, and Home while in every direction;
- disconnected writes and reconnect transitions;
- fragmented and combined FlexRadio lines;
- missing, invalid, and older preference files.

Captured controller messages can be used as fixtures, allowing most behavior to be tested without hardware.

## Additional maintainability recommendations

- Replace magic protocol strings such as `"404100"`, `"55"`, and `"53000D"` with named constants and document the byte layout.
- Consolidate duplicated TCP/serial writes and command construction. This reduces the chance that fixes are applied to one button path but missed in another.
- Report socket and FlexRadio errors somewhere observable. The FlexRadio `Error` event currently discards the exception.
- Add a short developer section to `README.md` describing the required Xojo version, supported platforms, controller protocol assumptions, and how to build/test the project.

## Verification notes

- All tracked source and project metadata files were inspected.
- No application source files were changed as part of this review.
- A compile or runtime test was not performed because the Xojo build tool and controller hardware are not available in this environment.
- The pre-existing `.DS_Store` working-tree modification was left untouched.
