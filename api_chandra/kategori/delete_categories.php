<?php
// Mengatur header agar respons berupa JSON
header('Content-Type: application/json');

// Menghubungkan ke database
include('../db_connect.php'); // Pastikan file ini ada dan benar

// Mendapatkan input JSON dari request body
$requestBody = file_get_contents('php://input');
$data = json_decode($requestBody, true);

// Validasi input ID
$id = isset($data['id']) ? $data['id'] : null;

if (empty($id)) {
    echo json_encode(["error" => "ID kategori harus diisi"]);
    exit();
}

try {
    // Query untuk memeriksa apakah kategori ada
    $queryCheck = "SELECT * FROM categories WHERE id = ?";
    $stmtCheck = $conn->prepare($queryCheck);
    $stmtCheck->bind_param("i", $id);
    $stmtCheck->execute();
    $resultCheck = $stmtCheck->get_result();

    if ($resultCheck->num_rows === 0) {
        echo json_encode(["error" => "Kategori tidak ditemukan"]);
        exit();
    }

    // Menghapus kategori
    $queryDelete = "DELETE FROM categories WHERE id = ?";
    $stmtDelete = $conn->prepare($queryDelete);
    $stmtDelete->bind_param("i", $id);

    if ($stmtDelete->execute()) {
        echo json_encode(["message" => "Kategori berhasil dihapus"]);
    } else {
        echo json_encode(["error" => "Gagal menghapus kategori"]);
    }

    $stmtDelete->close();
} catch (Exception $e) {
    echo json_encode(["error" => "Terjadi kesalahan: " . $e->getMessage()]);
}

// Menutup koneksi database
$conn->close();
?>
