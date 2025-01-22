<?php
// Aktifkan error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");

// Include file koneksi database
include('../db_connect.php');

// Decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validasi JSON input
if ($data === null) {
    echo json_encode(["success" => false, "message" => "Invalid JSON input."]);
    exit;
}

$name = $data['name'];
$username = $data['username'];
$password = $data['password'];
$email = $data['email'];

// Validasi: Periksa apakah username atau email sudah ada
$sql_check = "SELECT * FROM users WHERE username = ? OR email = ?";
$stmt_check = $conn->prepare($sql_check);

if (!$stmt_check) {
    echo json_encode(["success" => false, "message" => "Statement prepare failed: " . $conn->error]);
    exit;
}

$stmt_check->bind_param("ss", $username, $email);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

if ($result_check->num_rows > 0) {
    // Username atau email sudah ada
    echo json_encode(["success" => false, "message" => "Username or email already registered."]);
    $stmt_check->close();
    $conn->close();
    exit;
}

// Jika tidak ada konflik, lanjutkan pendaftaran
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO users (name, username, password, email) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Statement prepare failed: " . $conn->error]);
    $stmt_check->close();
    $conn->close();
    exit;
}

$stmt->bind_param("ssss", $name, $username, $hashed_password, $email);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Registration successful."]);
} else {
    echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
}

// Tutup statement dan koneksi setelah proses selesai
$stmt_check->close();
$stmt->close();
$conn->close();
?>
