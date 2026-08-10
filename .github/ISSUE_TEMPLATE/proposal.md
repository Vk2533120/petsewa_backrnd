name: 💡 Feature / Architecture Proposal
description: Submit a new feature, improvement, or architectural proposal for PetSewa
title: '[PROPOSAL] '
labels: ['proposal', 'needs-review']
body:
  - type: markdown
    attributes:
      value: |
        Thank you for submitting a Proposal for **PetSewa India**!
        Proposals can be submitted by any team member and will be triaged and reviewed by the **Petsewa Core** team.
  - type: textarea
    id: summary
    attributes:
      label: Proposal Summary
      description: Provide a clear, high-level summary of what you are proposing.
      placeholder: Describe the feature or improvement in 2-3 sentences.
    validations:
      required: true
  - type: textarea
    id: motivation
    attributes:
      label: Motivation & Problem Statement
      description: Why is this change necessary? What problem does it solve for pet parents, doctors, or administrators?
    validations:
      required: true
  - type: dropdown
    id: component
    attributes:
      label: Affected Component(s)
      multiple: true
      options:
        - Flutter Mobile App (Frontend)
        - NestJS API Engine (Backend)
        - Database / PostgreSQL (Data Layer)
        - DevOps / CI/CD Workflows
        - Documentation / Architecture
    validations:
      required: true
  - type: textarea
    id: technical_design
    attributes:
      label: Proposed Technical Implementation
      description: Detail how this should be implemented (endpoints, database schema, state management, etc.).
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      description: Were there other ways you considered solving this? Why is this proposal better?
  - type: checkboxes
    id: checklist
    attributes:
      label: Submission Checklist
      options:
        - label: I have verified this proposal does not duplicate an existing issue or discussion.
          required: true
        - label: I am ready to collaborate with Petsewa Core reviewers on refinement.
          required: true
