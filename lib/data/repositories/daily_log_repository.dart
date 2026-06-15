import '../dao/daily_log_dao.dart';
import '../models/daily_log.dart';

class DailyLogRepository {
  final DailyLogDao _dao;

  DailyLogRepository(this._dao);

  Future<int> addLog(DailyLog log)                     => _dao.insert(log);
  Future<List<DailyLog>> getLogsForDate(String date)   => _dao.getByDate(date);
  Future<List<String>> getDistinctDates()               => _dao.getDistinctDates();
  Future<int> updateLog(DailyLog log)                   => _dao.update(log);
  Future<int> deleteLog(int id)                         => _dao.delete(id);
}