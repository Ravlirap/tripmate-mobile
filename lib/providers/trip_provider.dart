import 'package:flutter/material.dart';
import 'package:tubes_ppb_app/core/services/trip_service.dart';
import 'package:tubes_ppb_app/data/models/trip_model.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService;

  List<Trip> _trips = [];
  List<Trip> _agentTrips = [];
  Trip? _selectedTrip;

  bool _isLoading = false;
  String? _errorMessage;

  TripProvider(this._tripService);

  List<Trip> get trips => _trips;
  List<Trip> get agentTrips => _agentTrips;
  Trip? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Fetch public upcoming trips. Supports search filters.
  Future<void> fetchTrips({String? search}) async {
    _setLoading(true);
    _clearError();
    try {
      _trips = await _tripService.getPublicTrips(destination: search);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _trips = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch a single trip's details. If [isAgent] is true, fetches from agent resource.
  Future<Trip?> fetchTripDetail(String id, {bool isAgent = false}) async {
    _setLoading(true);
    _clearError();
    try {
      if (isAgent) {
        _selectedTrip = await _tripService.getAgentTripDetail(id);
      } else {
        _selectedTrip = await _tripService.getPublicTripDetail(id);
      }
      return _selectedTrip;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _selectedTrip = null;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch trips belonging to the logged-in agent.
  Future<void> fetchAgentTrips() async {
    _setLoading(true);
    _clearError();
    try {
      _agentTrips = await _tripService.getAgentTrips();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _agentTrips = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new open trip (Agent only).
  Future<bool> createTrip(Map<String, dynamic> tripData) async {
    _setLoading(true);
    _clearError();
    try {
      final newTrip = await _tripService.createTrip(tripData);
      _agentTrips.insert(0, newTrip);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing trip (Agent only).
  Future<bool> updateTrip(String id, Map<String, dynamic> tripData) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _tripService.updateTrip(id, tripData);
      
      // Update local agent lists
      final index = _agentTrips.indexWhere((t) => t.id == id);
      if (index != -1) {
        _agentTrips[index] = updated;
      }
      if (_selectedTrip?.id == id) {
        _selectedTrip = updated;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a trip (Agent only).
  Future<bool> deleteTrip(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _tripService.deleteTrip(id);
      _agentTrips.removeWhere((t) => t.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }
}
