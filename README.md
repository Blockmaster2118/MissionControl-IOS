# MissionControl iOS

MissionControl is an iOS application designed to help remote pilots manage small commercial drone operations.

The application brings mission planning, aircraft management, pre-flight inspections, defect information and flight history into a single mobile workflow. It also uses iOS system extensions to provide quick access to mission information and allow information from other applications to be brought into MissionControl.

## Project Overview

A small commercial drone operation can require a pilot to manage several related pieces of information, including:

- Aircraft and their serviceability
- Scheduled missions
- Pre-flight inspections
- Defects and maintenance information
- Previous flight records

MissionControl combines these tasks into one application so that the pilot can access the information needed to prepare for and conduct a flight without relying on separate notes, spreadsheets or other applications.

The application is designed primarily for use at or near the operating site, where quick access to operational information is important.

## Domain Context

MissionControl is designed around the workflow of a remote pilot conducting a small commercial drone operation.

A typical workflow is:

1. Select or manage the aircraft being used.
2. Create and schedule a mission.
3. Review the aircraft and mission information.
4. Complete the required pre-flight inspection.
5. Conduct the flight.
6. Record the outcome and retain the flight history.

The application links these activities through the mission and aircraft rather than treating each task as separate administrative information.

This also supports the record-keeping requirements associated with commercial drone operations.

## Architecture

MissionControl uses a SwiftUI-based architecture with local SwiftData persistence.

The main application is responsible for the complete user interface and operational workflow. Data is separated into aircraft, mission and flight stores, with a central `DataStore` coordinating the application's persistent state.

```text
┌─────────────────────────────┐
│       MissionControl        │
│          SwiftUI            │
├─────────────────────────────┤
│ Mission Management          │
│ Aircraft Management         │
│ Pre-flight Checks           │
│ Defect Information          │
│ Flight History              │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          DataStore          │
├─────────────────────────────┤
│ Aircraft Store              │
│ Mission Store               │
│ Flight Store                │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          SwiftData          │
│      Local Persistence      │
└─────────────────────────────┘

        App Group Container
               │
       ┌───────┴────────┐
       ▼                ▼
┌─────────────┐  ┌────────────────┐
│   Widget    │  │ Share Extension│
│  Extension  │  │                │
└─────────────┘  └────────────────┘
```

The application uses local persistence rather than relying on a network service. This allows operational information to remain available on the device between application launches and without requiring a constant network connection.

## iOS Extensions

MissionControl implements two iOS system extensions:

### Widget Extension

The WidgetKit extension provides quick access to the pilot's next scheduled mission directly from the Home Screen.

The widget can display information including:

- Next scheduled mission
- Mission time
- Assigned aircraft
- Pre-flight progress
- Inspection completion status

The widget was chosen because this information is useful at a glance. A pilot preparing for a flight can check the next mission and its readiness without opening the complete application.

### Share Extension

The Share Extension allows information from other applications to be sent directly into MissionControl.

A pilot may receive useful mission information through another application, such as a message, document or website. Without the extension, this information would need to be copied manually into MissionControl.

The Share Extension instead represents shared information as a SharedBrief and writes it into the App Group inbox as a JSON file.

When the main application becomes active, it reloads the shared briefs and allows the information to be incorporated into the appropriate mission.

This reduces manual transcription and allows external information to enter the existing MissionControl workflow.

## Persistence
MissionControl uses SwiftData for local persistent storage.

SwiftData was chosen because the application manages structured information such as aircraft, missions and flight records. It provides persistent storage while integrating directly with Swift and SwiftUI.

The project separates its persistence responsibilities into:

- Aircraft data
- Mission data
- Flight data

A central DataStore coordinates these stores and provides the resulting application state to the SwiftUI views.

### Why Local Persistence?

The application's core information belongs primarily to the individual operator and device. Missions, aircraft, inspections and flight records need to remain available between application launches and should not depend on a constant network connection.

CloudKit was not used because synchronisation between multiple devices or multiple users is outside the scope of the current application.

## App Group

The main application and its extensions use an App Group to share information.

The App Group provides a shared container that allows the main application, Widget Extension and Share Extension to exchange the information required for their respective workflows.

The Share Extension uses the shared container to place incoming SharedBrief information into the application's inbox as JSON. The main application can then read this information when it becomes active.

## Project Structure

```text
MissionControl-IOS/
├── MissionControl/              # Main iOS application
├── MissionControlWidget/        # WidgetKit extension
├── MissionControlShare/         # Share Extension
├── MissionControlTests/         # Unit tests
├── MissionControlUITests/       # UI tests
└── MissionControl.xcodeproj     # Xcode project
```

## Requirements

- macOS
- Xcode
- iOS Simulator or compatible iOS device

