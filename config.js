/* ============================================================================
   SIR ROHAIL AHMED · Accounting · website settings
   THE ONLY FILE YOU EDIT. Every page reads it, so keep one copy beside them.
   Built by Nexlyr Solutions.

   Rule: a blank value hides that thing on the site. Nothing invented ever
   shows: no placeholder number, no made-up review, no fake result.
   ============================================================================ */

window.RA_CONFIG = {

  /* 1. WHO HE IS ------------------------------------------------------------ */
  name:      'Sir Rohail Ahmed',
  shortName: 'Rohail Ahmed',
  subject:   'Accounting',
  city:      'Karachi',
  yearsTeaching: 20,             // rohailahmed.com: "more than twenty years"

  /* 2. CONTACT -------------------------------------------------------------- */
  // WhatsApp: digits only, country code first. Taken from his YouTube
  // description ("WhatsApp/Call for Enrollment"). Confirm before launch.
  whatsapp:     '923060233883',
  phoneDisplay: '0306 0233883',
  email:        '',                // blank = hidden

  instagram:      'https://www.instagram.com/rohailahmed12/',
  instagramClass: 'https://www.instagram.com/classofrohailahmed/',
  facebook:       'https://www.facebook.com/SirRohailAhmed/',
  youtube:        'https://www.youtube.com/@AccountingbySirRohail',

  /* Places he teaches in person. Remove a line to hide it. */
  campuses: [
    { name: 'Credo College', note: 'Founding member · Credo School & College System',
      address: 'E-136–141, Block 7, Gulshan-e-Iqbal, Main Abul Hasan Isphahani Road, Karachi',
      map: 'https://www.google.com/maps/search/?api=1&query=Credo+College+Gulshan-e-Iqbal+Block+7+Karachi' }
  ],
  online: true,

  /* 3. VIDEOS — real YouTube IDs only. ------------------------------------- */
  featuredVideo: {
    id: 'NVXNyyYHC3o',
    title: 'O Level Accounting 7707 · May/June 2022 Paper 22 · full solution',
    chapters: ['Cash books', 'Single entry (incomplete records)', 'Errors and suspense accounts', 'Inventory valuation', 'Company accounts']
  },

  /* 4. STUDENT PORTAL (Supabase) -------------------------------------------
     Supabase → Project Settings → API. Paste the Project URL and the
     publishable / anon key. NEVER the service_role / secret key.
     Blank = sign-in stays off and the portal runs as an on-device study desk. */
  SUPABASE_URL:      '',
  SUPABASE_ANON_KEY: '',
  MAX_DEVICES: 2,                // keep in step with backend.sql

  /* Lets you demo the portal and admin panel before Supabase is connected.
     Everything in preview mode is sample data saved only in that browser,
     and every preview screen says so. Set to false at launch. */
  PORTAL_PREVIEW: true,

  /* 5. REAL MATERIAL ONLY — empty lists hide their sections ---------------- */
  /* { value: 'A*', label: '7707 Accounting', note: 'May/June 2026', name: 'Student name' } */
  RESULTS: [],
  /* { name: 'Ayesha K.', meta: 'AS 9706 · 2026', text: 'What they actually said.' } */
  REVIEWS: [],

  /* 6. SITE ----------------------------------------------------------------- */
  siteUrl:   'https://sir-rohail-ahmed.vercel.app',
  agency:    'Nexlyr Solutions',
  agencyUrl: 'https://nexlyr.solutions'
};

/* ============================================================================
   Plumbing. Nothing to edit below.
   ============================================================================ */
(function () {
  var C = window.RA_CONFIG;
  C.live = !!(C.SUPABASE_URL && C.SUPABASE_ANON_KEY);
  if (C.SUPABASE_URL) C.SUPABASE_URL = C.SUPABASE_URL.replace(/\/+$/, '');
  if (/service_role|sb_secret/.test(C.SUPABASE_ANON_KEY || '')) {
    console.error('[RA] That is a SECRET Supabase key. Never put it in a file a browser loads. Use the anon / publishable key.');
    C.live = false;
  }
  C.waUrl = function (text) {
    if (C.whatsapp) return 'https://wa.me/' + C.whatsapp + (text ? '?text=' + encodeURIComponent(text) : '');
    if (C.instagram) return C.instagram;
    if (C.facebook) return C.facebook;
    return 'contact.html';
  };
  C.waLabel = C.whatsapp ? 'WhatsApp' : (C.instagram ? 'Instagram' : 'Facebook');
})();
