# CompTing (Company Accounting) Mobile App

CompTing adalah aplikasi mobile pencatatan keuangan operasional perusahaan yang dirancang khusus untuk kebutuhan bisnis harian. Aplikasi ini memfokuskan alur pada pencatatan transaksi di lapangan, pengelolaan utang-piutang, persetujuan bertingkat (*approval*), pemantauan kas, serta pembuatan laporan keuangan tanpa kompleksitas sistem ERP penuh.

## Peran Pengguna (Role-Based Access Control)

Aplikasi ini membagi hak akses ke dalam 3 peran (*roles*) sesuai dengan alur kerja operasional perusahaan:

1. **Staf / Operator (Inputer)**
   * **Fokus**: Input transaksi harian di lapangan.
   * **Akses**: Mencatat pemasukan/pengeluaran, mengunggah foto bukti nota/struk, memantau status pengajuan transaksi milik sendiri (Pending, Disetujui, Ditolak), dan mengelola data Utang/Piutang.

2. **Manager / Supervisor (Approver)**
   * **Fokus**: Otorisasi dan validasi transaksi.
   * **Akses**: Memeriksa antrean pengajuan dari staf, mengecek detail nominal dan foto bukti nota, melakukan *Approve* atau *Reject* (dengan wajib mengisi catatan alasan penolakan), serta melihat riwayat persetujuan.

3. **Finance / Admin (Full Access & Reporting)**
   * **Fokus**: Pemantauan saldo, pencetakan laporan, dan pengawasan sistem.
   * **Akses**: Memantau posisi kas & bank secara *real-time*, melihat dan mengekspor laporan keuangan (Laba Rugi dan Arus Kas) langsung ke format PDF, serta mengawasi rekam jejak seluruh aktivitas (*Audit Log*).

---

## Alur Kerja Sistem

```text
[Staf: Input Transaksi + Foto Bukti] -> [Manager: Review & Approval / Reject + Catatan] -> [Sistem: Update Ledger & Saldo Kas Otomatis] -> [Finance: Laporan & Audit Log]
```

1. **Pencatatan Lapangan**: Staf menginput transaksi pemasukan atau pengeluaran dilengkapi foto bukti fisik nota. Status awal transaksi menjadi `Menunggu Approval`.
2. **Persetujuan (Approval)**: Manager memeriksa pengajuan. 
   * Jika disetujui (*Approve*), saldo kas/bank otomatis ter-update dan transaksi masuk ke buku besar (*Ledger*).
   * Jika ditolak (*Reject*), Manager memberikan catatan alasan penolakan agar staf dapat melihat dan menindaklanjuti.
3. **Pencatatan Otomatis & Audit Trail**: Setiap tindakan (input, approval, reject, pelunasan utang/piutang) dicatat otomatis ke dalam *Audit Log*.
4. **Pelaporan & Ekspor**: Tim Finance dapat memantau ringkasan laba rugi dan arus kas serta mengekspornya langsung ke dokumen PDF.

---

## Modul dan Fitur Utama

| Modul | Peran Pengguna | Deskripsi Fitur |
| :--- | :--- | :--- |
| **Pemasukan (Income)** | Staf | Input data hasil penjualan, *invoice*, dan *payment* beserta kategori akun, *cost center*, dan foto bukti. |
| **Pengeluaran (Expense)** | Staf | Input biaya operasional, gaji, atau pembayaran *vendor* dengan lampiran foto struk. |
| **Utang & Piutang** | Staf, Finance | Pemantauan tagihan *customer* (piutang) dan kewajiban *supplier* (utang) dengan pengingat jatuh tempo dan fitur pelunasan. |
| **Persetujuan (Approval)** | Manager | Daftar antrean persetujuan transaksi, peninjauan nota fisik, serta aksi *Approve* atau *Reject* beserta catatan penolakan. |
| **Audit Log** | Finance | Catatan kronologis otomatis yang merekam siapa pengguna yang menginput, menyetujui, menolak, atau mengubah data. |
| **Kas & Bank** | Finance | Monitoring saldo *real-time* untuk Kas Utama, Rekening Bank, dan E-Wallet perusahaan. |
| **Laporan & Ekspor PDF** | Finance | Ringkasan Laba Rugi (*Profit/Loss*) dan Arus Kas (*Cash Flow*) dengan tombol ekspor langsung ke PDF. |

---

## Tampilan Navigasi per Peran

Aplikasi secara dinamis menyesuaikan menu navigasi bawah (*bottom navigation*) berdasarkan peran pengguna yang sedang login:

* **Tampilan Staf**: 
  * `Beranda` (Ringkasan singkat & status pengajuan)
  * `Transaksi` (Form input & daftar riwayat transaksi)
  * `Utang/Piutang` (Daftar tagihan & tombol pelunasan)
* **Tampilan Manager**:
  * `Beranda` (Indikator transaksi pending)
  * `Approval` (Antrean persetujuan transaksi & riwayat keputusan)
* **Tampilan Finance**:
  * `Beranda` (Ringkasan total kas/bank & grafik arus kas)
  * `Laporan & Log` (Laporan laba rugi, arus kas, ekspor PDF, & Audit Log)
