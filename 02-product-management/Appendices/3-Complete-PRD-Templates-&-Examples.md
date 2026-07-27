# Appendix 3: Complete PRD Templates & Examples

## Overview

This appendix provides comprehensive, ready-to-use templates for Product Requirements Documents (PRDs), user stories, and acceptance criteria. Each template is based on industry best practices and includes real examples from the Ledgerly case study.

**Purpose:** To provide a complete, copy-pasteable PRD template that you can adapt for any product or feature.

---

## Template 1: Complete PRD Template

### PRD Template Structure

```markdown
# [Product/Feature Name]: Product Requirements Document

**Version:** [Version Number]
**Date:** [Current Date]
**Status:** [Draft | In Review | Approved | Implemented]
**Author:** [Your Name]
**Reviewers:** [Engineering Lead, Design Lead, Product Lead]

---

## 1. Executive Summary

### Overview
[One-paragraph summary of what we're building and why]

### Key Outcomes
- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

### Business Impact
- [Impact on revenue, retention, etc.]

---

## 2. Problem Statement

### The Problem
[Concise description of the problem we're solving]

### Evidence
- [Data point 1]
- [Data point 2]
- [User quote 1]

### Why Now
[Why is this the right time to solve this problem?]

---

## 3. User Stories

### Epic 1: [Epic Name]

**Story 1: [Story Title]**
> As a [type of user],
> I want [some goal],
> So that [some reason].

**Story 2: [Story Title]**
> As a [type of user],
> I want [some goal],
> So that [some reason].

### Epic 2: [Epic Name]

[Continue with all epics and stories]

---

## 4. Success Metrics

### North Star Metric
[The one metric that matters most]

### Primary Metrics
- **Metric 1:** [Description], Target: [Target value]
- **Metric 2:** [Description], Target: [Target value]
- **Metric 3:** [Description], Target: [Target value]

### Secondary Metrics
- **Metric 4:** [Description], Target: [Target value]
- **Metric 5:** [Description], Target: [Target value]

### Counter-Metrics (What We Should NOT Hurt)
- **Metric A:** [Description], Threshold: [Maximum acceptable value]
- **Metric B:** [Description], Threshold: [Maximum acceptable value]

---

## 5. Detailed Requirements

### Feature 1: [Feature Name]

**Functional Requirements:**

1. **Requirement 1:**
   - [Description]
   - [Sub-details]
   - [Acceptance criteria]

2. **Requirement 2:**
   - [Description]
   - [Sub-details]
   - [Acceptance criteria]

**Non-Functional Requirements:**
- [Performance requirements]
- [Security requirements]
- [Accessibility requirements]

**Edge Cases:**
- [Edge case 1]
- [Edge case 2]

---

### Feature 2: [Feature Name]

[Continue with all features]

---

## 6. Technical Considerations

### Data Model
[ER Diagram or data model description]

### Technical Trade-offs
- **Trade-off 1:** [Description], Decision: [Decision made]
- **Trade-off 2:** [Description], Decision: [Decision made]

### Performance Requirements
- [Performance target 1]
- [Performance target 2]

### Security Requirements
- [Security requirement 1]
- [Security requirement 2]

---

## 7. Design Considerations

### Design Principles
1. **[Principle 1]:** [Description]
2. **[Principle 2]:** [Description]

### Key Screens
1. **[Screen 1]:** [Description]
2. **[Screen 2]:** [Description]

### Accessibility Requirements
- [WCAG requirements]
- [Screen reader compatibility]
- [Color contrast requirements]

---

## 8. Dependencies & Assumptions

### Dependencies
- **Technical:** [Dependency 1], [Dependency 2]
- **External:** [Dependency 3], [Dependency 4]
- **Stakeholder:** [Dependency 5]

### Assumptions
- [Assumption 1]
- [Assumption 2]
- [Assumption 3]

### Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk 1] | [Impact] | [Probability] | [Mitigation] |
| [Risk 2] | [Impact] | [Probability] | [Mitigation] |

---

## 9. Out of Scope

### Not in This Version
- [Feature not included 1]
- [Feature not included 2]
- [Feature not included 3]

### Future Versions
- [Future feature 1]
- [Future feature 2]

---

## 10. Appendix

### User Flows
[Include user flow diagrams]

### Wireframes
[Include wireframe images]

### Research References
- [Research source 1]
- [Research source 2]

### Change Log
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| [Version] | [Date] | [Name] | [Changes] |

---

## 11. Review Checklist

- [ ] Problem statement is grounded in research
- [ ] User stories are complete and testable
- [ ] Success metrics are measurable
- [ ] Requirements are specific and complete
- [ ] Technical constraints are identified
- [ ] Design guidelines are established
- [ ] Out of scope is clearly defined
- [ ] Dependencies and risks are addressed
- [ ] Stakeholders have reviewed and approved

---

## 12. Approval

| Role | Name | Approval Status | Date |
|------|------|-----------------|------|
| Product Lead | [Name] | [Approved / Changes Required / Not Yet Reviewed] | [Date] |
| Engineering Lead | [Name] | [Approved / Changes Required / Not Yet Reviewed] | [Date] |
| Design Lead | [Name] | [Approved / Changes Required / Not Yet Reviewed] | [Date] |
| Stakeholder | [Name] | [Approved / Changes Required / Not Yet Reviewed] | [Date] |
```

