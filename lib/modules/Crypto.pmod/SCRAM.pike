
//! SCRAM, defined by @rfc{5802@}.
//!
//! This implements both the client and the serverside.
//! You normally run either the server or the client, but if you would
//! run both, the sequence would be:
//!
//! @[client_1] -> @[server_1] -> @[server_2] -> @[client_2] ->
//! @[server_3] -> @[client_3()

#pike __REAL_VERSION__
#pragma strict_types
#require constant(Crypto.Hash)

private .Hash H;  // hash object

private string(8bit) first, cnonce;

constant ClientKey = "Client Key";
constant ServerKey = "Server Key";

//! Step 0 in the SCRAM handshake, prior to creating the object,
//! you need to have agreed with the server on the hashfunction to be used.
//!
//! @param h
//!   The hash object on which the SCRAM object should base its
//!   operations. Typical input is @[Crypto.SHA256].
//!
//! @seealso
//!   @[client_1]
protected void create(.Hash h) {
  H = h;
}

private Crypto.MAC.State HMAC(string(8bit) key) {
  return H->HMAC(key);
}

//! Client-side step 1 in the SCRAM handshake.
//!
//! @param username
//!   The username to feed to the server.  Some servers already received
//!   the username through an alternate channel (usually during
//!   the hash-function selection handshake), in which case it
//!   should be omitted here.
//!
//! @returns
//!   The first request to send to the server.
//!
//! @seealso
//!   @[client_2]
string(7bit) client_1(void|string username) {
  cnonce = MIME.encode_base64(random_string(18));
  return [string(7bit)](first = [string(8bit)]sprintf("n,,n=%s,r=%s",
    username && username != "" ? Standards.IDNA.to_ascii(username, 1) : "",
    cnonce));
}

//! Server-side step 1 in the SCRAM handshake.
//!
//! @returns
//!   The username specified by the client.
//!
//! @seealso
//!   @[server_2]
string server_1(Stdio.Buffer|string(8bit) line) {
  constant format = "n,,n=%s,r=%s";
  string username, r;
  first = [string(8bit)]line[3..];
  [username, r] = stringp(line)
    ? array_sscanf([string]line, format)
    : [array(string)](line->sscanf(format));
  cnonce = [string(8bit)]r;
  return Standards.IDNA.to_unicode(username);
}

//! Server-side step 2 in the SCRAM handshake.
//!
//! @param salt
//!   The salt corresponding to the username that has been specified earlier.
//!
//! @param iters
//!   The number of iterations the hashing algorithm should perform
//!   to compute the authentication hash.
//!
//! @returns
//!   The first response to be sent to the client.
//!
//! @seealso
//!   @[server_3]
string(7bit) server_2(string(8bit) salt, int iters) {
  string response = sprintf("r=%s,s=%s,i=%d",
    cnonce += MIME.encode_base64(random_string(18)),
    MIME.encode_base64(salt),
    iters);
  first += "," + response + ",";
  return [string(7bit)]response;
}

//! Client-side step 2 in the SCRAM handshake.
//!
//! @param pass
//!   The password to feed to the server.
//!
//! @param line
//!   The challenge received from the server to our @[client_first].
//!
//! @returns
//!   The final response to send to the server.
//!
//! @seealso
//!   @[client_3]
string(7bit) client_2(string pass, Stdio.Buffer|string(8bit) line) {
  constant format = "r=%s,s=%s,i=%d";
  string r, salt;
  int iters;
  [r, salt, iters] = stringp(line)
    ? array_sscanf([string]line, format)
    : [array(string)](line->sscanf(format));
  if (iters > 0 && has_prefix(r, cnonce)) {
    line = [string(8bit)]sprintf("c=biws,r=%s", r);
    r = sprintf("%s,r=%s,s=%s,i=%d,%s", first[3..], r, salt, iters, line);
    if (pass != "")
      pass = Standards.IDNA.to_ascii(pass);
    salt = MIME.decode_base64(salt);
    if (!(first = .SCRAM_get_salted_password(H, pass, salt, iters))) {
      first = [string(8bit)]H->pbkdf2(pass, salt, iters, H->digest_size());
      .SCRAM_set_salted_password(first, H, pass, salt, iters);
    }
    Crypto.MAC.State hmacfirst = HMAC(first);
    first = 0;                         // Free memory
    salt = hmacfirst([string(8bit)]ClientKey);
    salt = sprintf("%s,p=%s", line,
      MIME.encode_base64(salt
        ^ HMAC(H->hash([string(8bit)]salt))([string(8bit)]r)));
    cnonce = HMAC(hmacfirst([string(8bit)]ServerKey))([string(8bit)]r);
  } else
    salt = 0;
  return [string(7bit)]salt;
}

//! Server-side step 3 in the SCRAM handshake.
//!
//! @param salted_password
//!   The salted (using the salt provided earlier) password belonging
//!   to the specified username.
//!
//! @returns
//!   The final response to send to the client.
string(7bit) server_3(string(8bit) salted_password,
 Stdio.Buffer|string(8bit) line) {
  constant format = "c=biws,r=%s,p=%s";
  string r, p, response;
  [r, p] = stringp(line)
    ? array_sscanf([string]line, format)
    : [array(string)](line->sscanf(format));
  if (r == cnonce) {
    first += sprintf("c=biws,r=%s", r);
    Crypto.MAC.State hmacfirst = HMAC(salted_password);
    r = hmacfirst([string(8bit)]ClientKey);
    if (MIME.decode_base64(p)
     == [string(8bit)](r ^ HMAC(H->hash([string(8bit)]r))(first)))
      response = sprintf("v=%s", MIME.encode_base64(HMAC(
         hmacfirst([string(8bit)]ServerKey))(first)));
  }
  return response;
}

//! Final step 3 in the SCRAM handshake.  If we get this far, the
//! server has already verified that we supplied the correct credentials.
//! If this step fails, it means the server does not have our
//! credentials at all.
//!
//! @param line
//!   The verification received from the server to our @[client_final].
//!
//! @returns
//!   True if the server is valid, false if the server is invalid.
int(0..1) client_3(Stdio.Buffer|string line) {
  constant format = "v=%s";
  string(8bit) v;
  [v] = stringp(line)
    ? array_sscanf(line, format) : line->sscanf(format);
  return MIME.decode_base64(v) == cnonce;
}
