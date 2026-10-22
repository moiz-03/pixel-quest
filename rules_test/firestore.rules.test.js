const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

// ─────────────────────────────────────────────────────────────────────────────
// Setup
// ─────────────────────────────────────────────────────────────────────────────
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'pixel-quest-aba36',
    firestore: {
      rules: fs.readFileSync(
        path.resolve(__dirname, '..', 'firestore.rules'),
        'utf8'
      ),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// Convenience: an authenticated context for a given uid
const asAlice = () => testEnv.authenticatedContext('alice');
const asBob = () => testEnv.authenticatedContext('bob');
const asAnon = () => testEnv.unauthenticatedContext();

// ═════════════════════════════════════════════════════════════════════════════
// Unauthenticated access
// ═════════════════════════════════════════════════════════════════════════════
describe('Unauthenticated access', () => {
  it('cannot read any user doc', async () => {
    const db = asAnon().firestore();
    await assertFails(db.doc('users/alice').get());
  });

  it('cannot write any user doc', async () => {
    const db = asAnon().firestore();
    await assertFails(db.doc('users/alice').set({ level: 0 }));
  });

  it('cannot read quests subcollection', async () => {
    const db = asAnon().firestore();
    await assertFails(db.doc('users/alice/quests/q1').get());
  });

  it('cannot write quests subcollection', async () => {
    const db = asAnon().firestore();
    await assertFails(db.doc('users/alice/quests/q1').set({ title: 'x' }));
  });

  it('can read usernames (public)', async () => {
    const db = asAnon().firestore();
    await assertSucceeds(db.doc('usernames/alice').get());
  });

  it('cannot create a username', async () => {
    const db = asAnon().firestore();
    await assertFails(
      db.doc('usernames/alice').set({ uid: 'alice' })
    );
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Own user doc
// ═════════════════════════════════════════════════════════════════════════════
describe('Own user doc', () => {
  it('alice can read her own doc', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(db.doc('users/alice').get());
  });

  it('alice can create her own doc', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(
      db.doc('users/alice').set({
        level: 0,
        totalXp: 0,
        streak: 0,
        xpSpent: 0,
        streakFreezes: 0,
      })
    );
  });

  it('alice can update her own doc', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(
      db.doc('users/alice').set({ totalXp: 100 }, { merge: true })
    );
  });

  it('alice can delete her own doc', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(db.doc('users/alice').delete());
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Cross-user access
// ═════════════════════════════════════════════════════════════════════════════
describe('Cross-user access', () => {
  it('alice cannot read bob\'s doc', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('users/bob').get());
  });

  it('alice cannot write bob\'s doc', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('users/bob').set({ level: 99 }));
  });

  it('alice cannot update bob\'s doc', async () => {
    const db = asAlice().firestore();
    await assertFails(
      db.doc('users/bob').set({ totalXp: 999999 }, { merge: true })
    );
  });

  it('alice cannot delete bob\'s doc', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('users/bob').delete());
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Quests subcollection
// ═════════════════════════════════════════════════════════════════════════════
describe('Quests subcollection', () => {
  it('alice can read her own quests', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(db.doc('users/alice/quests/q1').get());
  });

  it('alice can write her own quests', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(
      db.doc('users/alice/quests/q1').set({
        title: 'Read',
        category: 'health',
        xp: 10,
        completed: false,
        completedDates: [],
      })
    );
  });

  it('alice cannot read bob\'s quests', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('users/bob/quests/q1').get());
  });

  it('alice cannot write bob\'s quests', async () => {
    const db = asAlice().firestore();
    await assertFails(
      db.doc('users/bob/quests/q1').set({ title: 'Hack' })
    );
  });

  it('alice cannot list bob\'s quests', async () => {
    const db = asAlice().firestore();
    await assertFails(db.collection('users/bob/quests').get());
  });

  it('alice can list her own quests', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(db.collection('users/alice/quests').get());
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Other subcollections (wildcard match)
// ═════════════════════════════════════════════════════════════════════════════
describe('Wildcard subcollections', () => {
  it('alice can read her own arbitrary subcollection', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(db.doc('users/alice/notes/n1').get());
  });

  it('alice cannot read bob\'s arbitrary subcollection', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('users/bob/notes/n1').get());
  });

  it('alice can write her own nested subcollection', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(
      db.doc('users/alice/settings/theme').set({ mode: 'dark' })
    );
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Username registry
// ═════════════════════════════════════════════════════════════════════════════
describe('Username registry', () => {
  it('anyone can read a username', async () => {
    const db = asBob().firestore();
    await assertSucceeds(db.doc('usernames/alice').get());
  });

  it('alice can claim a username for herself', async () => {
    const db = asAlice().firestore();
    await assertSucceeds(
      db.doc('usernames/alice').set({
        uid: 'alice',
        createdAt: new Date(),
      })
    );
  });

  it('alice cannot claim a username for someone else', async () => {
    const db = asAlice().firestore();
    await assertFails(
      db.doc('usernames/alice').set({ uid: 'bob' })
    );
  });

  it('alice cannot claim a username without a uid field', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('usernames/alice').set({}));
  });

  it('alice cannot update an existing username', async () => {
    // Seed: use admin bypass to write directly.
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('usernames/alice').set({ uid: 'alice' });
    });
    const db = asAlice().firestore();
    await assertFails(
      db.doc('usernames/alice').set({ uid: 'alice' }, { merge: true })
    );
  });

  it('alice can delete her own username', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('usernames/alice').set({ uid: 'alice' });
    });
    const db = asAlice().firestore();
    await assertSucceeds(db.doc('usernames/alice').delete());
  });

  it('alice cannot delete bob\'s username', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('usernames/bob').set({ uid: 'bob' });
    });
    const db = asAlice().firestore();
    await assertFails(db.doc('usernames/bob').delete());
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Global deny catch-all
// ═════════════════════════════════════════════════════════════════════════════
describe('Global deny catch-all', () => {
  it('alice cannot read an unrelated top-level collection', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('secrets/key').get());
  });

  it('alice cannot write an unrelated top-level collection', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('secrets/key').set({ value: 'x' }));
  });

  it('alice cannot read another user\'s username data via top-level doc', async () => {
    const db = asAlice().firestore();
    await assertFails(db.doc('admin/config').get());
  });
});