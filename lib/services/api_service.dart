import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_response.dart';
import '../models/login_response.dart';
import '../models/training_response.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://appabsensi.mobileprojp.com')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ─── Auth (tidak perlu token) ───────────────────────────────────────────────

  @POST('/api/register')
  Future<LoginResponse> register(@Body() Map<String, dynamic> body);

  @POST('/api/login')
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  // ─── Profile (token disisipkan otomatis oleh interceptor dio_client.dart) ───

  /// Ambil data profil user yang sedang login.
  @GET('/api/profile')
  Future<AuthResponse> getProfile();

  /// Ambil list data training
  @GET('/api/trainings')
  Future<TrainingResponse> getTrainings();

  /// Update profil.
  /// Body: name, email, jenis_kelamin, batch_id, training_id, dll.
  @PUT('/api/profile')
  Future<AuthResponse> updateProfile(@Body() Map<String, dynamic> body);

  /// Update foto profil.
  /// Body HANYA: { "profile_photo": "data:image/png;base64,<...>" }
  @PUT('/api/profile/photo')
  Future<AuthResponse> updateProfilePhoto(@Body() Map<String, dynamic> body);
}
