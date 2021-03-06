/**
	Password hashing routines

	Copyright: © 2012 RejectedSoftware e.K.
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Sönke Ludwig
*/
module vibe.crypto.passwordhash;

import std.base64;
import std.exception;
import std.md5;
import std.random;


/**
	Generates a psasword hash using MD5 together with a 32-bit salt.

	Params:
		password = The password for which a one-way hash is to be computed
		additional_salt = An optional string that is used to compute the final
			hash. The same string must be given to testSimplePassword to
			verify a password later. If this string is kept secret, it can
			enhance the security of this function.

	Returns:
		A base64 encoded string containing the salt and the hash value is returned.

	Remarks:
		MD5 is not considered safe and is computationally cheap. Although the
		use of salt helps a bit, using this fuction is discouraged for systems
		where security matters.

	See_Also:
		testSimplePasswordHash, vibe.crypto.md5
*/
string generateSimplePasswordHash(string password, string additional_salt = null)
{
	ubyte[4] salt;
	foreach( i; 0 .. 4 ) salt[i] = cast(ubyte)uniform(0, 256);
	ubyte[16] hash;
	sum(hash, salt, password, additional_salt);
	return Base64.encode(salt ~ hash).idup;
}

/**
	Tests a password hash generated using generateSimplePasswordHash.

	Params:
		hashstring: The string that was returned by a call to
			generateSimplePasswordHash
		password: Password string to test against the hash
		additional_salt: The same optional salt that was given to the original
			call to generateSimplePasswordHash

	Returns:
		Returns true iff the password matches the specified hash.

	See_Also:
		generateSimplePasswordHash, vibe.crypto.md5
*/
bool testSimplePasswordHash(string hashstring, string password, string additional_salt = null)
{
	ubyte[] upass = Base64.decode(hashstring);
	enforce(upass.length == 20);
	auto salt = upass[0 .. 4];
	auto hashcmp = upass[4 .. 20];
	ubyte[16] hash;
	sum(hash, salt, password, additional_salt);
	return hash == hashcmp;
}
