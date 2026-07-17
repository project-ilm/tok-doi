// SPDX-License-Identifier: GPL-3.0-or-later
// © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
//
// Tok DOI — browser-first atomic provenance for the PIE signatory campaign.
// No backend. SHA-256 (Web Crypto) → OpenTimestamps (browser) → AyeSHA → record.

import { Ayesha } from './ayesha.js';

const enc = new TextEncoder();
export const hex = b => [...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,'0')).join('');

export async function sha256Hex(text){
  return hex(await crypto.subtle.digest('SHA-256', enc.encode(text)));
}

// Canonical endorsement statement — this exact string is what gets hashed & stamped.
export function buildStatement({signatory, affiliation, capacity, base_doi, base_sha256, signed_utc}){
  return [
    'I endorse the Proclamation of Individual Equity.',
    `base_doi: ${base_doi}`,
    `base_canonical_text_sha256: ${base_sha256}`,
    `signatory: ${signatory || '(anonymous)'}`,
    `affiliation: ${affiliation || '(none)'}`,
    `capacity: ${capacity || 'individual'}`,
    `signed_utc: ${signed_utc}`
  ].join('\n');
}

// Browser OpenTimestamps. Requires window.OpenTimestamps (loaded from CDN).
// Returns Uint8Array of the .ots proof for the given 32-byte SHA-256 digest.
export async function otsStampHash(hashHex){
  const OTS = window.OpenTimestamps;
  if(!OTS) throw new Error('OpenTimestamps library not loaded');
  const hashBytes = Uint8Array.from(hashHex.match(/.{2}/g).map(h=>parseInt(h,16)));
  const detached = OTS.DetachedTimestampFile.fromHash(new OTS.Ops.OpSHA256(), hashBytes);
  await OTS.stamp(detached);                       // calls public OTS calendars
  return Uint8Array.from(detached.serializeToBytes());
}

export async function otsVerifyHash(hashHex, otsBytes){
  const OTS = window.OpenTimestamps;
  if(!OTS) throw new Error('OpenTimestamps library not loaded');
  const hashBytes = Uint8Array.from(hashHex.match(/.{2}/g).map(h=>parseInt(h,16)));
  const original = OTS.DetachedTimestampFile.fromHash(new OTS.Ops.OpSHA256(), hashBytes);
  const detached = OTS.DetachedTimestampFile.deserialize([...otsBytes]);
  return await OTS.verify(detached, original);     // {} pending, or {chain:{timestamp,height}}
}

// Assemble a registry record conforming to registry/pie/SCHEMA.json
export async function buildRecord(fields){
  const signed_utc = new Date().toISOString();
  const statement = buildStatement({...fields, signed_utc});
  const statement_sha256 = await sha256Hex(statement);
  const otsBytes = await otsStampHash(statement_sha256);
  const ots_ayesha = await Ayesha.encode(otsBytes);
  const rec = {
    tok: 'tok:pie:PENDING',            // final id assigned at commit time, in order
    registry: 'pie',
    base_doi: fields.base_doi,
    signatory: fields.signatory || '',
    affiliation: fields.affiliation || '',
    capacity: fields.capacity || 'individual',
    statement,
    statement_sha256,
    ots_ayesha,
    signed_utc,
    model_of_record: 'Claude Opus 4.8'
  };
  if(fields.artifact_url) rec.artifact_url = fields.artifact_url;
  return rec;
}

// Keyless GitHub submission: pre-filled new-file compose URL (user clicks Commit).
export function composeUrl({owner, repo, branch, path, content}){
  const u = `https://github.com/${owner}/${repo}/new/${branch}`;
  const q = new URLSearchParams({filename: path, value: content});
  return `${u}?${q.toString()}`;
}

export function toJSONL(rec){ return JSON.stringify(rec); }
