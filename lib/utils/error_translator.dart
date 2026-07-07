import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:absen_ah/l10n/app_localizations.dart';

class ErrorTranslator {
  /// Menerjemahkan error (bisa berupa DioException, Exception, atau String) ke dalam bahasa yang aktif di context.
  static String translate(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;

    if (error == null) return l10n.errNetworkError;

    String rawMessage = '';
    int? statusCode;

    if (error is DioException) {
      statusCode = error.response?.statusCode;
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response?.data as Map;
        rawMessage = (data['message'] ?? data['error'] ?? '').toString();
      }
      if (rawMessage.isEmpty) {
        rawMessage = error.message ?? '';
      }
    } else if (error is Exception) {
      rawMessage = error.toString().replaceFirst('Exception: ', '');
    } else {
      rawMessage = error.toString();
    }

    // 1. Cek berdasarkan status code & rawMessage
    if (statusCode == 401 ||
        rawMessage.toLowerCase().contains('unauthorized') ||
        rawMessage.toLowerCase().contains('unauthenticated') ||
        rawMessage.toLowerCase().contains('sesi habis')) {
      return l10n.errSessionExpired;
    }

    if (statusCode == 409 ||
        rawMessage.toLowerCase().contains('sudah absen hari ini')) {
      return l10n.errAlreadyCheckedInToday;
    }

    if (rawMessage.toLowerCase().contains('sudah mengajukan izin')) {
      return l10n.errAlreadyPermittedToday;
    }

    if (statusCode == 500 || rawMessage.toLowerCase().contains('server sedang bermasalah')) {
      return l10n.errServer500;
    }

    if (statusCode == 422 || rawMessage.toLowerCase().contains('data tidak valid')) {
      return l10n.errInvalidData;
    }

    // 2. Cek exact / partial string match (Fallback mapping)
    final lower = rawMessage.toLowerCase();
    if (lower.contains('sudah absen hari ini')) return l10n.errAlreadyCheckedInToday;
    if (lower.contains('belum melakukan absen masuk')) return l10n.errCheckOutFailed;
    if (lower.contains('gagal melakukan absen masuk')) return l10n.errCheckInFailed;
    if (lower.contains('gagal melakukan absen pulang') || lower.contains('gagal check-in')) return l10n.errCheckOutFailed;
    if (lower.contains('gagal mengajukan izin')) return l10n.errPermitFailed;
    if (lower.contains('gagal menghapus data absen')) return l10n.errDeleteFailed;
    if (lower.contains('gagal login') || lower.contains('login failed')) return l10n.errLoginFailed;
    if (lower.contains('kesalahan jaringan') || lower.contains('connection') || lower.contains('timeout') || lower.contains('socketexception')) {
      return l10n.errNetworkError;
    }

    // Jika tidak ada pola yang cocok, kembalikan pesan asli
    return rawMessage.isNotEmpty ? rawMessage : l10n.errNetworkError;
  }

  /// Helper untuk digunakan di provider (tanpa context) agar menyimpan string baku/key yang konsisten
  static String getStandardMessage(dynamic error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401) return 'Unauthorized';
      if (status == 409) {
        final data = error.response?.data;
        final msg = data is Map ? (data['message'] ?? '') : '';
        if (msg.toString().toLowerCase().contains('izin')) return 'Anda sudah mengajukan izin pada tanggal ini.';
        return 'Sudah absen hari ini';
      }
      if (status == 500) return 'Server sedang bermasalah (500).';
      if (status == 422) return 'Data tidak valid.';
      if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout || error.type == DioExceptionType.connectionError) {
        return 'Terjadi kesalahan jaringan.';
      }
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
