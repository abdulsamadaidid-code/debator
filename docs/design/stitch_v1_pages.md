# Debator V1 Pages And Stitch Prompt

## Page Inventory

### 1. Welcome / Landing
Purpose:
- explain what Debator is in one screen
- set the expectation that this is structured debate, not general comment-thread chaos
- send users into sign up or demo exploration

Key features:
- brand hero with clear positioning
- short explanation of structured debate format
- CTA for create account
- secondary CTA for demo / browse
- trust signals about civility, logic, and topic-first discovery

### 2. Auth / Magic Link
Purpose:
- create a low-friction entry point
- make sign-in feel fast, modern, and safe

Key features:
- email input
- send magic link action
- simple explanation of what happens next
- error / success helper state
- back action to welcome

### 3. Onboarding
Purpose:
- establish identity and preferences before full participation
- make the account feel intentional from the start

Key features:
- display name
- handle
- topic interest selection
- debate goals or experience level
- civility / community norms acknowledgement
- completion CTA

### 4. Discover / Home Feed
Purpose:
- make the app feel active and worth returning to
- highlight the strongest active debates and major topics

Key features:
- featured debates
- live debate strip
- recommended topics
- open-seat debates
- quick metrics like audience, live count, active topics
- fast route into a debate detail page

### 5. Topics Index
Purpose:
- help users browse the debate arenas they care about

Key features:
- topic search
- topic chips or filters
- topic cards with active debate count
- followed topics state
- sort options such as trending / newest / most active

### 6. Topic Detail
Purpose:
- turn broad interest into actual participation

Key features:
- topic hero with description
- active debates in this topic
- follow topic action
- top contributors or top debaters in the topic
- trend or activity indicators

### 7. Debate Detail
Purpose:
- be the core reading and participation screen

Key features:
- debate proposition and title
- topic badge, format badge, live state
- join for / join against
- audience score / support split
- round-by-round argument timeline
- participants roster
- judging prompt
- report action
- follow / save debate

### 8. Create Debate
Purpose:
- guide users into launching a clean, high-quality debate

Key features:
- topic picker
- title
- proposition
- overview
- format selector
- starting side selector
- judging criteria
- opening statement
- identity notice showing who is publishing

### 9. Round Composer
Purpose:
- provide a focused writing flow for later debate rounds

Key features:
- current debate context
- selected side
- round label
- argument editor
- evidence note field
- save draft / publish actions

### 10. Profile
Purpose:
- anchor identity, trust, and continuity

Key features:
- avatar / identity header
- handle and display name
- rating / reputation
- debates participated in
- topics explored / followed
- saved debates
- sign out
- account environment or status info

### 11. Notifications / Activity
Purpose:
- bring users back into active debates

Key features:
- replies / round updates
- debate followed updates
- vote milestones
- moderation notices
- read / unread state

### 12. Saved / Following
Purpose:
- give users continuity and memory

Key features:
- saved debates
- followed topics
- active debates you joined
- drafts

### 13. Search Results
Purpose:
- support scale beyond simple topic browsing

Key features:
- query input
- tabbed results for debates / topics / users
- smart empty state
- recent searches

### 14. Moderation / Report Flow
Purpose:
- make the debate environment safe enough to scale

Key features:
- report reason picker
- optional note
- confirmation state
- moderation status feedback

### 15. Settings / Account
Purpose:
- handle account preferences cleanly

Key features:
- notification preferences
- privacy settings
- sign out
- account metadata
- app environment / version metadata for internal builds

## Stitch Prompt

Use this prompt in Google Stitch:

```text
Design a complete mobile-first and desktop-responsive product UI for an app called Debator.

Debator is a social product built specifically for structured debates. It should feel like a high-signal arena for ideas, not like a generic social feed. The experience should feel modern, premium, editorial, and intellectually energetic, while still welcoming and easy to use.

DESIGN SYSTEM:
- Product vibe: editorial social platform, structured debate arena, premium knowledge app
- Platform: mobile-first app with strong tablet and desktop layouts
- Background: warm parchment and stone gradients, atmospheric but subtle
- Surface style: creamy layered cards with soft borders and diffused shadows
- Primary color: deep teal (#0F6A67) for actions and trust
- Secondary color: clay orange (#C96A33) for energy and tension
- Support color: muted navy (#204C7A) for secondary emphasis and analytical modules
- Text: dark charcoal primary text, muted gray secondary text
- Typography: Space Grotesk for headlines, Plus Jakarta Sans for body/interface
- Shape language: rounded corners, clean pills, soft glassy navigation, refined spacing
- Avoid: generic startup SaaS, purple gradients, gamer UI, crowded social media clutter

PRODUCT PRINCIPLES:
- The proposition is always the hero.
- Every page should support the loop: discover, evaluate, join, argue, follow, return.
- Debate must feel structured and consent-based.
- The design should reward clarity, evidence, and thoughtful disagreement.

DESIGN THESE SCREENS:

1. Welcome / Landing
- Brand hero explaining structured debate
- Primary CTA to create account
- Secondary CTA for demo / browse
- Short trust and structure benefits

2. Auth / Magic Link
- Clean email sign-in screen
- Send magic link primary action
- Clear step explanation and helper state

3. Onboarding
- Display name and handle setup
- Topic interests
- Debate goals or experience level
- Community norms acknowledgement

4. Discover / Home
- Featured debates
- Live debates
- Topic highlights
- Quick product metrics
- Clear entry into debate details

5. Topics Index
- Search, filters, topic cards, followed topics

6. Topic Detail
- Topic hero
- Active debates in that topic
- Follow action
- Top contributors / trend indicators

7. Debate Detail
- Large proposition header
- Join for / join against actions
- Audience score split
- Round-by-round timeline
- Participant roster
- Judging prompt
- Save / follow / report affordances

8. Create Debate
- Guided, premium form layout
- Topic, title, proposition, overview, format, starting side, judging prompt, opening statement
- Identity notice showing who is publishing

9. Round Composer
- Focused writing screen for publishing a debate round
- Debate context, round label, statement editor, evidence note, publish CTA

10. Profile
- Identity header
- Handle, rating, activity summary
- Participated debates
- Topics explored / followed
- Saved debates

11. Notifications / Activity
- Debate updates, replies, followed debate changes, moderation messages

12. Saved / Following
- Saved debates, followed topics, joined debates, drafts

13. Search Results
- Results for debates, topics, and users

14. Moderation / Report Flow
- Report modal or screen
- Reason picker and confirmation state

15. Settings / Account
- Notification preferences
- Privacy
- Sign out
- Internal build metadata area

LAYOUT NOTES:
- Mobile bottom navigation should feel docked and refined
- Desktop layouts should rebalance into columns instead of stretching mobile cards
- Debate detail should feel like a reading interface with a side intelligence panel
- Create, onboarding, and auth should feel more focused than feed screens

ATMOSPHERE KEYWORDS:
- editorial
- structured debate
- premium knowledge product
- warm parchment gradients
- teal and clay accents
- modern social app
- rigorous but welcoming

Output a cohesive multi-screen product design with one consistent design system across all pages.
```
