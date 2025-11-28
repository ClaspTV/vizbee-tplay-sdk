# VizbeeTPlayKit Developer Guide

This guide is for developers who are maintaining and publishing the `VizbeeTPlayKit` framework. For instructions on how to *use* the framework in an application, please refer to the README in the consumer-facing repository: [https://github.com/ClaspTV/vizbee-tplay-sdk](https://github.com/ClaspTV/vizbee-tplay-sdk).

## Overview

`VizbeeTPlayKit` is a wrapper framework built on top of the Vizbee Continuity SDK. This project contains the source code and build scripts necessary to produce the distributable `TPlaySDK.xcframework`.

This wrapper provides several key features tailored for aggregator apps like T-Play:

*   **Custom UI Components**: Includes customized device selection cards designed specifically for the T-Play application.
*   **Simplified Cast Button**: Offers a `VTPCastButton` that wraps the standard Vizbee cast button, simplifying its integration.
*   **Simplified Video API**: Provides a high-level API to start video playback.
*   **Multi-App Support**: Supports starting and stopping the underlying Vizbee SDK, allowing it to coexist with other Vizbee-enabled apps within an aggregator application.

## Building the Framework

The framework is built and archived using a shell script.

To build a new version of the framework, run the following command from the project root:

```bash
./build-xcframework.sh
```

Upon successful execution, the script will archive the framework and place the output `TPlaySDK.xcframework` into a `dist` folder located one level above the project directory (`../dist`).

## Publishing a New Version

Publishing a new version of the framework is a manual process. Follow these steps carefully:

1.  **Build the Framework**: Run the `./build-xcframework.sh` script as described above.

2.  **Locate the Artifact**: Navigate to the `dist` directory (one level up from this project's root) and verify that the new `TPlaySDK.xcframework` has been created.

3.  **Clone the Distribution Repository**: If you haven't already, clone the `vizbee-tplay-sdk` repository to your local machine:
    ```bash
    git clone https://github.com/ClaspTV/vizbee-tplay-sdk.git
    ```

4.  **Copy the Framework**: Manually copy the `TPlaySDK.xcframework` from the `dist` folder into the root of your local `vizbee-tplay-sdk` repository clone, replacing the existing framework.

5.  **Commit and Push**: In the `vizbee-tplay-sdk` repository, commit the new framework and push the changes:
    ```bash
    # Navigate into the repository directory
    cd vizbee-tplay-sdk

    # Add, commit, and push the new framework
    git add .
    git commit -m "feat: Update framework to version X.Y.Z" # Use a descriptive commit message
    git push
    ```

6.  **Tag the Release**: Create a new tag that matches the version number and push it to the repository. This is crucial for Swift Package Manager to pick up the new version.
    ```bash
    git tag vX.Y.Z # e.g., v1.0.1
    git push origin vX.Y.Z
    ```

Once these steps are complete, the new version of the framework will be available for consumption.
