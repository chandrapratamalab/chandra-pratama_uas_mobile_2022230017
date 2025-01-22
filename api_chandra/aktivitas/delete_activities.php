<?php
header("Content-Type: application/json");

// Include koneksi database
include('../db_connect.php');

// Mendapatkan data dari request
$data = json_decode(file_get_contents("php://input"), true);
$id = $data['id'] ?? null;

// Validasi input
if (empty($id)) {
    echo json_encode(["error" => "ID aktivitas harus diisi."]);
    exit();
}

// Query untuk menghapus aktivitas
$query = "DELETE FROM activities WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["message" => "Aktivitas selesai."]);
} else {
    echo json_encode(["error" => "Gagal menghapus aktivitas. Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
