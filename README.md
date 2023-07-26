<!--

This source file is a derivative of the Stanford HealthGPT project

Original SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see ORIGINAL_CONTRIBUTORS.md)

Original SPDX-License-Identifier: MIT
Modified by [Your Name or Organization]

-->

# WellnessGuide

WellnessGuide is a personal health iOS app that integrates with HealthKit data, utilizing AI to promote a healthier lifestyle. By analyzing the health data you allow the app to access, WellnessGuide provides insights tailored to you. The more data points provided, the richer the insights. 

For developers and early adopters, please note that you must use your own OpenAI key for now. In the future, this requirement will be abstracted away.

## Features

- Personalized insights based on your HealthKit data.
- AI-powered analysis using OpenAI's GPT models.
- Completely optional data points; use as many or as few as you like.
- User-friendly interface for a seamless health data interaction.
- Built on the foundation of HealthGPT, extending its capabilities to a more personalized level.

## Disclaimer

WellnessGuide is designed for general informational purposes. It is not a replacement for professional medical guidance, diagnosis, or therapy. While AI models, like those from OpenAI, provide valuable insights, they can sometimes generate incorrect information. Use WellnessGuide at your own risk. Always seek advice from a licensed healthcare provider about any health concerns. Aggregated HealthKit data for the past 14 days will be uploaded to OpenAI. Refer to the [OpenAI privacy policy](https://openai.com/policies/privacy-policy) for details.

## Set Up

1. Clone this repository.
2. Open `WellnessGuide.xcodeproj` in Xcode. Ensure all dependencies are installed and indexing is completed.
3. Insert your OpenAI API key in `Supporting Files/OpenAI-Info.plist`. Alternatively, input your key directly within the app during the setup process.
4. Launch the app, either on your device or in the simulator, and explore WellnessGuide with your health data 🚀

If using the simulator, remember to manually input data in the Health app, otherwise your results will display as zero.

## Contributing

If you're interested in contributing, kindly check the [contribution guidelines](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md). The list of original contributors can be found in [`ORIGINAL_CONTRIBUTORS.md`](ORIGINAL_CONTRIBUTORS.md).

## License

This project remains under the MIT License. For more details, view the [Licenses](LICENSES) file.

