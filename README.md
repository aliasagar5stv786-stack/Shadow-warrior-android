# Shadow Warrior: Rise of the Ninja — Full 31-Level Project (Enhanced Prototype)

## Included
- 31 level definitions: Chapters 1–3 have 10 levels each; Chapter 4 is the final boss.
- A Godot 4 project with touch buttons, basic combat and powers, a simple animated ninja/enemy drawing, a boss encounter, and synthesized sound effects plus a short original looping background music cue.
- Android export preset and GitHub Actions workflow for attempting a cloud APK build.

## Important limitations
This is a playable prototype/framework, not a polished commercial-quality game. The level list and chapter structure are present, but the 31 stages do not yet each have unique hand-built layouts and fully tuned gameplay. Persistent save/progress, true 90-star chapter unlock logic, complete coin/star pickup logic, robust enemy AI, richer animations, and final music/sound mixing still need development. The APK has not been compiled or tested in this environment.

## Build from a phone
1. Extract the ZIP on your Android phone.
2. In Chrome, create a repository at https://github.com/ .
3. Upload all project files and folders, including the hidden `.github/workflows/build-apk.yml`.
4. Open the repository's Actions tab and run the `Build Android APK` workflow.
5. If the workflow succeeds, download `shadow-warrior-debug-apk` from its Artifacts.
6. Download the APK on your phone, open it, allow installation from that source if Android asks, then install.

The cloud build may require troubleshooting if the runner lacks a matching Godot Android export template or SDK. Do not treat a successful upload as proof the APK built; check that the workflow run is green and the APK artifact exists.
