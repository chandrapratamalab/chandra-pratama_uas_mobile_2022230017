<?php
// Menggunakan include untuk mengakses koneksi database
include('../db_connect.php');  // Pastikan path ini benar sesuai struktur folder Anda

try {
    // Query untuk mengambil data kategori
    $query = "SELECT id, name, description, image_file FROM categories ORDER BY created_at DESC";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();

    $categories = [];

    // Mendapatkan protocol (http atau https) dan host
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'];
    $baseUrl = "$protocol://$host/project_api/api_chandra/uploads/";  // Path gambar pada server

    while ($row = $result->fetch_assoc()) {
        // Gabungkan URL gambar dengan nama file
        $row['image_file'] = $baseUrl . htmlspecialchars($row['image_file']);
        // Melakukan sanitasi untuk mencegah XSS
        $row['name'] = htmlspecialchars($row['name']);
        $row['description'] = htmlspecialchars($row['description']);
        
        // Menambahkan data kategori ke dalam array
        $categories[] = $row;
    }

    // Menyiapkan response API
    $response = array(
        'status' => 'success',
        'data' => $categories
    );

    // Menutup koneksi database
    $stmt->close();
    $conn->close();

    // Menampilkan response dalam format JSON
    header('Content-Type: application/json');
    echo json_encode($response);

} catch (Exception $e) {
    // Jika terjadi error, tangkap pesan error dan kembalikan response gagal
    $response = array(
        'status' => 'error',
        'message' => 'Terjadi kesalahan: ' . $e->getMessage()
    );
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
