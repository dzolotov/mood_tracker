import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'objectbox_repository.dart';

class ObjectBoxService {
  static final ObjectBoxService _instance = ObjectBoxService._internal();
  
  factory ObjectBoxService() => _instance;
  
  ObjectBoxService._internal();
  
  final ObjectBoxRepository _repository = ObjectBoxRepository();
  
  ObjectBoxRepository get repository => _repository;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, 'objectbox');
    
    await _repository.initialize();
    _isInitialized = true;
  }
  
  void dispose() {
    if (_isInitialized) {
      _repository.close();
      _isInitialized = false;
    }
  }
}