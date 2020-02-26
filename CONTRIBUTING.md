Contributing to the LaunchDarkly Client-Side SDK for React Native
================================================

LaunchDarkly has published an [SDK contributor's guide](https://docs.launchdarkly.com/sdk/concepts/contributors-guide) that provides a detailed explanation of how our SDKs work. See below for additional information on how to contribute to this SDK.

Submitting bug reports and feature requests
------------------

The LaunchDarkly SDK team monitors the [issue tracker](https://github.com/launchdarkly/react-native-client-sdk/issues) in the SDK repository. Bug reports and feature requests specific to this SDK should be filed in this issue tracker. The SDK team will respond to all newly filed issues within two business days.

Submitting pull requests
------------------

We encourage pull requests and other contributions from the community. Before submitting pull requests, ensure that all temporary or unintended code is removed. Don't worry about adding reviewers to the pull request; the LaunchDarkly SDK team will add themselves. The SDK team will acknowledge all pull requests within two business days.

Build instructions
------------------

### Prerequisites

This SDK requires that you have [`npm`](https://www.npmjs.com/) and [`react-native-cli`](https://www.npmjs.com/package/react-native-cli) installed in order to develop with it.

### Building and running

You can modify and verify changes by developing within the LaunchDarkly React Native SDK sample application (`hello-react-native`).

1. Clone and setup the [`hello-react-native`](https://github.com/launchdarkly/hello-react-native) repository.
2. In your `hello-react-native` directory, copy your `react-native-client-sdk` directory into `node_modules` as `launchdarkly-react-native-client-sdk`. Alternatively, you can use [wml](https://github.com/wix/wml) to monitor and copy files.
3. Launch your emulator (`emulator -avd <NAME>` for Android) or connect your device.
4. Test your changes in `hello-react-native` by running either `react-native run-ios` or `react-native run-android` depending on your desired runtime environment.
