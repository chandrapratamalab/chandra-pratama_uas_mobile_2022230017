<?php
header("Content-Type: application/json");

// Include koneksi database
include('../db_connect.php');

// Mendapatkan data dari request
$data = json_decode(file_get_contents("php://input"), true);

$id = $data['id'] ?? null;
$name = $data['name'] ?? null;
$description = $data['description'] ?? null;
$category_id = $data['category_id'] ?? null;
$date = $data['date'] ?? null;

// Validasi ID
if (empty($id)) {
    echo json_encode(["error" => "ID aktivitas wajib diisi."]);
    exit();
}

// Validasi category_id jika diberikan
if (!empty($category_id)) {
    $query_check = "SELECT id FROM categories WHERE id = ?";
    $stmt_check = $conn->prepare($query_check);
    $stmt_check->bind_param("i", $category_id);
    $stmt_check->execute();
    $result_check = $stmt_check->get_result();

    if ($result_check->num_rows === 0) {
        echo json_encode(["error" => "Kategori tidak ditemukan."]);
        exit();
    }
    $stmt_check->close();
}

// Bangun query UPDATE secara dinamis berdasarkan kolom yang diberikan
$updateFields = [];
$params = [];
$paramTypes = "";

// Tambahkan kolom yang diberikan ke query
if (!empty($name)) {
    $updateFields[] = "name = ?";
    $params[] = $name;
    $paramTypes .= "s";
}
if (!empty($description)) {
    $updateFields[] = "description = ?";
    $params[] = $description;
    $paramTypes .= "s";
}
if (!empty($category_id)) {
    $updateFields[] = "category_id = ?";
    $params[] = $category_id;
    $paramTypes .= "i";
}
if (!empty($date)) {
    $updateFields[] = "date = ?";
    $params[] = $date;
    $paramTypes .= "s";
}

// Tambahkan ID ke parameter
$params[] = $id;
$paramTypes .= "i";

// Pastikan ada kolom yang diperbarui
if (empty($updateFields)) {
    echo json_encode(["error" => "Tidak ada kolom yang diperbarui."]);
    exit();
}

// Gabungkan query UPDATE
$query = "UPDATE activities SET " . implode(", ", $updateFields) . ", updated_at = NOW() WHERE id = ?";
$stmt = $conn->prepare($query);

// Bind parameter secara dinamis
$stmt->bind_param($paramTypes, ...$params);

// Eksekusi query
if ($stmt->execute()) {
    echo json_encode(["message" => "Aktivitas berhasil diperbarui."]);
} else {
    echo json_encode(["error" => "Gagal memperbarui aktivitas. Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
