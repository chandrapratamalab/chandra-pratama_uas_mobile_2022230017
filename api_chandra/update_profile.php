<?php
include('db_connect.php');
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data['user_id'] ?? null;
$name = $data['name'] ?? null;
$email = $data['email'] ?? null;
$username = $data['username'] ?? null;
$password = isset($data['password']) ? password_hash($data['password'], PASSWORD_DEFAULT) : null;

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID tidak ditemukan."]);
    exit;
}

// Ambil data lama jika field tidak dikirim
$sql_select = "SELECT name, email, username FROM users WHERE id = ?";
$stmt_select = $conn->prepare($sql_select);
$stmt_select->bind_param("i", $user_id);
$stmt_select->execute();
$result = $stmt_select->get_result();
$row = $result->fetch_assoc();

// Gunakan nilai lama jika field tidak dikirim
$name = $name ?: $row['name'];
$email = $email ?: $row['email'];
$username = $username ?: $row['username'];

// Update data pengguna
$sql_update = "UPDATE users SET name = ?, email = ?, username = ?" . ($password ? ", password = ?" : "") . " WHERE id = ?";
$stmt_update = $conn->prepare($sql_update);

if ($password) {
    $stmt_update->bind_param("ssssi", $name, $email, $username, $password, $user_id);
} else {
    $stmt_update->bind_param("sssi", $name, $email, $username, $user_id);
}

if ($stmt_update->execute()) {
    echo json_encode(["success" => true, "message" => "Profil berhasil diperbarui."]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal memperbarui profil."]);
}

$stmt_select->close();
$stmt_update->close();
$conn->close();
?>
