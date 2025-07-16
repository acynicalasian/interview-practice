# interview-practice
Store practice code I wrote for interview prep.

## How to run
You might need to run `cabal install --lib stm` and similar for any other libraries GHC complains about. You'll also need to make sure you compile an object file for `FFIrandom.c` with `gcc -c FFIrandom.c`. Finally, make sure you're including the aforementioned object file when compiling or running with `GHCi`; `ghc foreign FFIrandom.o` and `ghci foreign.hs FFIrandom.o` (not sure if the `.hs` file extension is necessary here). I think it probably won't be necessary to run `ghcup tui` to update anything since I'm fairly positive most of these issues resolved themselves with the aforementioned `cabal` commands. Bleh.