---

## Template 2: PRD for "Goal Setting" Feature (Filled Example)

Here's the complete filled example from the Ledgerly case study:

```markdown
# Goal Setting: Product Requirements Document

**Version:** 1.0
**Date:** [Current Date]
**Status:** Approved
**Author:** [Your Name]
**Reviewers:** Engineering Lead, Design Lead, Head of Product

---

## 1. Executive Summary

### Overview
Goal Setting is Ledgerly's flagship feature to drive user retention and engagement. Users who set financial goals are 3x more likely to remain active after 30 days (from our discovery research). This feature allows users to create, track, and achieve savings, spending, and debt reduction goals—turning Ledgerly from a passive spending tracker into an active tool for financial progress.

### Key Outcomes
- 50% of users set at least one goal within 30 days of onboarding
- Goal-setting users retain at 3x the rate of non-goal users
- Users report feeling more "in control" of their finances

### Business Impact
- Increase Day 30 retention from 20% to 40%
- Increase weekly active users from 10% to 30%
- Drive referrals through positive user experience (NPS target: 45+)

---

## 2. Problem Statement

### The Problem
Young professionals (25-40) who use Ledgerly want to improve their financial health, but they don't know where to start. They can see their spending history, but they have no guidance on what to do differently. Without a clear goal to work toward, they lose motivation and stop using the app within 30 days.

### Evidence
- Users who set goals (via external tools) are 3x more likely to retain
- 80% of users churn within 30 days
- User research quote: "I could see what I spent, but not what I could spend."
- User research quote: "I opened it and it said the same thing as yesterday."

### Why Now
The user retention issue is critical. We're losing 80% of users within 30 days. Goal Setting addresses the #1 reason users churn: lack of progress and motivation.

---

## 3. User Stories

### Epic 1: Create and Manage Goals

**Story 1: Create a Savings Goal**
> As a user who wants to save money,
> I want to create a savings goal with a target amount and deadline,
> So that I have a clear target to work toward.

**Story 2: Create a Spending Goal**
> As a user who wants to manage my spending,
> I want to create a spending goal for a specific category (e.g., dining out),
> So that I can stay within my budget.

**Story 3: Create a Debt Reduction Goal**
> As a user who has debt,
> I want to create a goal to pay off a specific debt,
> So that I can become debt-free.

**Story 4: Edit Goals**
> As a user who's tracking goals,
> I want to edit my goal amount, deadline, or category,
> So that my goals stay relevant as my situation changes.

**Story 5: Delete Goals**
> As a user who no longer needs a goal,
> I want to delete the goal from my dashboard,
> So that my dashboard stays clean and focused.

### Epic 2: Track Goal Progress

**Story 6: View Goal Progress**
> As a user with active goals,
> I want to see my progress toward each goal on my dashboard,
> So that I stay motivated and know if I'm on track.

**Story 7: See Goal Details**
> As a user who wants to understand my progress,
> I want to view detailed information about my goal (progress chart, projected completion date, amount remaining),
> So that I know exactly what to do next.

**Story 8: Get Progress Notifications**
> As a user who wants to stay on track,
> I want to receive notifications when I hit milestones or fall behind,
> So that I can take corrective action.

### Epic 3: Get Recommendations

**Story 9: Get Goal Suggestions**
> As a user who doesn't know what goal to set,
> I want to see suggested goals based on my spending patterns,
> So that I have a starting point.

**Story 10: Get Actionable Tips**
> As a user who wants to achieve my goals,
> I want to receive personalized tips on how to save more or spend less,
> So that I have a clear path forward.

---

## 4. Success Metrics

### North Star Metric
**Retention at 30 days:** Increase from 20% to 40%

### Primary Metrics
- **Goal-setting adoption:** 50% of users set at least one goal within 30 days
- **Goal completion rate:** 20% of goals completed within 3 months
- **User satisfaction:** 4.5+/5 rating from goal-setting users

### Secondary Metrics
- **Weekly active users:** Increase from 10% to 30%
- **Session depth:** Goal-setting users view 5+ screens per session
- **Referral rate:** Goal-setting users refer 2x more than non-goal users

### Counter-Metrics (What We Should NOT Hurt)
- **User churn:** Should not increase for non-goal-setting users
- **Performance:** App should not slow down with added features
- **Onboarding completion:** Should not decrease due to added complexity

---

## 5. Detailed Requirements

### Feature 1: Create Goal

**Functional Requirements:**

1. **Goal Types:**
   - Savings Goal: "Save $X by [date]"
   - Spending Goal: "Spend less than $X on [category] per month"
   - Debt Goal: "Pay off [account] by [date]"

2. **Goal Creation Flow:**
   - User clicks "Set a Goal" button on dashboard
   - User selects goal type (Savings, Spending, Debt)
   - User enters goal parameters:
     - **Savings:** Target amount, target date, optional note
     - **Spending:** Category, monthly limit
     - **Debt:** Account name, total balance, target date
   - User confirms and saves goal
   - Goal appears on dashboard with initial progress

3. **Validation Rules:**
   - Target amount must be > $0
   - Target date must be in the future
   - Goal name cannot be empty
   - Duplicate goals are allowed (user can have multiple goals)

4. **Error Handling:**
   - Display clear error messages for invalid inputs
   - Auto-save progress so users don't lose work
   - Allow users to save as draft (not activate yet)

**Acceptance Criteria:**
- [ ] User can access "Set a Goal" from dashboard
- [ ] User can select from 3 goal types
- [ ] User can enter and validate goal parameters
- [ ] User can save goal after validation
- [ ] Goal appears on dashboard within 5 seconds
- [ ] User receives confirmation message
- [ ] Error messages are clear and actionable

**Non-Functional Requirements:**
- Goal creation takes < 2 minutes for 90% of users
- Goal appears on dashboard within 5 seconds of saving
- Mobile-responsive: works seamlessly on mobile and desktop

**Edge Cases:**
- User enters 0 as target amount → Show error: "Please enter a valid amount"
- User enters past date → Show error: "Please select a future date"
- User cancels goal creation → No goal is saved
- User loses internet connection → Auto-save draft

---

### Feature 2: Track Goal Progress

**Functional Requirements:**

1. **Dashboard Widget:**
   - Display each goal with progress bar and percentage
   - Show "On Track" or "Behind" indicator
   - Clicking goal opens detail view

2. **Goal Detail View:**
   - Show progress chart (line chart over time)
   - Show target amount, current amount, and amount remaining
   - Show projected completion date
   - Show key milestones (e.g., "50% completed!")
   - Show transaction history related to the goal

3. **Progress Calculation:**
   - **Savings Goal:** Progress = (current savings) / (target amount)
   - **Spending Goal:** Progress = 1 - (monthly spending) / (monthly limit)
   - **Debt Goal:** Progress = (amount paid off) / (total debt)

4. **Milestones:**
   - Show notification at 25%, 50%, 75%, and 100% completion
   - Celebrate completion with confetti/celebration message

**Acceptance Criteria:**
- [ ] Each goal on dashboard shows progress bar and percentage
- [ ] "On Track" / "Behind" status is accurate based on time remaining
- [ ] Clicking goal opens detail view
- [ ] Progress updates automatically within 1 hour of new transactions
- [ ] Progress chart shows trend over time
- [ ] Milestones trigger at 25%, 50%, 75%, 100%

**Non-Functional Requirements:**
- Dashboard loads in < 2 seconds
- Charts are responsive and accessible
- Progress updates within 1 hour of new transactions

**Edge Cases:**
- User has no transactions → Progress shows 0%
- User exceeds target → Progress shows 100%+
- User sets goal but doesn't complete onboarding → Goal remains in "draft" state

---

### Feature 3: Edit and Delete Goals

**Functional Requirements:**

1. **Edit Goal:**
   - Allow users to modify target amount, target date, and description
   - Show current values as default
   - Validate inputs before saving
   - Show confirmation after successful update

2. **Delete Goal:**
   - Display confirmation dialog before deletion
   - Explain that this action cannot be undone
   - Remove goal from dashboard after deletion

3. **Archive Goals:**
   - Allow users to archive completed goals (instead of deleting)
   - Archived goals are visible in "Archived Goals" section
   - Users can unarchive goals if needed

**Acceptance Criteria:**
- [ ] Users can access Edit from goal detail view
- [ ] Current values are shown as default
- [ ] Validation checks are applied
- [ ] Confirmation is shown on successful update
- [ ] Delete requires confirmation before action
- [ ] Archived goals are moved to Archived section

**Non-Functional Requirements:**
- Changes take effect within 30 seconds
- Users receive confirmation of changes

---

### Feature 4: Goal Suggestions

**Functional Requirements:**

1. **Suggested Goals:**
   - Based on user's spending patterns, suggest goals
   - Example: "Based on your spending, you could save $50/month by reducing dining out"
   - Show 3-5 suggested goals on creation screen

2. **Personalization:**
   - Analyze user's transaction history for patterns
   - Identify categories with high spending
   - Recommend realistic targets (not too high, not too low)

3. **Opt-out:**
   - Allow users to dismiss suggestions they don't want

**Acceptance Criteria:**
- [ ] Suggestions appear on goal creation screen
- [ ] Suggestions are based on user's actual spending
- [ ] Users can dismiss unwanted suggestions
- [ ] Suggestions are realistic and achievable

**Non-Functional Requirements:**
- Suggestions generated in < 1 second
- Suggestions are privacy-preserving (use anonymized data)

---

### Feature 5: Notifications

**Functional Requirements:**

1. **Milestone Notifications:**
   - Send push notification at 25%, 50%, 75%, 100% completion
   - Send email summary of progress (weekly)

2. **Alert Notifications:**
   - Send notification if user is falling behind on a goal
   - Send notification if user is making exceptional progress

3. **Notification Preferences:**
   - Users can opt-in/out of notifications
   - Users can customize frequency (daily, weekly, monthly)

**Acceptance Criteria:**
- [ ] Notifications are sent at milestone thresholds
- [ ] Weekly summaries are delivered
- [ ] Alert notifications are sent when user falls behind
- [ ] Users can customize notification preferences

**Non-Functional Requirements:**
- Notifications arrive within 1 minute of milestone reached
- Unsubscribe is easy (one-click)
- Notification delivery is reliable

---

## 6. Technical Considerations

### Data Model

```
USER ||--o{ GOAL : creates

GOAL {
    string id PK
    string user_id FK
    string type "savings | spending | debt"
    string name
    decimal target_amount
    decimal current_amount
    date target_date
    string category "for spending goals"
    string account_id "for debt goals"
    string status "active | completed | archived"
    datetime created_at
    datetime updated_at
}

USER ||--o{ MILESTONE : achieves

MILESTONE {
    string id PK
    string goal_id FK
    decimal percentage
    datetime achieved_at
}
```

### Technical Trade-offs

1. **Real-time vs. Batch Updates:**
   - *Decision:* Batch update progress every 6 hours
   - *Rationale:* Users don't need real-time updates; reduces API calls

2. **Caching Strategy:**
   - *Decision:* Cache goal progress in Redis for 15 minutes
   - *Rationale:* Dashboard loads quickly; progress is updated frequently

3. **Notification Delivery:**
   - *Decision:* Use a queue-based notification system (AWS SQS)
   - *Rationale:* Guarantees delivery; scalable

### Performance Requirements

- Goal creation: < 500ms response time
- Dashboard load: < 2 seconds (including all widgets)
- Progress updates: < 1 hour latency
- Notification delivery: < 1 minute latency

### Security Requirements

- Goal data encrypted at rest
- Goal data accessible only to owning user
- No goal data exposed in logs

---

## 7. Design Considerations

### Design Principles

1. **Simplicity:** Goal creation should feel effortless. No jargon, no complexity.
2. **Clarity:** Progress should be immediately visible and understandable.
3. **Motivation:** Celebrate wins, encourage when behind, never shame users.
4. **Consistency:** Follow Ledgerly's existing design language.

### Key Screens

1. **Goal Creation Flow:**
   - Step 1: Select goal type (Savings, Spending, Debt)
   - Step 2: Enter goal parameters
   - Step 3: Review and confirm

2. **Dashboard:**
   - Show 3-5 goals with progress bars
   - Show "Add Goal" button
   - Show "You're on track" or "You're behind" indicator

3. **Goal Detail View:**
   - Progress chart (line)
   - Key metrics (target, current, remaining)
   - Actionable insights ("To stay on track, save $X more per week")
   - Transaction history related to the goal

### Accessibility Requirements

- WCAG 2.1 AA compliant
- Screen-reader compatible
- Color-contrast requirements (4.5:1 for text)
- Keyboard-navigable

---

## 8. Dependencies & Assumptions

### Dependencies

- **Plaid Integration:** Transaction data for progress tracking
- **User Authentication:** Users must be logged in
- **Notification Service:** Push notification setup required
- **Analytics:** Event tracking for metrics

### Assumptions

- Users have at least one bank account connected
- Users have transaction history (at least 1 month)
- Users have given permission for notifications (opt-in)
- App is responsive and works on mobile

### Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low adoption | Users don't set goals | Medium | Guide during onboarding; send nudges |
| Inaccurate progress | Transactions miscategorized | Medium | Allow manual category editing; improve categorization |
| Technical complexity | Real-time updates challenging | Medium | Batch updates with eventual consistency |
| Performance impact | Dashboard slow | Low | Cache strategy; optimize queries |

---

## 9. Out of Scope

### Not in This Version
- Shared goals (multiple users on one goal)
- Automatic goal suggestion based on AI
- Goal templates (pre-set goals)
- Linking goals to specific accounts
- Investment goals
- Goal sharing on social media
- Goal gamification (achievements, challenges)

### Future Versions
- Goal templates for common financial goals
- Automatic goal adjustment based on spending patterns
- Goal recommendations using machine learning
- Shared goals for couples/families
- Integration with financial advisors

---

## 10. Appendix

### User Flow: Goal Creation

```
[Start] → [User clicks "Set a Goal"] → [Select goal type]
                                        │
                                        ▼
                                [Enter goal parameters]
                                        │
                                        ▼
                                [Review and confirm]
                                        │
                                        ▼
                                [Goal added to dashboard]
                                        │
                                        ▼
                                  [End]
```

### User Flow: Goal Progress Tracking

```
[Start] → [User opens dashboard] → [View goal progress bars]
                                    │
                                    ▼
                            [Click a goal for detail view]
                                    │
                                    ▼
                            [View progress chart]
                                    │
                                    ▼
                            [View milestones and insights]
                                    │
                                    ▼
                                  [End]
```

### Research References

- User research: Ledgerly discovery phase (Parts 1-3)
- Competitive analysis: Goal features in Mint, YNAB, and Personal Capital
- Retention analysis: Users who set goals are 3x more likely to retain
- User feedback: "I want to see progress" (common theme in interviews)

---

## 11. Review Checklist

- [x] Problem statement is clear and grounded in research
- [x] User stories cover all key user journeys
- [x] Success metrics are measurable and meaningful
- [x] Requirements are complete and testable
- [x] Technical constraints are considered
- [x] Design guidelines are established
- [x] Out of scope is clearly defined
- [x] Dependencies and risks are identified

---

## 12. Approval

| Role | Name | Approval Status | Date |
|------|------|-----------------|------|
| Product Lead | [Name] | Approved | [Date] |
| Engineering Lead | [Name] | Approved | [Date] |
| Design Lead | [Name] | Approved | [Date] |
| Head of Product | [Name] | Approved | [Date] |

---

## 13. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Your Name] | Initial version |
```

---

## Template 3: User Story Template

### User Story Template

```markdown
# [Epic Name]: User Stories

## Epic Overview

[Description of the epic and its purpose]

## User Stories

### Story 1: [Story Title]

**User Story:**
> As a [type of user],
> I want [some goal],
> So that [some reason].

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Edge Cases:**
- [Edge case 1]
- [Edge case 2]

**Design Requirements:**
- [Design requirement 1]
- [Design requirement 2]

**Technical Requirements:**
- [Technical requirement 1]
- [Technical requirement 2]

---

### Story 2: [Story Title]

[Continue with all stories]

---

## Story Points Summary

| Story | Points | Priority |
|-------|--------|----------|
| Story 1 | [Points] | [P0/P1/P2] |
| Story 2 | [Points] | [P0/P1/P2] |
| Total | [Total] | |
```

---

## Template 4: Acceptance Criteria Template

### Acceptance Criteria Template

```markdown
# [Feature Name]: Acceptance Criteria

## Feature Overview

[Description of feature]

---

## Acceptance Criteria: [Feature 1]

### Given:
- [Context/State 1]
- [Context/State 2]

### When:
- [Action 1]
- [Action 2]

### Then:
- [Expected outcome 1]
- [Expected outcome 2]

### Edge Cases:
- [Edge case 1] → [Expected behavior]
- [Edge case 2] → [Expected behavior]

### Acceptance Test:
- [ ] [Test 1]
- [ ] [Test 2]

---

## Acceptance Criteria: [Feature 2]

[Continue with all features]

---

## Final Checklist

- [ ] All acceptance criteria are testable
- [ ] Edge cases are covered
- [ ] Error states are handled
- [ ] Success paths are covered
- [ ] Performance is considered
- [ ] Accessibility is addressed
```

---

## Quick Checklist: PRD Review

### Before Submitting PRD

- [ ] Problem statement is clear and evidence-based
- [ ] User stories follow "As a/I want/So that" format
- [ ] Acceptance criteria are specific and testable
- [ ] Success metrics are measurable
- [ ] Out of scope is clearly defined
- [ ] Dependencies are identified
- [ ] Risks are documented with mitigations
- [ ] Technical constraints are considered
- [ ] Design principles are established
- [ ] Accessibility requirements are included
- [ ] Stakeholders have been consulted
- [ ] Version and date are documented
- [ ] Change log is maintained

### After PRD Review

- [ ] All feedback is addressed
- [ ] Engineering lead approves
- [ ] Design lead approves
- [ ] Product lead approves
- [ ] Stakeholders approve
- [ ] PRD is finalized and shared

---

*End of Appendix 3*
