# Chat Messaging (1:1)

## User Story
As a signed-in user who has been matched, I want to exchange messages with my potential roommate so that we can coordinate and decide if we're a good fit.

## Acceptance Criteria
- I can only message users with whom I have an active match (enforced by matcher-service dependency).
- I can open an existing conversation with my match and see the latest messages in chronological order.
- I can send a non-empty text message; after sending, I see my message in the thread with my name and a timestamp.
- I can send files or media in a conversation (images, documents, etc.).
- If I try to send an empty message, I get a validation error and nothing is sent.
- I cannot view a conversation that I am not a participant in (authorization).
- I cannot start a conversation with a user I am not matched with.
- I can block another user in a conversation, preventing further messages.
- I can report another user for inappropriate behavior, creating a report record for admin review.
- When a new message is posted while I'm viewing the thread, it appears without a full page reload (progressive: ActionCable/WebSocket; acceptable for now to assert the message appears after submit in a single session).

## MVC Outline

**Models**
- `User`: existing model with authentication.
- `ActiveMatch`: `id`, `user_one_id:integer`, `user_two_id:integer`, `status:string`
  - Represents matched users who can communicate.
  - Validates that both users exist and are different.
  - Status values: 'active', 'inactive', 'expired'.
- `Conversation`: `id`, `participant_one_id:integer`, `participant_two_id:integer`, `created_at`, `updated_at`
  - Validates that the two participants are different.
  - Validates that participants have an active match before creating conversation.
  - Scope: `for(user)` → conversations where user is participant.
  - Method: `participant?(user)` → boolean check if user is a participant.
- `Message`: `id`, `conversation_id:integer`, `user_id:integer`, `body:text`, `created_at`
  - Validations: `body` presence (for text messages).
  - Associations: `belongs_to :conversation`, `belongs_to :user`.
  - Default scope/order: oldest → newest or explicit `created_at asc`.
  - Optional: `attachment` for file uploads (Active Storage).
- `Block`: `id`, `blocker_id:integer`, `blocked_id:integer`, `created_at`
  - Represents when one user blocks another.
  - Validates uniqueness of blocker/blocked pair.
  - Scope: `active_blocks_for(user)` → all blocked user IDs for a given user.
- `Report`: `id`, `reporter_id:integer`, `reported_id:integer`, `conversation_id:integer`, `reason:text`, `status:string`, `created_at`
  - Stores user reports for admin review.
  - Status values: 'pending', 'reviewed', 'resolved', 'dismissed'.
  - Validations: `reason` presence.

**Views**
- `conversations/index.html.erb`: list existing conversations for current user (names + last message snippet).
- `conversations/show.html.erb`: thread view with messages, sender, timestamp; form to send message; buttons for block/report.
- Partials: `_message.html.erb`, `_form.html.erb`, `_block_modal.html.erb`, `_report_modal.html.erb`.

**Controllers**
- `ConversationsController`:
  - `#index` - list all conversations for current user (auth: signed-in user).
  - `#show` - display one conversation with messages (auth: participants only).
  - `#create` - start new conversation (auth: must be matched users).
  - `#block` - block the other participant (auth: participants only).
  - `#report` - report the other participant (auth: participants only).
- `MessagesController`:
  - `#create` - create message in conversation (auth: participants only, not blocked).
  - Handles both text messages and file uploads.
  - On failure, re-render show with errors.

**Routing**
```rb
resources :conversations, only: [:index, :show, :create] do
  resources :messages, only: [:create]
  member do
    post :block   # POST /conversations/:id/block
    post :report  # POST /conversations/:id/report
  end
end
```

## Dependencies (Please See Project Specification Section 2.4)

**messenger module depends on:**
- `user-service`: For user authentication (JWT tokens) and profile data
- `matcher-service`: To ensure that only matched users can communicate

**Database Tables Used:**
- `users` (from user-service)
- `active_matches` (from matcher-service) 
- `conversations` (messenger)
- `messages` (messenger)
- `reports` (shared - logs issues)

## Key Business Rules

1. **Matching Requirement**: Users MUST have an active match before they can message each other.
2. **Participant Authorization**: Only conversation participants can view/send messages.
3. **Blocking**: Once blocked, the blocked user cannot send messages to the blocker.
4. **Reporting**: Reports are logged for admin review (see `reports` table in database schema).
5. **Message Validation**: Empty messages are rejected with validation errors.

## Future Enhancements
- Real-time notifications when new messages arrive (ActionCable/WebSockets)
- Read receipts and typing indicators
- Message reactions (emoji reactions)
- Search within conversation history
- Delete/edit sent messages (within time window)