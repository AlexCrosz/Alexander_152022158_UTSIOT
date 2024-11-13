<?php
header('Content-Type: application/json');
include 'koneksi.php';

// Query to get min, max, avg values
$sql = "
    SELECT 
        MIN(suhu) AS min_suhu, MAX(suhu) AS max_suhu, AVG(suhu) AS rata_suhu,
        MIN(humid) AS min_humid, MAX(humid) AS max_humid, AVG(humid) AS rata_humid
    FROM tb_cuaca";
$hasil = $conn->query($sql);

$response = array();

if ($hasil->num_rows > 0) {
    $row = $hasil->fetch_assoc();

    // Basic statistics
    $response["suhumax"] = (int)$row['max_suhu'];
    $response["suhumin"] = (int)$row['min_suhu'];
    $response["suhurata"] = (float)$row['rata_suhu'];
    $response["humidmax"] = (int)$row['max_humid'];
    $response["humidmin"] = (int)$row['min_humid'];
    $response["humidrata"] = (float)$row['rata_humid'];
}

// Query to get maximum temperature and humidity records with details
$sql_details = "
    SELECT 
        id AS idx, suhu, humid, lux AS kecerahan, ts AS timestamp
    FROM tb_cuaca
    WHERE suhu = (SELECT MAX(suhu) FROM tb_cuaca)
      AND humid = (SELECT MAX(humid) FROM tb_cuaca)";
$hasil_details = $conn->query($sql_details);

$response["nilai_suhu_max_humid_max"] = array();

if ($hasil_details->num_rows > 0) {
    while ($row_details = $hasil_details->fetch_assoc()) {
        $response["nilai_suhu_max_humid_max"][] = array(
            "idx" => (int)$row_details['idx'],
            "suhu" => (float)$row_details['suhu'],
            "humid" => (float)$row_details['humid'],
            "kecerahan" => (float)$row_details['kecerahan'],
            "timestamp" => $row_details['timestamp']
        );
    }
}

// Query to get unique month-year combinations for max temperature records
$sql_month_year = "
    SELECT DISTINCT DATE_FORMAT(ts, '%c-%Y') AS month_year
    FROM tb_cuaca
    WHERE suhu = (SELECT MAX(suhu) FROM tb_cuaca)
    LIMIT 2";
$hasil_month_year = $conn->query($sql_month_year);

$response["month_year_max"] = array();

if ($hasil_month_year->num_rows > 0) {
    while ($row_month_year = $hasil_month_year->fetch_assoc()) {
        $response["month_year_max"][] = array(
            "month_year" => $row_month_year['month_year']
        );
    }
}

// Sending the response in JSON format
echo json_encode($response);

$conn->close();
?>
