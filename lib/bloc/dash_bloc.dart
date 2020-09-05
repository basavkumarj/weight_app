import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/other/query_tags.dart';
import 'package:weight/other/user_data.dart';
import 'package:weight/other/utility.dart';

class DashboardBloc implements BlocBase {
  FirebaseUser firebaseUser;
  final _bmiSubject = new BehaviorSubject<Map<String, dynamic>>();
  final _listSubject = new BehaviorSubject<QuerySnapshot>();

  Stream<Map<String, dynamic>> get bmiStream => _bmiSubject.stream;

  Stream<QuerySnapshot> get listStream => _listSubject.stream;

  @override
  void dispose() {
    _bmiSubject.close();
    _listSubject.close();
  }

  DashboardBloc() {
    getUser();
    updateList();
    calculateData();
  }

  Future<void> getUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser();
    return;
  }

  void calculateData() async {
    if (firebaseUser == null) await getUser();
    QuerySnapshot weightData = await Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .orderBy(QueryTags.qDateTime, descending: true)
        .limit(1)
        .getDocuments(source: Source.cache);
    double weight = weightData.documents[0][QueryTags.qWeight];
    double height = await new UserData().getHeight();
    if (height != null && weight != null) {
      double bmi = Utility.calulateBMI(height, weight);
      double percent = (bmi / 24.9).abs();
      Utility.getBMIType(bmi);
      _bmiSubject.add({
        QueryTags.qBMI: bmi.toStringAsFixed(1),
        QueryTags.qHeight: height,
        QueryTags.qWeight: weight,
        QueryTags.qBMIType: Utility.getBMIType(bmi),
        QueryTags.qBMIPercent: percent < 1.0 ? percent : percent - 1
      });
    }
  }

  Future<double> getHeight() async {
    return await new UserData().getHeight();
  }

  Future<bool> isHeightSaved() async {
    return await new UserData().getHeight() != null;
  }

  Future<void> saveWeight(double weight) async {
    if (firebaseUser == null) await getUser();
    Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .document()
        .setData({
      QueryTags.qWeight: weight,
      QueryTags.qDateTime: FieldValue.serverTimestamp()
    });
    calculateData();
    updateList();
  }

  Future<void> saveWeightHeight({double weight, double height}) async {
    if (firebaseUser == null) await getUser();
    Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .document()
        .setData({
      QueryTags.qWeight: weight,
      QueryTags.qDateTime: FieldValue.serverTimestamp()
    });
    UserData().saveHeight(height);
    calculateData();
    updateList();
  }

  Future<void> deleteData(String id) async {
    if (firebaseUser == null) await getUser();
    Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .document(id)
        .delete();
    calculateData();
  }

  Future<void> editData(String id, double newWeight) async {
    if (firebaseUser == null) await getUser();
    Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .document(id)
        .updateData({QueryTags.qWeight: newWeight});
    calculateData();
  }

  void updateList() async {
    if (firebaseUser == null) await getUser();
    Firestore.instance
        .collection(QueryTags.qWeightManagementRootCollection)
        .document(firebaseUser.uid)
        .collection(QueryTags.qWeightCollection)
        .orderBy(QueryTags.qDateTime, descending: true)
        .snapshots()
        .listen((event) {
      _listSubject.add(event);
    });
  }
}
