<?php
// SRP6 Hilfsklasse für TrinityCore Account-Registrierung
// Quelle: https://github.com/azerothcore/Account-Registration/blob/master/inc/srp6.php
class SRP6 {
    // TrinityCore 3.3.5a N und g
    private static $N_hex = '894B645E89B7A89347568F812A1C4B827E0A6D700C90D6C1F4C1DFE6C3A123B7';
    private static $g_hex = '7';

    public static function generateSalt() {
        return random_bytes(32);
    }

    public static function calculateVerifier($username, $password, $salt) {
        $username = strtoupper($username);
        $password = strtoupper($password);
        $h1 = sha1($username . ':' . $password, true);
        $h2 = sha1($salt . $h1, true);
        $N = gmp_init('0x' . self::$N_hex);
        $g = gmp_init(self::$g_hex);
        $h2int = gmp_import($h2, 1, GMP_MSW_FIRST | GMP_NATIVE_ENDIAN);
        $verifier = gmp_powm($g, $h2int, $N);
        $verifier_bin = self::gmp2bin($verifier, 32);
        return $verifier_bin;
    }

    public static function getN() {
        return self::$N_hex;
    }
    public static function getG() {
        return self::$g_hex;
    }

    private static function gmp2bin($num, $pad = 32) {
        $bin = gmp_export($num, 1, GMP_MSW_FIRST | GMP_NATIVE_ENDIAN);
        return str_pad($bin, $pad, "\0", STR_PAD_LEFT);
    }
}