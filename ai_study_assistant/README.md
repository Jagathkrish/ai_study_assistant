# Offline AI Study Assistant 🧠📱

[cite_start]A Keras + Flutter mobile application that leverages on-device machine learning to provide tutoring, summarization, and quiz generation without requiring an internet connection[cite: 1, 4]. 

[cite_start]The core of this system is a Small Language Model (SLM) optimized via quantization and deployed directly on mobile devices using TensorFlow Lite[cite: 5]. [cite_start]This project demonstrates the feasibility of privacy-first, offline-first educational AI tools[cite: 6].

## ✨ Features

* [cite_start]**Smart Summarizer:** Pasted lecture notes or typed text are condensed into structured bullet points[cite: 49, 50, 52].
* [cite_start]**Quiz Generator:** Generates multiple-choice practice questions and answers based on user-provided study material[cite: 53, 54, 55].
* [cite_start]**Explain Like I'm 5:** Breaks down complex concepts into child-friendly explanations using analogies and simple language[cite: 57, 59, 60, 104].
* [cite_start]**Voice Interaction:** Includes Speech-to-Text for hands-free queries and Text-to-Speech for auditory learning[cite: 62, 63, 64].
* [cite_start]**100% Offline:** All inference happens via background isolates on the device, ensuring data privacy and zero network dependency[cite: 20, 28].

## 🛠️ Tech Stack

**Machine Learning Pipeline:**
* [cite_start]TensorFlow / Keras [cite: 68]
* [cite_start]Hugging Face Transformers [cite: 68]
* [cite_start]TensorFlow Lite Converter (INT8/FP16 Quantization) [cite: 39, 68]

**Mobile Application:**
* [cite_start]Flutter & Dart [cite: 69]
* [cite_start]`tflite_flutter` (Inference Engine) [cite: 42]
* [cite_start]Hive / SQLite (Offline Storage) [cite: 47]

## 🚀 Getting Started

*(Instructions for cloning, setting up the Python environment, and running the Flutter app will be added here as development progresses.)*

## 🧑‍💻 Author
**Jagath Krishna**