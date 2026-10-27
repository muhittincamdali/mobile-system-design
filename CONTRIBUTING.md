# Contributing

Thanks for taking the time to improve Mobile System Design. The repository has two parts that
change together: the guide in `docs/` and the Swift package in `Sources/`.

## Reporting a problem

Open an issue with:

- for the guide: the page and the paragraph, what is wrong or unclear, and a source (an RFC,
  Apple or Android documentation) when the point is factual;
- for the package: the type and the call, what you expected and what happened, and the
  platform, OS version and Xcode version.

## Changing the guide

- Keep each page focused on design questions and trade-offs. Where code helps, link to the
  package type instead of pasting a long listing.
- State numbers with the assumptions they come from ("at 160 kbit/s, a 3.5-minute track is
  about 4.2 MB"). Do not quote scale figures of real companies without a public source.
- Link to the primary source: the RFC, or the Apple or Android documentation page.
- A new case study follows the steps of [the framework](docs/framework.md): requirements,
  estimates, high-level design, API and data, deep dives, trade-offs and metrics. Add it to
  [docs/README.md](docs/README.md).

## Changing the package

1. Fork the repository and branch from `main`. Keep each pull request to one change.
2. Every public type needs tests in `Tests/MobileSystemDesignTests`, including the edge cases
   its inputs can produce: negative values, NaN and infinity, `Int.max`, empty and malformed
   text, concurrent calls. Inject time (a clock, a `now` parameter or a sleep function) so the
   tests never sleep.
3. Values that can come from outside the app — remote configuration, HTTP headers, files,
   other devices — must be clamped or rejected, never trap. Collections that grow with input
   need a limit.
4. The package has no dependencies and builds in the Swift 6 language mode without warnings.
   Document public API with DocC comments (`///`); the catalog builds with
   `--warnings-as-errors`.
5. Run the checks:

    ```sh
    swift test
    xcodebuild test -scheme MobileSystemDesign \
      -destination 'platform=iOS Simulator,name=iPhone 17'
    xcodebuild docbuild -scheme MobileSystemDesign -destination 'generic/platform=macOS' \
      OTHER_DOCC_FLAGS=--warnings-as-errors
    node scripts/check-readme-samples.mjs
    ```

6. If you change a README code sample, change the copy in
   `Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift` as well. That file is
   compiled by the example app and, through the symlink
   `Tests/MobileSystemDesignTests/ReadmeExamples.swift`, compiled and run by `swift test`.
   Build the app with:

    ```sh
    cd Examples/SystemDesignLab
    xcodebuild build -scheme SystemDesignLab -destination 'generic/platform=iOS Simulator'
    ```

7. If a change affects a lab's screen, regenerate the screenshots with
   `scripts/capture-screenshots.sh`.
8. `README.md` is translated into other languages (`README.<language>.md`). If you change
   `README.md` and cannot update the translations, say so in the pull request.

## Style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## License

By contributing you agree that your contributions are licensed under the MIT License.
