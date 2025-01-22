<?php
include('db_connect.php');
header("Content-Type: application/json");

// Ambil data JSON dari body request
$data = json_decode(file_get_contents("php://input"), true);
$user_id = $data['user_id'] ?? null;

// Validasi input
if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID tidak ditemukan."]);
    exit;
}

// Hapus akun dari database
$sql = "DELETE FROM users WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Akun berhasil dihapus."]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus akun."]);
}

$stmt->close();
$conn->close();
?>
