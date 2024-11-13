<?php
$servername = "localhost"; // Sesuaikan dengan server database kamu
$username = "root"; // Username database, biasanya "root" untuk localhost
$password = ""; // Password untuk user root, biasanya kosong di XAMPP
$dbname = "pem_iot"; // Ganti dengan nama database kamu

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Mengecek koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
?>
