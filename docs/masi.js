/* masi.js — MASI workflows in the browser. No tokens. No backend.
 * © 1993–2026 Abhishek Choudhary. All rights reserved. AyeAI.
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This is the same state machine as misty/masi.py, deliberately. Misty is the
 * publication layer and needs a Zenodo token; Tok is the atomic layer and needs
 * nothing at all. A researcher with no account, no key and no install can still
 * run the workflow, stamp the ledger, and hold a dated proof of every step.
 *
 * «No Added Sugar.»
 *
 * TRACKS and GATES below must stay identical to misty/masi.py. They are data in
 * both places for exactly that reason: one definition, two runtimes.
 */

export const MASI_VERSION = "1.0";

export const TRACKS = {
  ethics: {
    label: "IRB / ethics approval",
    states: ["drafting","submitted","clarifications","approved","amendment",
             "renewed","expired","closed","rejected"],
    loops: ["clarifications","amendment","renewed"],
    terminal: ["closed","rejected","expired"],
    evidence: { approved: ["approval_ref","approved_on","expires_on"] },
    note: "Approval carries a reference and an expiry. Both are recorded, because an expired approval is not an approval."
  },
  prereg: {
    label: "pre-registration",
    states: ["drafting","stamped","registered","collecting","deviation","complete","withdrawn"],
    loops: ["deviation"],
    terminal: ["complete","withdrawn"],
    evidence: { stamped: ["stamp_file","stamped_on"], collecting: ["collection_started_on"] },
    note: "The OTS stamp on the plan is the whole instrument. Deviations are recorded, never edited into the original."
  },
  paper: {
    label: "manuscript",
    states: ["drafting","stamped","internal-review","revising","ready"],
    loops: ["revising","internal-review"],
    terminal: ["ready"],
    evidence: { stamped: ["stamp_file","stamped_on"] },
    note: "Pre-venue. Hands off to journal, conference or chapter."
  },
  journal: {
    label: "journal article",
    states: ["prepared","submitted","desk-check","under-review","reviews-received",
             "major-revision","minor-revision","resubmitted","accepted","copyedit",
             "proof","published","rejected","withdrawn"],
    loops: ["major-revision","minor-revision","resubmitted","under-review",
            "reviews-received","copyedit","proof"],
    terminal: ["published","rejected","withdrawn"],
    evidence: { submitted: ["venue","submitted_on"], accepted: ["accepted_on"],
                published: ["published_on"] },
    review: true,
    note: "Editorial ladder. Acceptance requires at least one recorded review round — an accept with no reviews on the ledger is a record of nothing."
  },
  conference: {
    label: "conference paper or poster",
    states: ["prepared","abstract-submitted","abstract-accepted","full-submitted",
             "under-review","reviews-received","rebuttal","accepted","camera-ready",
             "presented","proceedings-published","rejected","withdrawn"],
    loops: ["under-review","reviews-received","rebuttal"],
    terminal: ["proceedings-published","presented","rejected","withdrawn"],
    evidence: { "abstract-submitted": ["venue","submitted_on"], accepted: ["accepted_on"],
                presented: ["presented_on","presentation_kind"] },
    review: true,
    note: "Two submission rounds and a rebuttal window, which journals do not have. presentation_kind is talk or poster."
  },
  chapter: {
    label: "book chapter",
    states: ["proposed","invited","drafting","submitted","editor-review","revising",
             "final","in-production","published","declined","withdrawn"],
    loops: ["editor-review","revising"],
    terminal: ["published","declined","withdrawn"],
    evidence: { submitted: ["volume_title","editor","submitted_on"], published: ["published_on"] },
    review: true,
    note: "Editor-led rather than peer-panel-led, and usually invited. The volume and its editor are recorded from the start."
  },
  patent: {
    label: "patent matter",
    states: ["drafting","disclosed","filed","published","office-action","granted","abandoned"],
    loops: ["office-action"],
    terminal: ["granted","abandoned"],
    evidence: { disclosed: ["stamp_file","stamped_on"],
                filed: ["application_no","jurisdiction","filed_on"] },
    note: "Filing is a human and counsel decision, never a script's. This tool stops there."
  }
};

