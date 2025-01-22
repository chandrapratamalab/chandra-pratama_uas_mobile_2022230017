<?php
// db_connect.php
$host = 'localhost';  // Ganti dengan informasi database Anda
$username = 'teky6584_api_chandra';   // Ganti dengan username MySQL Anda
$password = 'NIgg2v@fbauw';       // Ganti dengan password MySQL Anda
$dbname = 'teky6584_api_chandra'; // Ganti dengan nama database Anda

// Koneksi ke database
$conn = new mysqli($host, $username, $password, $dbname);
echo "berhasil";

// Cek apakah koneksi berhasil
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}
?>
