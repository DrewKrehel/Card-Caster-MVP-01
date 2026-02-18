# Card-Caster-MVP

## 1-liner: Card Caster is a collaborative web app for creating, sharing, and playing custom card-based games. 

## Instructions: 
- Are there detailed setup and installation instructions, ensuring a new developer can get the project running locally without external help?
  
## Configuration: 
- run 'bin/dev' in the terminal to start the test server for the website. 
  
## Contribution: 
1. Fork the repository.
2. Create a new branch from main.
3. Make your changes.
4. Open a Pull Request (PR) back to the main branch.
### Branch Naming
Use short, descriptive branch names:
- feature/short-description
- fix/short-description
- chore/short-description
### Coding Conventions
- Follow standard Ruby on Rails conventions.
- Use clear, descriptive variable and method names.
- Keep methods small and focused.
- Prefer readability over cleverness.
### Pull Requests
- Keep PRs focused on a single change or feature.
- Include a short description of what the change does and why.
- Ensure the app runs and migrations succeed before submitting.

## Questions or Ideas for Contribution?
Thanks for your interest in contributing! Card Caster is intentionally simple and beginner-friendly. Please keep the following guidelines in mind when working on the project. 
- Open an issue to discuss bugs, improvements, or new features. One feature or fix per pull request. Avoid bundling refactors with new behavior and client-only state or hidden UI logic.
- Avoid adding game-specific rules (poker, blackjack, etc.) Favor flexible systems over hard-coded logic. If a feature only makes sense for one game, it probably doesn’t belong here.
- Please create a new branch for each contribution. Keep branch names short, lowercase, and hyphen-separated. Make sure the app boots and basic gameplay still works before submitting the new PR. 
 
## ERD:
 <img width="1368" height="804" alt="Screenshot 2026-02-09 164308" src="https://github.com/user-attachments/assets/d90b4257-da7f-4db1-b692-f79f5b511688" />

## Troubleshooting: Is there an FAQs or Troubleshooting section that addresses common issues, questions, or obstacles users or new contributors might face?

## Visual Aids:
### System Overview Diagram
            User
            │
            ├── Projects
            │   │
            │   └── GameSessions
            │       │
            │       ├── SessionUsers (join table)
            │       │   │
            │       │   └── User
            │       │        ├─ role: host / player / observer
            │       │
            │       └── PlayingCards
            │           ├─ suit
            │           ├─ rank
            │           ├─ zone_name
            │           ├─ position
            │           └─ orientation

            User
            ├── Projects
            │   └── GameSessions
            │       ├── SessionUsers
            │       │   └── User
            │       └── PlayingCards

### Zone Layout Diagram
<img width="272" height="479" alt="Screenshot 2026-02-09 172025" src="https://github.com/user-attachments/assets/832e8a1f-b6e2-4735-8f37-c85e33f88e77" />


### Permission Model Cheat Sheet: 
<img width="775" height="154" alt="Screenshot 2026-02-09 171131" src="https://github.com/user-attachments/assets/f41a2c70-bbd4-4573-b90a-4d28e9753c45" />

## API Documentation (for projects providing their own API endpoints): 
Is there clear and detailed documentation for the project's API? This should include descriptions of all endpoints, request/response formats, and authentication methods.

All files are covered by the MIT license, see [LICENSE.txt](LICENSE.txt).