export const REVIEW_DECISIONS =
  ["accept","minor-revision","major-revision","reject","desk-reject","conditional-accept"];

const iso = d => (d||"").slice(0,10);
const asDate = s => { const v = iso(s); return /^\d{4}-\d{2}-\d{2}$/.test(v) ? new Date(v+"T00:00:00Z") : null; };
const truthy = v => ["1","true","yes","y"].includes(String(v||"").toLowerCase());

export function newMatter(slug, track, title){
  if(!TRACKS[track]) throw new Error(`unknown track ${track}`);
  const now = new Date().toISOString().replace(/\.\d+Z$/,"Z");
  return { masi_version: MASI_VERSION, slug, track, title: title||slug,
           state: TRACKS[track].states[0], created: now, links: [], facts: {},
           reviews: [], history: [{at: now, state: TRACKS[track].states[0], note: "created"}] };
}

/** Why a transition is refused, or null if it is allowed. */
export function refusal(m, to){
  const spec = TRACKS[m.track];
  if(!spec.states.includes(to)) return `${to} is not a state of ${m.track}`;
  if(spec.terminal.includes(m.state)) return `${m.slug} is terminal at ${m.state}`;
  if(spec.review && to === "accepted" && !m.reviews.length)
    return "acceptance with no review round recorded — add the decision that was actually made";
  const need = (spec.evidence||{})[to]||[];
  const missing = need.filter(k => !(k in m.facts));
  if(missing.length) return `needs on the ledger first: ${missing.join(", ")}`;
  const ci = spec.states.indexOf(m.state), ni = spec.states.indexOf(to);
  if(ni < ci && !spec.loops.includes(to)) return `${to} is behind ${m.state} and is not a loop state`;
  return null;
}

export function advance(m, to, note){
  const why = refusal(m, to);
  if(why) throw new Error(why);
  const now = new Date().toISOString().replace(/\.\d+Z$/,"Z");
  m.state = to;
  m.history.push({at: now, state: to, note: note||""});
  return m;
}

export function addReview(m, round, decision, reviewer, note, received_on){
  if(!TRACKS[m.track].review) throw new Error(`track ${m.track} has no peer-review stage`);
  if(!REVIEW_DECISIONS.includes(decision)) throw new Error(`unknown decision ${decision}`);
  const now = new Date().toISOString().replace(/\.\d+Z$/,"Z");
  m.reviews.push({round: Number(round), decision, reviewer: reviewer||"(anonymous)",
                  received_on: received_on || iso(now), note: note||"", at: now});
  m.history.push({at: now, state: m.state, note: `review r${round}: ${decision}`});
  return m;
}

/* -------------------------------------------------------------------------
 * Gates. Identical logic to misty/masi.py. `all` is every matter in the
 * workspace, so links can be resolved without a filesystem.
 * ------------------------------------------------------------------------- */
