# Card-Caster-MVP

## 1-liner: Card Caster is a collaborative web app for creating, sharing, and playing custom card-based games. 

## Instructions: 
- Are there detailed setup and installation instructions, ensuring a new developer can get the project running locally without external help?
  
## Configuration: 
- Are configuration instructions provided, such as environment variables or configuration files that need to be set up?
  
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

## Questions or Ideas?
Open an issue to discuss bugs, improvements, or new features before starting large changes.
 
## ERD: Does the documentation include an entity relationship diagram?
 
## Troubleshooting: Is there an FAQs or Troubleshooting section that addresses common issues, questions, or obstacles users or new contributors might face?

## Visual Aids:
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

## API Documentation (for projects providing their own API endpoints): 
Is there clear and detailed documentation for the project's API? This should include descriptions of all endpoints, request/response formats, and authentication methods.

All files are covered by the MIT license, see [LICENSE.txt](LICENSE.txt).
