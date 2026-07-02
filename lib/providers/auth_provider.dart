import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/training_model.dart';
import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../services/token_services.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService(createDioClient());
  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  List<TrainingModel>? _trainings;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  List<TrainingModel>? get trainings => _trainings;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });
      final token = response.data?.token;

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak diterima dari server.');
      }

      await TokenStorage.saveToken(token);
      _user = response.data?.user;
      return true;
    } on DioException catch (e) {
      _setError(_parseDioError(e));
      return false;
    } catch (e) {
      _setError('Gagal login: ${e.toString().replaceFirst('Exception: ', '')}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(Map<String, dynamic> body) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiService.register(body);
      final token = response.data?.token;

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak diterima dari server setelah register.');
      }

      await TokenStorage.saveToken(token);
      _user = response.data?.user;
      return true;
    } on DioException catch (e) {
      _setError(_parseDioError(e));
      return false;
    } catch (e) {
      _setError('Gagal register: ${e.toString().replaceFirst('Exception: ', '')}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    _user = null;
    _trainings = null;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.getProfile();
      _user = response.data ?? response.user;
      
      // Also fetch trainings if empty to optimize dropdown
      if (_trainings == null) {
        final trainingResp = await _apiService.getTrainings();
        _trainings = trainingResp.data;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> fetchTrainings() async {
    try {
      final trainingResp = await _apiService.getTrainings();
      _trainings = trainingResp.data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching trainings: $e');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiService.updateProfile(body);
      _user = response.data ?? response.user ?? _user;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_parseDioError(e));
      return false;
    } catch (e) {
      _setError('Gagal update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfilePhoto(String base64Image) async {
    _setLoading(true);
    try {
      final response = await _apiService.updateProfilePhoto({'profile_photo': base64Image});
      final updatedUser = response.data ?? response.user;
      if (updatedUser?.profilePhoto != null) {
        _user = _user?.copyWith(profilePhoto: updatedUser?.profilePhoto) ?? updatedUser;
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _setError(_parseDioError(e));
      return false;
    } catch (e) {
      _setError('Update photo error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      // TODO: Implement real API call when endpoint is ready
      // await _apiService.changePassword({'current_password': currentPassword, 'new_password': newPassword});
      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      return true;
    } catch (e) {
      _setError('Gagal mengubah password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _parseDioError(DioException e) {
    if (e.response == null) return 'Terjadi kesalahan jaringan.';
    final status = e.response?.statusCode;
    if (status == 401 || status == 404) return 'Sesi habis atau data tidak ditemukan.';
    if (status == 422) {
      final errors = e.response?.data['errors'];
      return errors != null ? 'Data tidak valid: $errors' : 'Data tidak valid.';
    }
    if (status == 500) return 'Server sedang bermasalah (500).';
    return extractApiMessage(e.response?.data, e.message ?? 'Terjadi kesalahan.');
  }
}