export function gates(m, all){
  const res = [];
  const linked = (m.links||[]).map(s => (all||[]).find(x => x.slug === s)).filter(Boolean);
  const byTrack = {};
  linked.forEach(l => (byTrack[l.track] = byTrack[l.track]||[]).push(l));

  if(truthy(m.facts.human_subjects)){
    const eth = byTrack.ethics || [];
    if(!eth.length){
      res.push(["G1","ERROR","human_subjects is set but no ethics matter is linked"]);
    } else {
      const e = eth[0];
      if(!["approved","renewed","amendment"].includes(e.state)){
        res.push(["G1","ERROR",`ethics matter ${e.slug} is ${e.state}, not approved`]);
      } else {
        const ap = asDate(e.facts.approved_on), st = asDate(m.facts.collection_started_on),
              ex = asDate(e.facts.expires_on);
        if(ap && st && st < ap)
          res.push(["G1","ERROR",`collection began ${iso(m.facts.collection_started_on)} but approval is dated ${iso(e.facts.approved_on)} — an approval cannot be applied backwards`]);
        else if(ap && st)
          res.push(["G1","ok",`approval ${iso(e.facts.approved_on)} precedes collection ${iso(m.facts.collection_started_on)}`]);
        if(ex && ex < new Date() && m.state !== "complete")
          res.push(["G1","WARN",`ethics approval expired ${iso(e.facts.expires_on)} — renew before further collection`]);
      }
    }
  }

  if(m.track === "prereg"){
    const stamped = asDate(m.facts.stamped_on), started = asDate(m.facts.collection_started_on);
    if(started && !stamped)
      res.push(["G2","ERROR","collection has a start date but the plan was never stamped"]);
    else if(stamped && started){
      if(stamped > started)
        res.push(["G2","ERROR",`plan stamped ${iso(m.facts.stamped_on)}, collection began ${iso(m.facts.collection_started_on)} — this is a post-hoc plan, not a pre-registration`]);
      else
        res.push(["G2","ok",`plan stamped ${iso(m.facts.stamped_on)} before collection ${iso(m.facts.collection_started_on)}`]);
    }
  }

  const pat = byTrack.patent || [];
  if(pat.length && m.track !== "patent"){
    const unfiled = pat.filter(p => ["drafting","disclosed"].includes(p.state));
    if(unfiled.length)
      res.push(["G3","ERROR",`linked patent matter not yet filed (${unfiled.map(p=>p.slug).join(", ")}). Minting a DOI publishes the invention; in a first-to-file jurisdiction that can end the novelty. File first, or record a deliberate defensive disclosure.`]);
    else
      res.push(["G3","ok","linked patent matters are filed or beyond"]);
  }
  if(truthy(m.facts.defensive_publication))
    res.push(["G3","WARN","defensive_publication is asserted — publication will bar a later patent on this disclosure. Recorded as deliberate."]);

  if(TRACKS[m.track].review){
    const late = ["accepted","camera-ready","copyedit","proof","published",
                  "proceedings-published","in-production"];
    if(late.includes(m.state)){
      if(!m.reviews.length)
        res.push(["G4","ERROR",`${m.state} reached with no review round on the ledger`]);
      else
        res.push(["G4","ok",`${m.reviews.length} review round(s); last decision ${m.reviews[m.reviews.length-1].decision}`]);
    }
  }

  if(["journal","conference","chapter"].includes(m.track)){
    const pre = byTrack.prereg || [];
    if(pre.length && !pre.some(p => ["complete","collecting","registered"].includes(p.state)))
      res.push(["G5","WARN","a pre-registration is linked but never reached registered"]);
    if(truthy(m.facts.human_subjects) && !pre.length)
      res.push(["G5","WARN","human-subjects work with no linked pre-registration"]);
  }

  if(!res.length) res.push(["--","ok","no gate applies to this matter yet"]);
  return res;
}

export function mintable(m, all){
  const errs = gates(m, all).filter(g => g[1] === "ERROR").map(g => `${g[0]}: ${g[2]}`);
  return { ok: !errs.length, errors: errs };
}

/** The canonical bytes a ledger is stamped over. Stable ordering, so the same
 *  ledger always yields the same digest in the browser and on the CLI. */
export function canonical(m){
  const ordered = {
    masi_version: m.masi_version, slug: m.slug, track: m.track, title: m.title,
    state: m.state, created: m.created,
    links: [...(m.links||[])].sort(),
    facts: Object.fromEntries(Object.entries(m.facts||{}).sort()),
    reviews: m.reviews||[], history: m.history||[]
  };
  return JSON.stringify(ordered);
}
