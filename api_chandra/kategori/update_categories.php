<?php
// Menggunakan include untuk mengakses koneksi database
include('../db_connect.php');

// Folder upload untuk gambar
$uploadDir = '../uploads/';

// Mendapatkan data dari form-data
$id = isset($_POST['id']) ? $_POST['id'] : null;
$name = isset($_POST['name']) ? $_POST['name'] : null;
$description = isset($_POST['description']) ? $_POST['description'] : null;

// Debugging: Log data input
file_put_contents('php://stderr', print_r($_POST, true));

// Validasi input
if (empty($id)) {
    echo json_encode(["error" => "ID kategori harus diisi."]);
    exit();
}

// Query untuk mendapatkan data kategori sebelumnya
$query = "SELECT * FROM categories WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();
$category = $result->fetch_assoc();

if (!$category) {
    echo json_encode(["error" => "Kategori tidak ditemukan."]);
    exit();
}

// Proses upload file jika ada
$imageFile = $category['image_file']; // Gambar lama
if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
    $imageName = $_FILES['image']['name'];
    $imageTmpName = $_FILES['image']['tmp_name'];
    $imageExtension = pathinfo($imageName, PATHINFO_EXTENSION);
    $imageNewName = uniqid() . '.' . $imageExtension;
    $imagePath = $uploadDir . $imageNewName;

    if (move_uploaded_file($imageTmpName, $imagePath)) {
        // Jika ada file baru, hapus file lama
        if (!empty($category['image_file']) && file_exists($uploadDir . $category['image_file'])) {
            unlink($uploadDir . $category['image_file']);
        }
        $imageFile = $imageNewName;
    } else {
        echo json_encode(["error" => "Gagal mengunggah gambar."]);
        exit();
    }
}

// Update data kategori
$query = "UPDATE categories SET name = ?, description = ?, image_file = ?, updated_at = NOW() WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("sssi", $name, $description, $imageFile, $id);

if ($stmt->execute()) {
    echo json_encode(["message" => "Kategori berhasil diperbarui."]);
} else {
    echo json_encode(["error" => "Gagal memperbarui kategori. Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
