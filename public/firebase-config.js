// Your Firebase project's config, from Firebase console > Project settings > Your apps.
// These aren't secret: they identify your project, and firestore.rules decides who can do what.
export const firebaseConfig = {
  apiKey: "AIzaSyCX28hJBDSYNoi2uU-sYgtaStAyvri6clc",
  authDomain: "loot-goblins-roster.firebaseapp.com",
  projectId: "loot-goblins-roster",
  storageBucket: "loot-goblins-roster.firebasestorage.app",
  messagingSenderId: "969852083677",
  appId: "1:969852083677:web:af9d10c656fdea55646a34"
};

// Officers can edit or remove anything. List them by character ID: open your own character page
// and copy the "Character ID" line at the bottom. Keep this in sync with isOfficer() in firestore.rules.
export const OFFICER_CHARS = [];

// Left in so a copy of the old version still cached on someone's phone loads instead of breaking.
export const OFFICERS = [];

// Discord server ID for the "On Discord" box. In Discord: Server Settings > Widget, turn on Enable Server Widget,
// then copy the Server ID shown there and paste it between the quotes.
export const DISCORD_SERVER_ID = "363258337736785921";
