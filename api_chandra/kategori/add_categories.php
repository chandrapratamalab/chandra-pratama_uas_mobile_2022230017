<?php
// Menggunakan include untuk mengakses koneksi database
include('../db_connect.php');

// Folder upload untuk gambar
$uploadDir = '../uploads/';

// Mendapatkan data dari form-data
$name = isset($_POST['name']) ? $_POST['name'] : null;
$description = isset($_POST['description']) ? $_POST['description'] : null;

// Debugging: Cek data POST
file_put_contents('php://stderr', print_r($_POST, true));

// Cek apakah file gambar di-upload
if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
    $imageName = $_FILES['image']['name'];
    $imageTmpName = $_FILES['image']['tmp_name'];
    $imageExtension = pathinfo($imageName, PATHINFO_EXTENSION);
    $imageNewName = uniqid() . '.' . $imageExtension;
    $imagePath = $uploadDir . $imageNewName;

    if (move_uploaded_file($imageTmpName, $imagePath)) {
        $imageFile = $imageNewName;
    } else {
        echo json_encode(["error" => "Gagal memindahkan file gambar."]);
        exit();
    }
} else {
    echo json_encode(["error" => "File gambar tidak ditemukan."]);
    exit();
}

// Debugging: Pastikan variabel terisi sebelum query
file_put_contents('php://stderr', print_r([
    "name" => $name,
    "description" => $description,
    "imageFile" => $imageFile
], true));

// Validasi input
if (empty($name) || empty($description)) {
    echo json_encode(["error" => "Nama dan deskripsi kategori harus diisi."]);
    exit();
}

// Query untuk menambahkan kategori
$query = "INSERT INTO categories (name, description, image_file, created_at, updated_at) 
          VALUES (?, ?, ?, NOW(), NOW())";

$stmt = $conn->prepare($query);

// Debugging: Pastikan statement SQL berhasil disiapkan
if (!$stmt) {
    echo json_encode(["error" => "Gagal mempersiapkan query. Error: " . $conn->error]);
    exit();
}

// Bind parameter dan eksekusi query
$stmt->bind_param("sss", $name, $description, $imageFile);
if ($stmt->execute()) {
    echo json_encode(["message" => "Kategori berhasil ditambahkan."]);
} else {
    echo json_encode(["error" => "Gagal menambahkan kategori. Error: " . $stmt->error]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
