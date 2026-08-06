name: 🐛 Bug Report
description: Create a bug report to help improve PetSewa platform
title: '[BUG] '
labels: ['bug']
body:
  - type: markdown
    attributes:
      value: |
        Thank you for reporting a bug in the PetSewa Platform!
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: Clear and concise description of what the bug is.
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior.
      placeholder: |
        1. Go to '...'
        2. Click on '....'
        3. Scroll down to '....'
        4. See error
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: Clear description of what you expected to happen.
    validations:
      required: true
  - type: dropdown
    id: module
    attributes:
      label: Affected Component
      options:
        - NestJS Backend Engine
        - Flutter Mobile App (Customer)
        - Flutter Mobile App (Vendor)
        - Database / TypeORM
        - CI/CD Pipeline
    validations:
      required: true
