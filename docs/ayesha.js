// SPDX-License-Identifier: GPL-3.0-or-later
// © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
//
// AyeSHA — encoding layer for Tok DOI.
//
// PURPOSE: the raw OpenTimestamps (.ots) proof is never stored in the registry.
// It is encoded to a compact, text-safe, self-verifying string via AyeSHA, and
// only that string is committed.
//
// ⚠ THE DEFAULT CODEC BELOW IS A DOCUMENTED PLACEHOLDER, not the canonical AyeSHA.
//   It is fully reversible (so verification works) and self-checked, but it is
//   plain base64url + a truncated checksum. Replace `Ayesha.codec` with the
//   canonical AyeSHA implementation when ready — the INTERFACE is stable:
//       encode(Uint8Array) -> string
//       decode(string)     -> Uint8Array   (throws on checksum mismatch)
//   Nothing else in Tok DOI needs to change on swap.

const _b64url = {
  enc(bytes){ let s=''; for(const b of bytes) s+=String.fromCharCode(b);
    return btoa(s).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,''); },
  dec(str){ str=str.replace(/-/g,'+').replace(/_/g,'/'); while(str.length%4)str+='=';
    const bin=atob(str); const out=new Uint8Array(bin.length);
    for(let i=0;i<bin.length;i++)out[i]=bin.charCodeAt(i); return out; }
};

async function _sha256(bytes){
  const d=await crypto.subtle.digest('SHA-256', bytes);
  return new Uint8Array(d);
}
function _hex(bytes){ return [...bytes].map(b=>b.toString(16).padStart(2,'0')).join(''); }

export const Ayesha = {
  version: 'AYESHA1',
  // Swap this object for the canonical AyeSHA codec; keep the method signatures.
  codec: {
    async encode(bytes){
      const sum = _hex(await _sha256(bytes)).slice(0,8);      // integrity tag
      return `AYESHA1.${_b64url.enc(bytes)}.${sum}`;
    },
    async decode(str){
      const m = /^AYESHA1\.([A-Za-z0-9\-_]+)\.([0-9a-f]{8})$/.exec(str||'');
      if(!m) throw new Error('AyeSHA: malformed token');
      const bytes = _b64url.dec(m[1]);
      const sum = _hex(await _sha256(bytes)).slice(0,8);
      if(sum !== m[2]) throw new Error('AyeSHA: checksum mismatch');
      return bytes;
    }
  },
  encode(bytes){ return this.codec.encode(bytes); },
  decode(str){ return this.codec.decode(str); }
};
export default Ayesha;
