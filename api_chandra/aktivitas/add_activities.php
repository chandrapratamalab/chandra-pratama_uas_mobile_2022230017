<?php
// Sertakan file koneksi database
require_once '../db_connect.php'; // Sesuaikan path ke lokasi file db_connect.php

// Ambil data dari request JSON
$input = file_get_contents("php://input");
$data = json_decode($input, true);

// Ambil data dari array $data
$user_id = $data['user_id'] ?? null;
$name = $data['name'] ?? null;
$description = $data['description'] ?? null;
$category_id = $data['category_id'] ?? null;
$date = $data['date'] ?? null;

// Debug data yang diterima
error_log("Data yang diterima: " . print_r($data, true));

// Jika data kosong
if (empty($data)) {
    echo json_encode([
        "status" => "error",
        "message" => "Data tidak diterima."
    ]);
    exit();
}

// Validasi input
if (empty($user_id) || empty($name) || empty($description) || empty($category_id) || empty($date)) {
    echo json_encode([
        "status" => "error",
        "message" => "Semua data wajib diisi."
    ]);
    exit();
}

// Validasi user_id di tabel users
$query_user_check = "SELECT id FROM users WHERE id = ?";
$stmt_user_check = $conn->prepare($query_user_check);
$stmt_user_check->bind_param("i", $user_id);
$stmt_user_check->execute();
$result_user_check = $stmt_user_check->get_result();

if ($result_user_check->num_rows === 0) {
    echo json_encode([
        "status" => "error",
        "message" => "User tidak ditemukan."
    ]);
    exit();
}

// Tambahkan aktivitas ke tabel activities
$query = "INSERT INTO activities (name, description, category_id, date, user_id, created_at, updated_at) 
          VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssisi", $name, $description, $category_id, $date, $user_id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Aktivitas berhasil ditambahkan."
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menambahkan aktivitas. Error: " . $stmt->error
    ]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
