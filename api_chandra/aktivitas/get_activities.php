<?php
// Sertakan file koneksi database
require_once '../db_connect.php'; // Sesuaikan path ke lokasi file db_connect.php

// Ambil parameter user_id dari URL
$user_id = $_GET['user_id'] ?? null;

// Validasi user_id
if (empty($user_id)) {
    echo json_encode(["error" => "User ID wajib diisi."]);
    exit();
}

// Query untuk mendapatkan aktivitas berdasarkan user_id
$query = "
    SELECT a.id, a.name, a.description, c.name AS category_name, a.date, a.created_at, a.updated_at
    FROM activities a
    INNER JOIN categories c ON a.category_id = c.id
    WHERE a.user_id = ?
    ORDER BY a.created_at DESC
";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

// Cek jika ada hasil
if ($result->num_rows > 0) {
    $activities = [];
    while ($row = $result->fetch_assoc()) {
        $activities[] = $row;
    }
    echo json_encode(["data" => $activities]);
} else {
    echo json_encode(["data" => []]);
}
