# Firestore Schema (Lifestyle & Engagement App)

This schema aligns with the existing models under lib/models and the services under lib/services.

Collections overview
- users (docId: uid)
  - displayName: string | null
  - photoUrl: string | null
  - points: number (int)
  - fcmTokens: string[]
  - updatedAt: timestamp

- habits (docId: auto)
  - ownerId: string (uid)
  - title: string
  - description: string | null
  - archived: boolean
  - updatedAt: timestamp or ISO string

- habit_entries (docId: auto)
  - habitId: string (ref: habits)
  - ownerId: string (uid)
  - dayKey: string (YYYY-MM-DD)
  - completed: boolean

- posts (docId: auto)
  - userId: string (uid)
  - content: string
  - createdAt: timestamp or ISO string
  - likes: string[] (uids)

- comments (docId: auto)
  - postId: string (ref: posts)
  - userId: string (uid)
  - text: string
  - createdAt: timestamp or ISO string

- events (docId: auto)
  - title: string
  - description: string
  - dateTime: timestamp or ISO string
  - createdBy: string (uid)
  - rsvps: string[] (uids)

- notifications (docId: auto)
  - userId: string (uid)
  - type: string (like | comment | rsvp | system)
  - message: string
  - refId: string | null (refers to related entity)
  - read: boolean
  - createdAt: timestamp or ISO string

Notes
- The app currently serializes many date fields as ISO strings for web friendliness; you can migrate to Firestore Timestamps if preferred.
- All write operations should occur from authenticated users only.

Suggested security rules (high level)
// Pseudo-rules. Apply and refine in Firebase Console > Firestore Rules.
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return isSignedIn() && request.auth.uid == uid; }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isOwner(userId);
    }

    match /habits/{id} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if resource.data.ownerId == request.auth.uid;
    }

    match /habit_entries/{id} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.resource.data.ownerId == request.auth.uid;
    }

    match /posts/{id} {
      allow read: if true; // public feed
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }

    match /comments/{id} {
      allow read: if true;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }

    match /events/{id} {
      allow read: if true;
      allow create: if isSignedIn() && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if resource.data.createdBy == request.auth.uid;
    }

    match /notifications/{id} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isSignedIn(); // typically via server or Cloud Functions
      allow update: if isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
  }
}

Recommended composite indexes (if you see index errors)
- posts by createdAt desc: collection=posts, orderBy=createdAt desc
- comments by postId+createdAt: collection=comments, where=postId, orderBy=createdAt desc
- habit_entries by ownerId+dayKey: collection=habit_entries, where=ownerId, orderBy=dayKey desc

Seed data considerations
- Create a users/{uid} document at first sign-in (app attempts this with merge writes).
- Initialize points to 0 and fcmTokens to [].
- Optionally pre-populate events and badges from an admin console or a one-time script.
