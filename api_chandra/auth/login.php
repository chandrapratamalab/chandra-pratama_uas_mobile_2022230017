<?php
// login.php
header("Content-Type: application/json");

// Include file koneksi database
include('../db_connect.php');

$data = json_decode(file_get_contents("php://input"), true);

// Ambil data dari request
$username = $data['username'];
$password = $data['password'];

// Validasi: Periksa apakah pengguna ada di database
$sql = "SELECT * FROM users WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    // Username tidak ditemukan
    echo json_encode([
        "status" => "error",
        "message" => "Username tidak ditemukan."
    ]);
} else {
    $user = $result->fetch_assoc();

    // Cek apakah password sesuai
    if (password_verify($password, $user['password'])) {
        // Login berhasil
        echo json_encode([
            "status" => "success",
            "message" => "Login berhasil.",
            "data" => [
                "user_id" => $user['id'],
                "name" => $user['name'],
                "username" => $user['username']
            ]
        ]);
    } else {
        // Password salah
        echo json_encode([
            "status" => "error",
            "message" => "Password salah."
        ]);
    }
}

$stmt->close();
$conn->close();
?>
