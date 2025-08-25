# smart_trip_planner

Smart trip planner for future.


## Architecture
```mermaid
flowchart TD
    U[User Prompt\n+ Itinerary + Chat History] --> LLM[LLM Receives Context & Functions]

    LLM -->|Needs Info?| F[Function Calls\n(weather, attractions, etc.)]
    F --> D[External Data Sources]
    D --> F --> LLM

    LLM --> J[Generate Updated Itinerary JSON]
    J --> V[Validation & Conversion to Trip Model]
    V --> U[Final Itinerary Returned to User]


    U --> A
    A --> L
    L --> A
    A --> Tools
    Tools --> V
    V --> A
    A --> U





## ⚙️ Setup Guide

### Backend Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yamiamit/smart_trip_planner_flutter
   flutter pub get
   flutter run
   ```
2. Create .env file in the root directory with these variables:

   ```bash
   GEMINI_API_KEY : 
   //provide your gemini api key
   
   ```
3. Register your app on firebase console to obtain google-services.json file
   ```bash
   put the obtained .json file /android/app directory

NOTE: You need to provide SHA1 key to enable google sign in so please refer documentary or net for that

## 📜 License

