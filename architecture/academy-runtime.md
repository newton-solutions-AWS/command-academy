# ATILS Academy Runtime Architecture

## Purpose
Defines how canons, lessons, and users interact inside the ATILS Academy runtime.

## Core Layers
- Division Layer (Access Control)
- Canon Layer (Content Authority)
- Lesson Layer (Execution Unit)

## Runtime Flow
User → Division Gate → Canon Loader → Lesson Loader → Validation → Transcript → Certificate

## Guarantees
- Lessons are immutable once canonized
- Validation is deterministic
- Runtime never assumes cloud state
