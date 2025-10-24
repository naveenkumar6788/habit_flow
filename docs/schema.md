# Firestore Schema

This app uses the following collections. Timestamps are stored as ISO-8601 UTC strings unless noted.

users (doc id = uid)
- displayName: string | null
- photoUrl: string | null
- points: number (int)
- fcmTokens: string[]
- updatedAt: server timestamp (optional)

habits (doc id = uuid)
- ownerId: string (uid)
- title: string
- description: string | null
- archived: boolean
- updatedAt: string (ISO-8601)

habit_entries (doc id = uuid)
- ownerId: string (uid)
- habitId: string (habits.id)
- dayKey: string (YYYY-MM-DD)
- completed: boolean
- updatedAt: string (ISO-8601)

posts (doc id = uuid)
- userId: string (uid)
- content: string
- createdAt: string (ISO-8601)
- likes: string[] (uid)

comments (doc id = uuid)
- postId: string (posts.id)
- userId: string (uid)
- text: string
- createdAt: string (ISO-8601)

events (doc id = uuid)
- title: string
- description: string
- dateTime: string (ISO-8601)
- createdBy: string (uid)
- rsvps: string[] (uid)

notifications (doc id = uuid)
- userId: string (uid)
- type: string ('like' | 'comment' | 'rsvp' | ...)
- message: string
- refId: string (related entity id)
- read: boolean
- createdAt: string (ISO-8601)

Suggested security rules (conceptual)
- Allow authenticated users to read public collections (posts, comments, events) and their own documents.
- Write constraints:
  - habits, habit_entries: request.auth.uid == resource.data.ownerId
  - posts: request.auth.uid == request.resource.data.userId
  - comments: request.auth.uid == request.resource.data.userId
  - events: request.auth.uid == request.resource.data.createdBy
  - notifications: only the system or the owner may write; owner may update read=true

Indexes
- posts: orderBy createdAt desc
- comments: orderBy createdAt desc
- events: orderBy dateTime asc
