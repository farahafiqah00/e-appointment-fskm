package util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

/**
 * PBKDF2-SHA256 password hashing.
 * Stored format: Base64(salt):Base64(hash)
 * 310,000 iterations, 16-byte salt, 256-bit output — meets NIST SP 800-132 recommendations.
 */
public final class PasswordUtil {

    private static final String ALGORITHM  = "PBKDF2WithHmacSHA256";
    private static final int    ITERATIONS = 310_000;
    private static final int    SALT_BYTES = 16;
    private static final int    HASH_BITS  = 256;

    private PasswordUtil() {}

    /** Hashes a plain-text password. Returns a storable "salt:hash" string. */
    public static String hash(String password) {
        byte[] salt = new byte[SALT_BYTES];
        new SecureRandom().nextBytes(salt);
        byte[] hash = pbkdf2(password.toCharArray(), salt);
        return Base64.getEncoder().encodeToString(salt)
             + ":" + Base64.getEncoder().encodeToString(hash);
    }

    /** Returns true if the plain-text password matches the stored hash. */
    public static boolean verify(String password, String stored) {
        if (stored == null || !stored.contains(":")) return false;
        String[] parts = stored.split(":", 2);
        byte[] salt       = Base64.getDecoder().decode(parts[0]);
        byte[] expected   = Base64.getDecoder().decode(parts[1]);
        byte[] actual     = pbkdf2(password.toCharArray(), salt);
        return slowEquals(expected, actual);
    }

    private static byte[] pbkdf2(char[] password, byte[] salt) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, ITERATIONS, HASH_BITS);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            byte[] result = skf.generateSecret(spec).getEncoded();
            spec.clearPassword();
            return result;
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("PBKDF2 unavailable", e);
        }
    }

    /** Constant-time comparison to prevent timing attacks. */
    private static boolean slowEquals(byte[] a, byte[] b) {
        int diff = a.length ^ b.length;
        for (int i = 0; i < a.length && i < b.length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }
}
